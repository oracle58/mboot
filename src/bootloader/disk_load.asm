disk_load:
    pusha
    push dx

    mov ah, 0x02 ; read mode
    mov al, dh   ; read dh number of sectors
    mov cl, 0x02 ; start from sector 2 [sector 1 is reserved for boot]
    mov ch, 0x00 ; cylinder 0
    mov dh, 0x00 ; head 0

    ; dl = drive number is set as input to disk_load
    ; es:bx = buffer pointer is set as input as well

    int 0x13      ; BIOS interrupt
    jc disk_error ; check carry bit for error

    pop dx        ; get back original number of sectors to read
    cmp al, dh    ; BIOS sets 'al' to the # of sectors actually read
                  ; compare it to 'dh' and error out if they are !=
    jne sectors_error
    popa
    ret

disk_error:
    mov si, disk_error_msg
    call print_error
    jmp disk_loop

sectors_error:
    mov si, sectors_error_msg
    call print_error
    jmp disk_loop

print_error:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    mov bh, 0x00
    int 0x10
    jmp print_error
.done:
    ret

disk_loop:
    jmp $

disk_error_msg: db "Disk read error!", 0
sectors_error_msg: db "Sector count mismatch!", 0