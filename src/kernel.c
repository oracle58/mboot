#include "kernel.h"

void kmain(void) {
    volatile unsigned char *vid = (unsigned char*)0xB8000;
    vid[0] = 'H'; vid[1] = 0x1E;
    vid[2] = 'i'; vid[3] = 0x1E;
    vid[4] = '!'; vid[5] = 0x1E;
    for (;;) asm volatile("hlt");
}
