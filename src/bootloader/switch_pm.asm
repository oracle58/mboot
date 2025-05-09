;-------------------------------------------------------------------------------
; switch_pm.asm
; Transitions the CPU from 16-bit real mode to 32-bit protected mode.
; This module handles the switch from 16-bit real mode to 32-bit protected mode
; by configuring the Global Descriptor Table (GDT), enabling protected mode,
; and setting up segment registers and the stack. It concludes by calling the
; 32-bit entry point defined in another module.
;-------------------------------------------------------------------------------

[bits 16]
;-------------------------------------------------------------------------------
; Initiates the switch from 16-bit real mode to 32-bit protected mode.
;
; Disables interrupts, loads the GDT, enables protected mode via CR0, and
; performs a far jump to initialize 32-bit segment registers.
;-------------------------------------------------------------------------------
switch_to_32bit:
    cli                     ; 1. Disable interrupts to prevent interference
    lgdt [gdt_descriptor]   ; 2. Load the Global Descriptor Table descriptor
    mov eax, cr0
    or eax, 0x1             ; 3. Set protected mode bit (bit 0) in CR0
    mov cr0, eax
    jmp CODE_SEG:init_32bit ; 4. Far jump to 32-bit code segment to flush pipeline

[bits 32]
;-------------------------------------------------------------------------------
; Initializes 32-bit protected mode environment.
;
; Updates segment registers to use the data segment selector, sets up the stack
; at a safe memory location, and calls the 32-bit entry point.
;-------------------------------------------------------------------------------
init_32bit:
    mov ax, DATA_SEG        ; 5. Set all segment registers to data segment selector
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000        ; 6. Initialize stack base pointer at 0x90000
    mov esp, ebp            ;     Set stack pointer to base (stack grows downward)

    call BEGIN_32BIT        ; 7. Call the 32-bit entry point defined in mbr.asm