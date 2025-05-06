[BITS 16]
[ORG 0x7C00]

CODE_OFFSET  equ 0x8
DATA_OFFSET  equ 0x10

KERNEL_LOAD  equ 0x1000         ; where linker.ld places the kernel
KERNEL_START equ 0x10000

start:
    cli           ; Clear interrupts, disabling all maskable interrupts
    mov ax, 0x00  ; Load immediate value 0x00 into register AX
    mov ds, ax    ; Set data segment (DS) to 0x00
    mov es, ax    ; Set extra segment (ES) to 0x00
    mov ss, ax    ; Set stack segment (SS) to 0x00
    mov sp, 0x7c00; Set stack pointer (SP) to 0x7c00, top of the bootloader segment
    sti           ; Enable interrupts, allowing them to occur again

; ── LOAD KERNEL ─────────────────────────────────────────────────────────────────────
mov bx, KERNEL_LOAD 
mov dh, 0x00
mov dl, 0x80
mov cl, 0x02
mov ch, 0x00
mov ah, 0x02
mov al, 8
int 0x13

jc disk_read_error



load_PM:
    cli
    lgdt[gdt.descriptor]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp CODE_OFFSET:PModeMain

disk_read_error:
    hlt

; ── GDT ─────────────────────────────────────────────────────────────────────
gdt:
    .start:
        dd 0x00000000                  ; Null descriptor
        dd 0x00000000

        dw 0xFFFF                      ; Code seg limit
        dw 0x0000                      ; Code seg base
        db 0x00
        db 10011010b                   ; P=1, DPL=0, S=1, E=1, RW=1
        db 11001111b                   ; G=1, D/B=1, L=0, AVL=0

        dw 0xFFFF                      ; Data seg limit
        dw 0x0000                      ; Data seg base
        db 0x00
        db 10010010b                   ; P=1, DPL=0, S=1, E=0, RW=1
        db 11001111b                   ; G=1, D/B=1, L=0, AVL=0
    .end:

    .descriptor:
        dw gdt.end - gdt.start - 1     ; size
        dd gdt.start                   ; address
; ────────────────────────────────────────────────────────────────────────────

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

    jmp CODE_OFFSET:KERNEL_START


times 510 - ($ - $$) db 0
dw    0xAA55
