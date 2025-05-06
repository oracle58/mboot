# mboot

Minimal Bootloader for the minos kernel.

## Assemble

```bash
make all
```

## Emulate

```bash
# no graphic
qemu-system-x86_64 -nographic -drive format=raw,file=./bin/boot.bin

# legacy drive shorthand (uses default GUI)
qemu-system-x86_64 -hda ./bin/boot.bin

# curses display
qemu-system-x86_64 -display curses -drive format=raw,file=./bin/boot.bin
```

## Boot Sector Memory Map

Address      | Data
-------------|-----------
0x0000       | (Data segment, cleared)
0x7C00       | Stack and code loaded here
0x7C06       | Pointer to 'Hello World!' message
0x7C10       | 'Hello World!', 0 
0x7C1B       | 0x00 (end of message)
0x7DFE - 0x7DFF | 0x55AA (boot signature at end of 512-byte sector)

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