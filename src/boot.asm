[BITS 16]
[ORG 0x7C00]

CODE_OFFSET  equ 0x8
DATA_OFFSET  equ 0x10

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

load_PM:
    cli
    lgdt[gdt.descriptor]       
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp CODE_OFFSET:PModeMain

; ── here begins our single “gdt” block ───────────────────────────────────────
gdt:
    .start:

    dd 0x00000000                  ; Null descriptor
    dd 0x00000000

    ; ── code segment descriptor ───────────────────────────────────────────
    dw 0xFFFF                      ; Limit
    dw 0x0000                      ; Base
    db 0x00
    db 10011010b                   ; P=1, DPL=00, S=1(=code/data), E=1(code), RW=1
    db 11001111b                   ; G=1, D/B=1, L=0, AVL=0

    ; ── data segment descriptor ───────────────────────────────────────────
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b                   ; P=1, DPL=00, S=1, E=0(data), RW=1
    db 11001111b

    .end:                                

    .descriptor:                       
        dw  gdt.end - gdt.start - 1      ; size of GDT minus one
        dd  gdt.start                    ; pointer to GDT base
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
    jmp  $

times 510 - ($ - $$) db 0
dw    0xAA55
