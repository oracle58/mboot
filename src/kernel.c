// src/kernel.c
#include "kernel.h"

// I/O for debug port 0xE9
static inline void outb(unsigned short port, unsigned char val) {
    asm volatile("outb %0, %1" : : "a"(val), "Nd"(port));
}

// Tiny delay (to let curses hook up the console)
static void delay(void) {
    for (volatile unsigned long i = 0; i < 1000000; i++);
}

void kmain(void) {
    delay();

    // 1) VGA text at 0xB8000 (visible under -display curses)
    volatile unsigned char *vid = (unsigned char *)0xB8000;
    const char *msg = "Hi!";
    for (int i = 0; msg[i]; i++) {
        vid[i*2 + 0] = msg[i];
        vid[i*2 + 1] = 0x1E;  // yellow on blue
    }

    // 2) 0xE9 debug port (visible under -nographic)
    outb(0xE9, 'H');
    outb(0xE9, 'i');
    outb(0xE9, '!');

    // hang
    for (;;) asm volatile("hlt");
}
