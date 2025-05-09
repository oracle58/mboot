;-------------------------------------------------------------------------------
; @file gdt.asm
; @brief Sets up a basic GDT with null, code, and data segment descriptors
; to enable protected mode operation. The GDT defines segment properties such
; as base address, size, and access permissions for the CPU.
;-------------------------------------------------------------------------------

; Null segment descriptor
; A mandatory 64-bit zeroed descriptor required by the CPU to initialize the GDT.
gdt_start:
    dq 0x0

; Code segment descriptor
; Defines a 32-bit code segment with execute/read permissions, covering the full
; 4GB address space (base 0x0, limit 0xffffffff).
gdt_code:
    dw 0xffff    ; Limit (bits 0-15): Lower 16 bits of segment size
    dw 0x0       ; Base (bits 0-15): Lower 16 bits of segment base address
    db 0x0       ; Base (bits 16-23): Middle 8 bits of segment base address
    db 10011010b ; Access byte: Present(1), Priv(00), Type(1), Code(1), Conforming(0), Readable(1), Accessed(0)
    db 11001111b ; Flags/Limit: Granularity(1), 32-bit(1), 64-bit(0), AVL(0), Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31): Upper 8 bits of segment base address

; Data segment descriptor
; Defines a 32-bit data segment with read/write permissions, covering the full
; 4GB address space (base 0x0, limit 0xffffffff).
gdt_data:
    dw 0xffff    ; Limit (bits 0-15): Lower 16 bits of segment size
    dw 0x0       ; Base (bits 0-15): Lower 16 bits of segment base address
    db 0x0       ; Base (bits 16-23): Middle 8 bits of segment base address
    db 10010010b ; Access byte: Present(1), Priv(00), Type(1), Code(0), Expand-down(0), Writable(1), Accessed(0)
    db 11001111b ; Flags/Limit: Granularity(1), 32-bit(1), 64-bit(0), AVL(0), Limit (bits 16-19)
    db 0x0       ; Base (bits 24-31): Upper 8 bits of segment base address

; Marks the end of the GDT entries
gdt_end:

; GDT descriptor structure
; Provides the size and starting address of the GDT for loading into the GDTR register.
gdt_descriptor:
    dw gdt_end - gdt_start - 1 ; Size: GDT size in bytes minus 1 (16-bit)
    dd gdt_start               ; Address: 32-bit linear address of gdt_start

; Segment selector offsets
; Defines constants for the code and data segment selectors relative to gdt_start.
; These are used to load segment registers (CS, DS, etc.) in protected mode.
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start