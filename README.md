# mboot

This repository contains a minimal x86 bootloader and a simple protected-mode kernel. The bootloader loads the kernel from disk into memory, sets up a basic GDT, switches the CPU to 32-bit protected mode, and jumps to the kernel's entry point. 

## Build
```bash
# dependencies
sudo pacman -S base-devel gcc nasm qemu 

# build
make clean && make all 
# run the image using qemu
make run 
```

## Boot Sector Memory Map

| Physical Address         | Size            | Content                                                       |
|--------------------------|-----------------|---------------------------------------------------------------|
| `0x00000–0x07BFF`        | 31 KB           | BIOS data areas: IVT, BDA, EBDA                               |
| **Boot Sector**<br>`0x07C00–0x07DFF` | **512 B**       | Loaded by BIOS as the first sector of the disk (MBR)          |
| `0x07C00–...`            | ...             | Bootloader code: sets up stack, loads kernel, sets up GDT     |
| `0x07C00–...`            | ...             | Includes GDT, GDT descriptor, and real-mode to protected-mode switch |
| `0x07DFF`                | 1 B             | Padding up to offset 510                                      |
| `0x07FFE–0x07FFF`        | 2 B             | Boot signature (`0xAA55`)                                     |
| **Kernel**<br>`0x1000–…`     | 2 × 512 B + …  | Kernel flat binary (entry: `_start`/`start_kernel`)           |


## Global Descriptor Table

**Source**: https://wiki.osdev.org/Global_Descriptor_Table

### Access Byte

| Bit 7 | Bits 6–5 | Bit 4 | Bit 3 | Bit 2 | Bit 1 | Bit 0 |
|:-----:|:--------:|:-----:|:-----:|:-----:|:-----:|:-----:|
|   P   |   DPL    |   S   |   E   |   DC  |   RW  |   A   |


| Field   | Bit(s) | Description                                                                                                                                                            |
|---------|--------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **P**   | 7      | **Present** — Must be 1 for a valid segment.                                                                                                                           |
| **DPL** | 6–5    | **Descriptor Privilege Level** — 0 = kernel (highest), 3 = user (lowest).                                                                                              |
| **S**   | 4      | **Descriptor Type** — 0 = system segment (e.g. TSS), 1 = code/data segment.                                                                                            |
| **E**   | 3      | **Executable** — 0 = data segment, 1 = code segment (executable).                                                                                                      |
| **DC**  | 2      | **Direction/Conforming** — For data segments: 0 = grows up, 1 = grows down; for code segments: 0 = non-conforming (only same DPL), 1 = conforming (callable from ≥ DPL). |
| **RW**  | 1      | **Read/Write** — For data segments: 0 = read-only, 1 = writable; for code segments: 0 = non-readable, 1 = readable.                                                     |
| **A**   | 0      | **Accessed** — Set by the CPU on first access; initialize to 1 if needed to avoid a fault on first access.                                                           |



### Flags

| Bit 3 | Bit 2 | Bit 1 | Bit 0    |
|:-----:|:-----:|:-----:|:---------|
|   G   |   DB  |   L   | Reserved |

| Flag | Bit | Description                                                                          |
|------|-----|--------------------------------------------------------------------------------------|
| G    | 3   | Granularity: 0 = limit in 1 B blocks; 1 = limit in 4 KiB blocks                     |
| DB   | 2   | Default size: 0 = 16-bit protected mode segment; 1 = 32-bit protected mode segment  |
| L    | 1   | Long-mode code: 1 = 64-bit code segment (DB must be 0); 0 = other segment types      |


## BIOS Common functions
**source**: https://wiki.osdev.org/BIOS

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

