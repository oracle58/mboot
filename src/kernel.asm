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

    ; Debug: Write directly to VGA memory
    mov dword [0xB8000], 0x4F4B4F4B   ; "KK" in white on red

    ; Call C kernel
    call kmain
    jmp $

times 512-($ - $$) db 0