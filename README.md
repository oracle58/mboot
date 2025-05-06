# mboot

Minimal Bootloader for the minos kernel.

## Compile

```shell
nasm -f bin boot.asm -o boot.bin
```

## Run

```shell
qemu-system-x86_64 -hda ./boot.bin
```

### QMP

```shell
qemu-system-x86_64 \
  -drive format=raw,file=boot.bin \
  -S \
  -qmp tcp:127.0.0.1:4444,server=on,wait=off \
  -chardev socket,id=mon0,host=127.0.0.1,port=4445,server=on,wait=off \
  -mon chardev=mon0,mode=control \
  -nographic

qemu-system-x86_64 \
  -drive format=raw,file=boot.bin \
  -S \
  -qmp tcp:127.0.0.1:4444,server=on,wait=off \
  -nographic
```

## Notes

Address      | Data
-------------|-----------
0x0000       | (Data segment, cleared)
0x7C00       | Stack and code loaded here
0x7C06       | Pointer to 'Hello World!' message
0x7C10       | 'Hello World!', 0 
0x7C1B       | 0x00 (end of message)
0x7DFE - 0x7DFF | 0x55AA (boot signature at end of 512-byte sector)

## Resources

[**BIOS Common Functions**](https://wiki.osdev.org/BIOS)

* `INT 0x10, AH = 1` -- set up the cursor
* `INT 0x10, AH = 3` -- cursor position
* `INT 0x10, AH = 0xE` -- display char
* `INT 0x10, AH = 0xF` -- get video page and mode
* `INT 0x10, AH = 0x11` -- set 8x8 font
* `INT 0x10, AH = 0x12` -- detect EGA/VGA
* `INT 0x10, AH = 0x13` -- display string
* `INT 0x10, AH = 0x1200` -- Alternate print screen
* `INT 0x10, AH = 0x1201` -- turn off cursor emulation
* `INT 0x10, AX = 0x4F00` -- video memory size
* `INT 0x10, AX = 0x4F01` -- VESA get mode information call
* `INT 0x10, AX = 0x4F02` -- select VESA video modes
* `INT 0x10, AX = 0x4F0A` -- VESA 2.0 protected mode interface