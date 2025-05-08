#include "kernel.h"

void kmain(void) {
    volatile unsigned int *vga = (volatile unsigned int*)0xB8000;

    // Debug: Write directly to VGA memory to confirm kmain execution
    vga[2] = 0x2F4D2F4D;  // "MM" in green on black

    // Clear screen first (80x25 characters)
    for (int i = 0; i < (80 * 25) / 2; i++) {
        vga[i] = 0x07200720; // Space with gray on black
    }

    // Write "K>" in red on black to be distinct from bootloader
    vga[0] = 0x047B044B;  // "K>" in red (0x04)

    // Add test pattern after
    vga[1] = 0x0C580C58;  // "XX" in bright red

    while (1) {
        __asm__ volatile("cli; hlt");
    }
}