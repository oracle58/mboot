# mboot

Minimal Bootloader for the minos kernel.

## Quickstart
```bash
chmod +x load.sh
./load.sh
```

## Boot Sector Memory Map

| Physical Address         | Size            | Content                                                       |
|--------------------------|-----------------|---------------------------------------------------------------|
| `0x00000–0x07BFF`        | 31 KB           | BIOS data areas: IVT (0x0000–0x03FF), BDA (0x0400–0x04FF), EBDA |
| **Boot Sector**<br>`0x07C00–0x07DFF` | **512 B**       | Loaded by BIOS as the first sector of the disk                |
| `0x07C00–0x07C1F`        | 32 B            | Real-mode setup: `cli`, clear segments, set `SP`, `sti`       |
| `0x07C20–0x07C2F`        | 16 B            | Prepare & invoke EDD load: disk-packet + `int 13h/AH=0x42`     |
| `0x07C30–0x07C6F`        | 64 B            | GDT entries (`gdt_start` … `gdt_end`)                         |
| `0x07C70–0x07C77`        | 8 B             | GDT descriptor (`gdt_descriptor`)                             |
| `0x09000`                | 16 B            | Disk-address packet data (pointer into 1 MiB)                 |
| `0x07DFF`                | 1 B             | Padding up to offset 510                                      |
| `0x07FFE–0x07FFF`        | 2 B             | Boot signature (`0xAA55`)                                     |
| **Kernel**<br>`0x100000–…`   | 8 × 512 B + …  | Kernel flat binary (`_start`/`PModeMain` + `.text`, `.data`, `.bss`) |



## Build

```bash
make clean    # cleanup build and bin files
make all      # build all

make assemble # assemble bootloader
make kernel   # build kernel
make image    # build os image
```

## Emulate Bootloader/OS

```bash
# gdb debug
qemu-system-x86_64 -nographic -drive format=raw,file=./bin/os.bin -gdb tcp::1234 stdio -S

# no graphic
qemu-system-x86_64 -nographic -drive format=raw,file=./bin/boot.bin
qemu-system-x86_64 -nographic -drive format=raw,file=./bin/os.bin

# curses display
qemu-system-x86_64 -display curses -drive format=raw,file=./bin/boot.bin
qemu-system-x86_64 -display curses -drive format=raw,file=./bin/os.bin
```

## Debug
```bash
sudo pacman -Sy hexedit
sudo pacman -Sy gdb

add-symbol-file ./build/completeKernel.o 0x100000
break kmain

target remote localhost:1234
```

## Global Descriptor Table

**Source**: https://wiki.osdev.org/Global_Descriptor_Table

### Access Byte

| Bit 7 | Bits 6–5 | Bit 4 | Bit 3 | Bit 2 | Bit 1 | Bit 0 |
|:-----:|:--------:|:-----:|:-----:|:-----:|:-----:|:-----:|
|   P   |   DPL    |   S   |   E   |   DC  |   RW  |   A   |


| Field | Bit(s) | Description |
|-------|--------|-------------|
| **P** | 7      | **Present** — Must be 1 for a valid segment. |
| **DPL** | 6–5   | **Descriptor Privilege Level** — 0 = kernel (highest), 3 = user (lowest). |
| **S** | 4      | **Descriptor Type** — 0 = system segment (e.g. TSS), 1 = code/data segment. |
| **E** | 3      | **Executable** — 0 = data segment, 1 = code segment (executable). |
| **DC** | 2      | **Direction / Conforming**  
• Data: 0 = grows up, 1 = grows down.  
• Code: 0 = non-conforming (only same DPL), 1 = conforming (can be called from ≥ DPL). |
| **RW** | 1      | **Read/Write**  
• Data: 0 = read-only, 1 = writable (read always allowed).  
• Code: 0 = non-readable, 1 = readable (write never allowed). |
| **A** | 0      | **Accessed** — Set by CPU on first access; avoid trapping faults by initializing to 1 if needed. |

- Set to `10011010b`

### Flags

| Bit 3 | Bit 2 | Bit 1 | Bit 0    |
|:-----:|:-----:|:-----:|:---------|
|   G   |   DB  |   L   | Reserved |

| Flag | Bit | Description                                                                          |
|------|-----|--------------------------------------------------------------------------------------|
| G    | 3   | Granularity: 0 = limit in 1 B blocks; 1 = limit in 4 KiB blocks                     |
| DB   | 2   | Default size: 0 = 16-bit protected mode segment; 1 = 32-bit protected mode segment  |
| L    | 1   | Long-mode code: 1 = 64-bit code segment (DB must be 0); 0 = other segment types      |

- Set to `11001111b`

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

## Video mem

```c
    // VGA text buffer starts at 0xB8000
    char *video_memory = (char *)0xB8000;

    video_memory[0] = 'H';
    video_memory[1] = 0x07; 

    video_memory[2] = 'i';
    video_memory[3] = 0x07;

    video_memory[4] = '!';
    video_memory[5] = 0x07;

    video_memory[6] = ' ';
    video_memory[7] = 0x07;
```