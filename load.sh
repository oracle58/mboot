#!/usr/bin/env bash
set -e

make clean
make all
qemu-system-x86_64 -nographic -drive format=raw,file=./bin/os.bin
