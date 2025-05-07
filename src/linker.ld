ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 0x00100000;
    .text : { *(.text) }
    .rodata : { *(.rodata) }
    .data : { *(.data) }
    .bss : { *(.bss) }
}