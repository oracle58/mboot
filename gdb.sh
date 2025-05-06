gdb -q \
  -ex "add-symbol-file ./build/completeKernel.o 0x100000" \
  -ex "break kmain" \
  -ex "target remote localhost:1234" \
  -ex "c"