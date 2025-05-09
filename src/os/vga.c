/**
 * @file vga.c
 * @brief VGA text mode driver for basic terminal output.
 * @author Oliver Fohrmann
 * @date 09-may-2025
 *
 * This module provides functionality for interacting with a VGA text mode display
 * in an 80x25 character grid. It supports initializing the screen, writing individual
 * characters, and printing strings with specified colors. The VGA memory is directly
 * accessed at 0xB8000, and global cursor position tracking is maintained.
 */

#include "vga.h"

/**
 * @def VGA_WIDTH
 * @brief Width of the VGA text mode screen in characters (80 columns).
 */
#define VGA_WIDTH 80

/**
 * @def VGA_HEIGHT
 * @brief Height of the VGA text mode screen in characters (25 rows).
 */
#define VGA_HEIGHT 25

/**
 * @def VGA_MEMORY
 * @brief Pointer to the VGA text mode memory buffer starting at 0xB8000.
 *
 * A static constant pointer to the VGA memory buffer, where each entry is a
 * 16-bit value representing an ASCII character and its color attributes.
 */
static uint16_t* const VGA_MEMORY = (uint16_t*)0xB8000;

/**
 * @var vga_row
 * @brief Tracks the current row position of the cursor (0 to VGA_HEIGHT-1).
 *
 * This static variable maintains the current row for printing operations,
 * updated by vga_print to support continuous text output.
 */
static size_t vga_row = 0;

/**
 * @var vga_col
 * @brief Tracks the current column position of the cursor (0 to VGA_WIDTH-1).
 *
 * This static variable maintains the current column for printing operations,
 * updated by vga_print to support continuous text output.
 */
static size_t vga_col = 0;

/**
 * @brief Creates a VGA memory entry for a character with specified color.
 * @param c The ASCII character to display.
 * @param color The color attribute (foreground and background).
 * @return A 16-bit VGA entry combining the character and color.
 *
 * Combines an 8-bit ASCII character with an 8-bit color attribute into a
 * 16-bit value for VGA memory. The color is shifted to the high byte.
 */
static uint16_t vga_entry(char c, uint8_t color) {
    return (uint16_t)c | ((uint16_t)color << 8);
}

/**
 * @brief Initializes the VGA screen and resets the cursor position.
 *
 * Clears the VGA text mode screen by writing a space character with a black
 * background to every position in the 80x25 grid. Resets the global cursor
 * position (vga_row, vga_col) to (0, 0).
 */
void vga_init() {
    vga_row = 0;
    vga_col = 0;
    for (size_t y = 0; y < VGA_HEIGHT; y++) {
        for (size_t x = 0; x < VGA_WIDTH; x++) {
            VGA_MEMORY[y * VGA_WIDTH + x] = vga_entry(' ', VGA_COLOR_BLACK);
        }
    }
}

/**
 * @brief Writes a character to a specific position on the VGA screen.
 * @param c The ASCII character to display.
 * @param color The color attribute (foreground and background).
 * @param x The column position (0 to VGA_WIDTH-1).
 * @param y The row position (0 to VGA_HEIGHT-1).
 *
 * Places a character at the specified (x, y) coordinates in the VGA memory
 * buffer, if the coordinates are within bounds. Out-of-bounds coordinates
 * are ignored to prevent invalid memory access.
 */
void vga_putchar(char c, uint8_t color, size_t x, size_t y) {
    if (x < VGA_WIDTH && y < VGA_HEIGHT) {
        VGA_MEMORY[y * VGA_WIDTH + x] = vga_entry(c, color);
    }
}

/**
 * @brief Prints a null-terminated string to the VGA screen, updating cursor position.
 * @param str The null-terminated string to display.
 * @param color The color attribute (foreground and background).
 *
 * Prints a string starting at the current cursor position (vga_col, vga_row).
 * Handles newline characters ('\n') by advancing to the next row and resetting
 * the column. Automatically wraps to the next row if the column exceeds
 * VGA_WIDTH. Updates the global cursor position (vga_row, vga_col) after
 * printing.
 */
void vga_print(const char* str, uint8_t color) {
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
    vga_row = pos_y;
    vga_col = pos_x;
}