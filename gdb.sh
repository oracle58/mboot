gdb -q --batch \
    -ex "set pagination off" \
    -ex "set architecture i386:intel" \
    -ex "target remote localhost:1234" \
    -ex "add-symbol-file ./build/kernel.o 0x100000" \
    -ex 'echo "\nMemory at 0x7E00 (kernel source):\n"' \
    -ex "x/32b 0x7E00" \
    -ex 'echo "\nMemory at 0x100000 (kernel destination):\n"' \
    -ex "x/32b 0x100000" \
    -ex "break *0x100000" \
    -ex "break kmain" \
    -ex "c" \
    -ex "x/8x 0xb8000" \
    -ex "info registers" \
  > gdb.log 2>&1