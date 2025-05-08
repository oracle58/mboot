gdb -q \
  -ex "set architecture i386:intel"\
  -ex "target remote localhost:1234" \
  -ex "add-symbol-file ./build/kernel.o 0x100000" \
  -ex "break kmain" \
  -ex "break kernel.c:6" \
  -ex "break kernel.c:7" \
  -ex "c"