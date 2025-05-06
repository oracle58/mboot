.PHONY: all assemble kernel image clean

BIN_DIR    := bin
BUILD_DIR  := build
SOURCE_DIR := src
INCLUDE_DIR := inc

FILES := $(BUILD_DIR)/kernel.asm.o $(BUILD_DIR)/kernel.o
FLAGS := -m32 -g -ffreestanding -nostdlib -nostartfiles -nodefaultlibs \
         -Wall -O0 -I$(INCLUDE_DIR) -fno-pic -fno-pie

all: image

$(BIN_DIR) $(BUILD_DIR):
	mkdir -p $@

assemble: | $(BIN_DIR) $(BUILD_DIR)
	nasm -f bin $(SOURCE_DIR)/boot.asm -o $(BIN_DIR)/boot.bin
	nasm -f elf32 -g $(SOURCE_DIR)/kernel.asm -o $(BUILD_DIR)/kernel.asm.o

kernel: | $(BUILD_DIR)
	gcc $(FLAGS) -std=gnu99 -c $(SOURCE_DIR)/kernel.c -o $(BUILD_DIR)/kernel.o
	ld -m elf_i386 -g -r $(FILES) -o $(BUILD_DIR)/completeKernel.o
	gcc $(FLAGS) -T ./linker.ld \
	    -o $(BIN_DIR)/kernel.bin $(BUILD_DIR)/completeKernel.o

image: assemble kernel
	cat $(BIN_DIR)/boot.bin $(BIN_DIR)/kernel.bin > $(BIN_DIR)/os.bin
	dd if=/dev/zero bs=512 count=8 >> $(BIN_DIR)/os.bin

clean:
	rm -rf $(BIN_DIR) $(BUILD_DIR)
