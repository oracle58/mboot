;-------------------------------------------------------------------------------
; disk_load.asm
; BIOS disk reading routine for loading sectors from a disk.
; 
; Provides a function to read sectors from a disk using BIOS interrupt
; 0x13. It loads specified sectors into a memory buffer and includes a utility
; function for printing error messages to the screen.
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;  Loads sectors from a disk into memory using BIOS interrupt 0x13.
;  dh Number of sectors to read.
;  dl Drive number (set by caller).
;  es:bx Buffer address to store the read data (set by caller).
;
; Reads the specified number of sectors starting from sector 2 (after the boot
; sector) on cylinder 0, head 0. Preserves all registers and returns on success.
;-------------------------------------------------------------------------------
disk_load:
    pusha                    ; Save all general-purpose registers
    push dx                  ; Save dx (contains number of sectors and drive number)

    mov ah, 0x02             ; BIOS function: Read sectors
    mov al, dh               ; Number of sectors to read (from dh)
    mov cl, 0x02             ; Start reading from sector 2 (sector 1 is boot sector)
    mov ch, 0x00             ; Use cylinder 0
    mov Dh, 0x00             ; Use head 0

    ; dl = drive number (set by caller)
    ; es:bx = buffer pointer (set by caller)

    int 0x13                 ; Call BIOS disk read interrupt
    jc disk_error_msg        ; Jump to error handler if carry flag is set

    pop dx                   ; Restore dx to get original number of sectors
    cmp al, dh               ; Compare sectors read (al) with requested (dh)
    jne sectors_error_msg    ; Jump to error handler if mismatch
    popa                     ; Restore all general-purpose registers
    ret                      ; Return to caller

;-------------------------------------------------------------------------------
; Prints a null-terminated error message to the screen using BIOS.
; si Pointer to the null-terminated string to print.
;
; Iteratively prints each character of the string using BIOS interrupt 0x10
; until a null terminator is encountered. Preserves registers except those
; required for BIOS calls.
;-------------------------------------------------------------------------------
print_error:
    lodsb                    ; Load next byte from si into al, increment si
    or al, al                ; Check if al is zero (null terminator)
    jz .done                 ; If null, finish printing
    mov ah, 0x0e             ; BIOS function: Teletype output
    mov bh, 0x00             ; Page number 0
    int 0x10                 ; Call BIOS video interrupt to print character
    jmp print_error          ; Repeat for next character
.done:
    ret                      ; Return to caller

;-------------------------------------------------------------------------------
; Error message strings for disk read failures.
;-------------------------------------------------------------------------------
disk_error_msg: db "Disk read error!", 0
sectors_error_msg: db "Sector count mismatch!", 0