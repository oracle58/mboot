[BITS 16]
[ORG 0x7C00]

CODE_OFFSET       equ 0x8
DATA_OFFSET       equ 0x10

; Kernel load address at 1 MiB
KERNEL_START_ADDR equ 0x100000
KERNEL_OFFSET_LOW equ KERNEL_START_ADDR & 0xFFFF    ; low 16 bits (0x0000)
KERNEL_LOAD_SEG   equ KERNEL_START_ADDR >> 4       ; segment (0x1000)

start:
    cli                           ; Disable interrupts
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti                           ; Enable interrupts

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
    lgdt [gdt_descriptor]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp CODE_OFFSET:PModeMain     ; far-jump into protected mode

disk_read_error:
    hlt

; ── GDT TABLE ────────────────────────────────────────────────────────────────
gdt_start:
    dd 0x00000000   ; null descriptor
    dd 0x00000000

    ; code segment descriptor
    dw 0xFFFF       ; limit low
    dw 0x0000       ; base low
    db 0x00         ; base mid
    db 10011010b    ; access: P=1, DPL=0, S=1, E=1, RW=1
    db 11001111b    ; flags: G=1, D/B=1, L=0, AVL=0
    db 0x00         ; base high

    ; data segment descriptor
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b    ; access: P=1, DPL=0, S=1, E=0, RW=1
    db 11001111b    ; flags
    db 0x00

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

; ── DISK ADDRESS PACKET (16 bytes) ──────────────────────────────────────────
; Structure: size(1), reserved(1), count(2), off(2), seg(2), high dword(4), LBA(8)
; Here: read 8 sectors starting at LBA=1 into 0x0010 0000
disk_packet:
    db 16, 0                            ; packet size, reserved
    dw 8                                ; number of sectors
    dw KERNEL_OFFSET_LOW                ; offset low
    dw KERNEL_LOAD_SEG                  ; segment (0x1000)
    dd 0                                ; high dword unused
    dq 1                                ; starting LBA (sector #1)

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

    in   al, 0x92
    or   al, 2
    out  0x92, al

    jmp CODE_OFFSET:KERNEL_START_ADDR

times 510 - ($ - $$) db 0
    dw    0xAA55