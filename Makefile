.PHONY: all assemble kernel image clean

BIN_DIR     := bin
BUILD_DIR   := build
SOURCE_DIR  := src
INCLUDE_DIR := inc

FILES := $(BUILD_DIR)/kernel.asm.o $(BUILD_DIR)/kernel.o
FLAGS := -g -ffreestanding -nostdlib -nostartfiles -nodefaultlibs \
         -Wall -O0 -I$(INCLUDE_DIR) 

all: image

$(BIN_DIR) $(BUILD_DIR):
	mkdir -p $@

assemble: | $(BIN_DIR) $(BUILD_DIR)
	nasm -f bin    $(SOURCE_DIR)/boot.asm       -o $(BIN_DIR)/boot.bin
	nasm -f elf -g $(SOURCE_DIR)/kernel.asm     -o $(BUILD_DIR)/kernel.asm.o

kernel: | $(BUILD_DIR)
	i686-elf-gcc -I./src $(FLAGS) -std=gnu99 -c ./src/kernel.c -o ./build/kernel.o
	i686-elf-ld -g -relocatable $(FILES) -o ./build/completeKernel.o
	i686-elf-gcc $(FLAGS) -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/completeKernel.o

image: assemble kernel
	dd if=./$(BIN_DIR)/boot.bin >> ./bin/os.bin
	dd if=./$(BIN_DIR)/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=8 >> ./bin/os.bin

clean:
	rm -rf $(BIN_DIR) $(BUILD_DIR)
