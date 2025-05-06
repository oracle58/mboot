[BITS 16]              ; Assemble for 16-bit real mode (BIOS mode)
[ORG 0x7C00]           ; Load at 0x7C00 (where BIOS loads bootloader)

start: 
    cli                ; Disable interrupts (prevents random interruptions while setting up)
    mov ax, 0x00       
    mov ds, ax         ; Data segment to 0x0000
    mov es, ax         ; Extra segment to 0x0000
    mov ss, ax         ; Stack segment to 0x0000
    mov sp, 0x7C00     ; Stack pointer at 0x7C00 (same as code load address, simple and safe)
    sti                ; Re-enable interrupts

    mov si, msg        ; Point SI (source index) to start of the message

print: 
    lodsb              ; Load byte from [DS:SI] into AL, increment SI
    cmp al, 0          ; String null terminator?
    je done            ; If yes, jump to done
    mov ah, 0x0E       ; BIOS teletype function (print char in AL to screen)
    int 0x10           ; Call BIOS video interrupt
    jmp print          ; Repeat for next character

done: 
    cli                ; Disable interrupts before halting
    hlt                ; Halt CPU Exec

msg: 
    dw 'Hello World!', 0       ; Message to print  

times 510 - ($ - $$) db 0      ; Pad the file with 0s to make it 512 bytes
dw 0xAA55                      ; Boot signature (magic number the BIOS requires)
