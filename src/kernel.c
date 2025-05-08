#include "kernel.h"

void kmain(void) {
    volatile unsigned char *vga = (volatile unsigned char*)0xB8000;
    vga[8] = 'X';    // Position 4, character
    vga[9] = 0x07;   // Attribute
    while(1) { asm volatile("cli; hlt"); }
}