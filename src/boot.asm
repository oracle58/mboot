[BITS 16]
[ORG 0x7C00]

CODE_OFFSET       equ 0x8
DATA_OFFSET       equ 0x10

; Kernel load address constants - use direct values instead of calculations
KERNEL_START_ADDR equ 0x100000    ; 1MB physical address
KERNEL_SEG        equ 0x1000      ; Segment for disk load (1MB >> 4)
KERNEL_OFF        equ 0x0000      ; Offset within segment

start:
    cli                           ; Disable interrupts
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti                           ; Enable interrupts

    ; ── ENABLE A20 VIA PORT 0x92 ──
    in    al, 0x92
    or    al, 00000010b
    out   0x92, al

; ── EXTENDED-READ KERNEL TO 1 MiB ───────────────────────────────────────────
; place packet below 64 KiB (at 0x0000:0x9000)
    mov ax, 0x0000
    mov es, ax
    mov si, disk_packet - $$      ; offset to disk_packet
    add si, 0x9000                ; packet at ORG+0x9000

    mov ah, 0x42                  ; EDD "Read sectors" function
    mov dl, 0x80                  ; HDD #1
    int 0x13
    jc disk_read_error

load_PM:
    cli
    lgdt [gdt.descriptor]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp CODE_OFFSET:PModeMain     ; far-jump into protected mode

disk_read_error:
    hlt

; ── GDT TABLE ────────────────────────────────────────────────────────────────
gdt:
    .start:

        dd 0x00000000   ; null descriptor
        dd 0x00000000

        ; code segment descriptor
        dw 0xFFFF       ; limit low (4 GiB limit)
        dw 0x0000       ; base low
        db 0x00         ; base mid
        db 10011010b    ; access: P=1, DPL=0, S=1, E=1, RW=1
        db 11001111b    ; flags: G=1, D/B=1, L=0, AVL=0
        db 0x00         ; base high

        ; data segment descriptor
        dw 0xFFFF       ; limit low (4 GiB limit)
        dw 0x0000       ; base low
        db 0x00         ; base mid
        db 10010010b    ; access: P=1, DPL=0, S=1, E=0, RW=1
        db 11001111b    ; flags: G=1, D/B=1, L=0, AVL=0
        db 0x00         ; base high

    .end:

    .descriptor:
        dw gdt.end - gdt.start - 1
        dd gdt.start

; ── DISK ADDRESS PACKET (16 bytes) ──────────────────────────────────────────
; Structure: size(1), reserved(1), count(2), off(2), seg(2), high dword(4), LBA(8)
; Here: read 8 sectors starting at LBA=1 into 0x0010 0000
disk_packet:
    db 16, 0                ; packet size, reserved
    dw 8                    ; number of sectors
    dw 0x0000              ; offset - use direct value
    dw 0x1000              ; segment - use direct value
    dd 0                   ; high dword unused
    dq 1                   ; starting LBA (sector #1)

    [BITS 32]
    PModeMain:
        mov ax, DATA_OFFSET
        mov ds, ax
        mov es, ax
        mov fs, ax
        mov ss, ax
        mov gs, ax
        mov ebp, 0x9C00
        mov esp, ebp
    
        ; Write test pattern to verify VGA memory access
        mov edi, 0xB8000
        mov byte [edi], 'K'      ; First char
        mov byte [edi+1], 0x07
        mov byte [edi+2], '>'    ; Second char
        mov byte [edi+3], 0x07
    
        ; Move cursor after the '>' character
        mov dx, 0x3D4
        mov al, 0x0F
        out dx, al
        mov dx, 0x3D5
        mov al, 3           ; Position 3 (after >)
        out dx, al
        mov dx, 0x3D4
        mov al, 0x0E
        out dx, al
        mov dx, 0x3D5
        mov al, 0
        out dx, al

        ; Debug: Write directly to VGA memory
        mov dword [0xB8000], 0x4F4B4F4B   ; "KK" in white on red
    
        jmp dword CODE_OFFSET:KERNEL_START_ADDR

times 510 - ($ - $$) db 0
dw    0xAA55