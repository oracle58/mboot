# $@ = target file
# $< = first dependency
# $^ = all dependencies

TARGET      := i386
BIN_DIR     := targets/$(TARGET)/bin
BUILD_DIR   := targets/$(TARGET)/build
SOURCE_DIR  := src

all: $(BIN_DIR)/os.bin

# Ensure output directories exist
$(BIN_DIR) $(BUILD_DIR):
	mkdir -p $@

$(BIN_DIR)/kernel.bin: $(BUILD_DIR)/kernel_entry.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/vga.o | $(BIN_DIR)
	ld -m elf_i386 -o $@ -T /home/oracle/mboot/linker.ld $^ --oformat binary -nostdlib

$(BUILD_DIR)/kernel_entry.o: $(SOURCE_DIR)/kernel_entry.asm | $(BUILD_DIR)
	nasm $< -f elf -o $@

$(BUILD_DIR)/kernel.o: $(SOURCE_DIR)/kernel.c | $(BUILD_DIR)
	gcc -m32 -O0 -g -ffreestanding -fno-pic -fno-pie -nostdlib -nostartfiles -nodefaultlibs -c $< -o $@

$(BUILD_DIR)/vga.o: $(SOURCE_DIR)/vga.c $(SOURCE_DIR)/vga.h | $(BUILD_DIR)
	gcc -m32 -O0 -g -ffreestanding -fno-pic -fno-pie -nostdlib -nostartfiles -nodefaultlibs -c $< -o $@

$(BIN_DIR)/mbr.bin: $(SOURCE_DIR)/mbr.asm $(SOURCE_DIR)/disk_load.asm $(SOURCE_DIR)/gdt.asm $(SOURCE_DIR)/main32.asm | $(BIN_DIR)
	nasm $< -f bin -o $@ -I$(SOURCE_DIR)/

$(BIN_DIR)/os.bin: $(BIN_DIR)/mbr.bin $(BIN_DIR)/kernel.bin | $(BIN_DIR)
	cat $^ > $@

run: $(BIN_DIR)/os.bin
	qemu-system-i386 -display curses -hda  $<

clean:
	$(RM) $(BIN_DIR)/*.bin $(BUILD_DIR)/*.o *.bin *.o *.dis

.PHONY: all run clean