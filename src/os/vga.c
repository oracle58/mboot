#include "vga.h"

#define VGA_WIDTH 80
#define VGA_HEIGHT 25
static uint16_t* const VGA_MEMORY = (uint16_t*)0xB8000;

// Global cursor position
static size_t vga_row = 0;
static size_t vga_col = 0;

static uint16_t vga_entry(char c, uint8_t color) {
    return (uint16_t)c | ((uint16_t)color << 8);
}

void vga_init() {
    vga_row = 0;
    vga_col = 0;
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            VGA_MEMORY[y * VGA_WIDTH + x] = vga_entry(' ', VGA_COLOR_BLACK);
        }
    }
}

void vga_set_cursor(size_t row, size_t col) {
    vga_row = row;
    vga_col = col;
}

void vga_putchar(char c, uint8_t color, size_t x, size_t y) {
    if (x < VGA_WIDTH && y < VGA_HEIGHT) {
        VGA_MEMORY[y * VGA_WIDTH + x] = vga_entry(c, color);
    }
}

void vprint(const char* str, uint8_t color) {
    size_t pos_x = vga_col;
    size_t pos_y = vga_row;
    
    for (size_t i = 0; str[i] != '\0'; i++) {
        // Handle newline or line wrapping
        if (str[i] == '\n' || pos_x >= VGA_WIDTH) {
            pos_y++;
            pos_x = 0;
            if (str[i] == '\n') continue;
        }
        
        // Use our working vga_putchar function
        vga_putchar(str[i], color, pos_x, pos_y);
        pos_x++;
    }
    
    // Update cursor position for next print
    vga_row = pos_y;
    vga_col = pos_x;
}
