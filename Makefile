TARGET      := x86
BIN_DIR     := targets/$(TARGET)/bin
BUILD_DIR   := targets/$(TARGET)/build
SOURCE_DIR  := src
BOOT_DIR    := $(SOURCE_DIR)/boot
KERNEL_DIR  := $(SOURCE_DIR)/kernel

all: $(BIN_DIR)/os.bin

# Ensure output directories exist
$(BIN_DIR) $(BUILD_DIR):
	mkdir -p $@

$(BIN_DIR)/main.bin: $(BUILD_DIR)/kernel_entry.o $(BUILD_DIR)/main.o $(BUILD_DIR)/vga.o | $(BIN_DIR)
	ld -m elf_i386 -o $@ -T /home/oracle/mboot/linker.ld $^ --oformat binary -nostdlib

$(BUILD_DIR)/kernel_entry.o: $(BOOT_DIR)/kernel_entry.asm | $(BUILD_DIR)
	nasm $< -f elf -o $@

$(BUILD_DIR)/main.o: $(KERNEL_DIR)/main.c | $(BUILD_DIR)
	gcc -m32 -O0 -g -ffreestanding -fno-pic -fno-pie -nostdlib -nostartfiles -nodefaultlibs -c $< -o $@

$(BUILD_DIR)/vga.o: $(KERNEL_DIR)/vga.c $(KERNEL_DIR)/vga.h | $(BUILD_DIR)
	gcc -m32 -O0 -g -ffreestanding -fno-pic -fno-pie -nostdlib -nostartfiles -nodefaultlibs -c $< -o $@

$(BIN_DIR)/mbr.bin: $(BOOT_DIR)/mbr.asm $(BOOT_DIR)/disk_load.asm $(BOOT_DIR)/gdt.asm $(BOOT_DIR)/switch_pm.asm | $(BIN_DIR)
	nasm $< -f bin -o $@ -I$(BOOT_DIR)/

$(BIN_DIR)/os.bin: $(BIN_DIR)/mbr.bin $(BIN_DIR)/main.bin | $(BIN_DIR)
	cat $^ > $@

run: $(BIN_DIR)/os.bin
	qemu-system-i386 -display curses -hda  $<

clean:
	$(RM) $(BIN_DIR)/*.bin $(BUILD_DIR)/*.o *.bin *.o *.dis

.PHONY: all run clean
