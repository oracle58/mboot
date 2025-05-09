#include "vga.h"

void start_kernel() {
    vga_init();
    
    // reset cursor to top lef
    extern void vga_set_cursor(size_t row, size_t col);
    vga_set_cursor(0, 0);

    vprint("Kernel loaded", VGA_COLOR_LIGHT_GREY);
    vprint(" OK", VGA_COLOR_LIGHT_GREEN);
}