/**
 * @file main.c
 * @brief Kernel entry point for system initialization.
 * @author Oliver Fohrmann
 * @date 09-may-2025
 * Provides the main entry point for the kernel, currently initializing the VGA display
 * and printing a basic status message.
 */

#include "vga.h"

/**
 * @brief Initializes the kernel and displays a startup message.
 *
 * Calls vga_init to clear the screen and prints a "Kernel Loaded OK" message
 * using vga_print with specified colors.
 */
void start_kernel(void) {
    vga_init();
    vga_print("Kernel Loaded", VGA_COLOR_LIGHT_GREY);
    vga_print(" OK", VGA_COLOR_LIGHT_GREEN);
}