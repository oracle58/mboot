#include "kernel.h"

void kmain(void) {
    volatile unsigned int *vga = (volatile unsigned int*)0xB8000;

    vga[0] = 0x047B044B;  // "K>" in red (0x04)
    vga[1] = 0x0C580C58;  // "XX" in bright red

    while (1) {
        __asm__ volatile("cli; hlt");
    }
}