[BITS 16]              ; Assemble for 16-bit real mode (BIOS mode)
[ORG 0x7C00]           ; Load at 0x7C00 (where BIOS loads bootloader)

start: 
    cli                ; Clear interrupts 
    mov ax, 0x00       
    mov ds, ax         ; Set Data segment to 0x00
    mov es, ax         ; Set Extra segment to 0x00
    mov ss, ax         ; Set Stack segment to 0x00
    mov sp, 0x7C00     ; Set Stack pointer to 0x7C00 (top of bootloader segment)
    mov si, msg        ; Load address of message into source index (SI) register
    sti                ; Re-enable interrupts

print: 
    lodsb              ; Load byte from [DS:SI] into AL, increment SI
    cmp al, 0          ; compare value in AL with string null terminator
    je done            ; If end of string, jump to done
    mov ah, 0x0E       ; BIOS teletype function (print char in AL to screen)
    int 0x10           ; Call BIOS teletype interrupt
    jmp print          ; Repeat for next character

done: 
    cli                ; Disable interrupts before halting
    hlt                ; Halt CPU Exec

msg: 
    dw 'Hello World!', 0       ; Message to print  

times 510 - ($ - $$) db 0      ; Pad the file with 0s to make it 512 bytes
dw 0xAA55                      ; Boot signature (magic number the BIOS requires)
