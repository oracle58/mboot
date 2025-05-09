;-------------------------------------------------------------------------------
; kernel_entry.asm
; Entry point for the kernel in 32-bit protected mode.
;
; Serves as the initial entry point for the kernel after the
; bootloader. It operates in 32-bit protected mode and calls the main kernel
; initialization function.
;-------------------------------------------------------------------------------

[bits 32]                     ; Specify 32-bit protected mode

global _start                 ; Declare _start as a global symbol for the linker
[extern start_kernel]         ; Declare start_kernel as an external symbol

;-------------------------------------------------------------------------------
; Calls the start_kernel function to begin kernel initialization and enters an
; infinite loop to prevent further execution.
;-------------------------------------------------------------------------------
_start:
    call start_kernel         ; Invoke the main kernel initialization function
    jmp $                     ; Infinite loop to halt execution