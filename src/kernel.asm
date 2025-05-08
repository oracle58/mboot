[BITS 32]

global _start
extern kmain

_start:
    ; Set up segment registers
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    ; Write a debug message to VGA memory showing kernel entry point was reached
    mov dword [0xB8000], 0x074B074B   ; "KK" in white
    mov dword [0xB8004], 0x0721074F   ; "O!" in white

    ; Call C kernel
    call kmain
    jmp $

times 512-($ - $$) db 0