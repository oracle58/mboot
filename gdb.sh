gdb -q \
  -ex "add-symbol-file ./build/kernel.o 0x100000" \
  -ex "break kmain" \
  -ex "break kernel.c:14" \
  -ex "break kernel.c:17" \
  -ex "break kernel.c:18" \
  -ex "break kernel.c:26" \
  -ex "break kernel.c:27" \
  -ex "target remote localhost:1234" \
  -ex "c"