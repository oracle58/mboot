#include "kernel.h"

void kmain(){
    // VGA text buffer starts at 0xB8000
    char *video_memory = (char *)0xB8000;

    // Write 'H', 'i', '!', ' ' directly to screen
    video_memory[0] = 'H';
    video_memory[1] = 0x07; // Light grey text on black background

    video_memory[2] = 'i';
    video_memory[3] = 0x07;

    video_memory[4] = '!';
    video_memory[5] = 0x07;

    video_memory[6] = ' ';
    video_memory[7] = 0x07;
}
