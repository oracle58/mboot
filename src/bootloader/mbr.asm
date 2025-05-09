;-------------------------------------------------------------------------------
; mbr.asm
; Master Boot Record (MBR) bootloader for loading and starting a kernel.
; 
; 16-bit bootloader that runs from the MBR at 0x7c00.
; It loads a kernel from disk into memory, switches to 32-bit protected mode,
; and transfers control to the kernel. The bootloader is designed to fit within
; the 512-byte MBR, including the magic number 0xAA55.
;-------------------------------------------------------------------------------

[bits 16]
[org 0x7c00]              ; Set origin to 0x7c00, where BIOS loads the MBR

;-------------------------------------------------------------------------------
; KERNEL_OFFSET
; Memory address where the kernel is loaded (0x1000).
;-------------------------------------------------------------------------------
KERNEL_OFFSET equ 0x1000

; BIOS sets boot drive in 'dl'; store for later use
mov [BOOT_DRIVE], dl      ; Save boot drive number provided by BIOS in dl

; setup stack
mov bp, 0x9000            ; Set base pointer to 0x9000 for stack
mov sp, bp                ; Initialize stack pointer to base (stack grows downward)

call load_kernel          ; Load the kernel from disk into memory
call switch_to_32bit      ; Transition to 32-bit protected mode

jmp $                     ; Infinite loop to halt execution if control returns

%include "disk_load.asm"  ; Include disk loading routine
%include "gdt.asm"        ; Include Global Descriptor Table definitions
%include "switch_pm.asm"  ; Include protected mode switch routine

;-------------------------------------------------------------------------------
; Loads the kernel from disk into memory.
;
; Configures parameters for disk_load to read 2 sectors from the boot drive
; into KERNEL_OFFSET (0x1000) and calls the disk loading routine.
;-------------------------------------------------------------------------------
[bits 16]
load_kernel:
    mov bx, KERNEL_OFFSET ; Set bx to destination address (0x1000)
    mov dh, 2             ; Set dh to number of sectors to read (2)
    mov dl, [BOOT_DRIVE]  ; Set dl to boot drive number
    call disk_load        ; Call disk loading routine
    ret                   ; Return to caller

;-------------------------------------------------------------------------------
; Entry point after switching to 32-bit protected mode.
;
; Transfers control to the kernel loaded at KERNEL_OFFSET and enters an infinite
; loop if the kernel returns.
;-------------------------------------------------------------------------------
[bits 32]
BEGIN_32BIT:
    call KERNEL_OFFSET    ; Call the kernel entry point at 0x1000
    jmp $                 ; Infinite loop to halt if kernel returns

;-------------------------------------------------------------------------------
; Stores the boot drive number provided by BIOS.
;-------------------------------------------------------------------------------
BOOT_DRIVE db 0

;-------------------------------------------------------------------------------
; Padding and boot signature
; Pads the remaining space to 510 bytes and adds the bootable magic number 0xAA55.
;-------------------------------------------------------------------------------
times 510 - ($-$$) db 0   ; Pad with zeros up to 510 bytes
dw 0xaa55                 ; Boot sector magic number