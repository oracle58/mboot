#!/usr/bin/env bash
set -e

make clean && make all
qemu-system-x86_64 \
  -drive file=./bin/os.bin,format=raw,if=ide,index=0,media=disk \
  -display curses
