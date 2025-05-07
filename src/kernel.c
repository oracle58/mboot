#include "kernel.h"

void kmain(void) {
    volatile unsigned char *vga = (volatile unsigned char*)0xB8000;
    
    // Clear from offset 4 (after K>)
    for (int i = 2; i < 80*25; i++) {
        vga[i*2] = '.';     // Fill with dots
        vga[i*2+1] = 0x07;  // Light gray on black
    }

    // Write TEST in bright white
    const char *msg = "TEST";
    int offset = 4;  // Write after K>
    for(int i = 0; msg[i]; i++) {
        vga[offset++] = msg[i];
        vga[offset++] = 0x0F;  // Bright white
    }

    while(1) { 
        asm volatile("cli; hlt"); // Disable interrupts and halt
    }
}