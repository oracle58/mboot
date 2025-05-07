gdb -q \
  -ex "add-symbol-file ./build/kernel.o 0x100000" \
  -ex "break kmain" \
  -ex "target remote localhost:1234" \
  -ex "c"