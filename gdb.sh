#!/bin/bash

echo "GDB debug log saved to gdb_debug.log"

gdb -q --batch \
    -ex "set pagination off" \
    -ex "set architecture i386:intel" \
    -ex "target remote localhost:1234" \
    -ex "add-symbol-file ./build/kernel.o 0x100000" \
    -ex 'echo "\n==== Boot Sector (0x7C00) ====\n"' \
    -ex "x/64bx 0x7C00" \
    -ex 'echo "\n==== Memory at Kernel Entry (0x100000) ====\n"' \
    -ex "x/32bx 0x100000" \
    -ex 'echo "\n==== VGA Memory (0xB8000) ====\n"' \
    -ex "x/32bx 0xB8000" \
    -ex 'echo "\n==== Setting Breakpoints ====\n"' \
    -ex "break *0x100000" \
    -ex "break kmain" \
    -ex "info breakpoints" \
    -ex 'echo "\n==== Continuing Execution ====\n"' \
    -ex "c" \
    -ex "x/32bx 0xB8000" \
    -ex 'echo "\n==== VGA Memory After Execution ====\n"' \
    -ex "x/32bx 0xB8000" \
    -ex 'echo "\n==== CPU Registers ====\n"' \
    -ex "info registers" \
  | tee gdb_debug.log