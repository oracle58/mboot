#include "kernel.h"

static inline void disable_vga_caching(void) {
    // Disable caching for VGA memory (0xB8000 - 0xBFFFF)
    asm volatile (
        "movl $0x200, %%ecx\n"        // IA32_MTRR_DEF_TYPE MSR
        "rdmsr\n"
        "andl $~0x800, %%eax\n"       // Clear E (enable MTRRs)
        "wrmsr\n"

        "movl $0x250, %%ecx\n"        // IA32_MTRR_PHYSBASE0 MSR
        "movl $0xB8000, %%eax\n"      // Base address
        "movl $0x0, %%edx\n"          // Type: Uncacheable
        "wrmsr\n"

        "movl $0x258, %%ecx\n"        // IA32_MTRR_PHYSMASK0 MSR
        "movl $0xFFFFF800, %%eax\n"   // Mask (4 KiB granularity)
        "movl $0x800, %%edx\n"        // Valid bit
        "wrmsr\n"

        "movl $0x200, %%ecx\n"        // IA32_MTRR_DEF_TYPE MSR
        "rdmsr\n"
        "orl $0x800, %%eax\n"         // Set E (enable MTRRs)
        "wrmsr\n"
        :
        :
        : "eax", "ebx", "ecx", "edx"
    );
}

void kmain(void) {
    volatile unsigned int *vga = (volatile unsigned int*)0xB8000;

    // Disable caching for VGA memory
    disable_vga_caching();

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