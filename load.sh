#!/usr/bin/env bash
set -e

# Parse -g flag for graphics
GFX=0
while getopts "g" opt; do
  case "$opt" in
    g) GFX=1 ;;
    *) echo "Usage: $0 [-g]"; exit 1 ;;
  esac
done

make clean && make all

COMMON_ARGS=(
  -drive file=./bin/os.bin,format=raw,if=ide,index=0,media=disk
)

if [[ $GFX -eq 1 ]]; then
  echo "Starting with graphics (curses)…"
  qemu-system-i386 "${COMMON_ARGS[@]}" -display curses
else
  echo "Starting in nographics mode…"
  qemu-system-i386 "${COMMON_ARGS[@]}" -nographic
fi
