.PHONY: all assemble kernel image clean

BIN_DIR     := bin
BUILD_DIR   := build
SOURCE_DIR  := src
INCLUDE_DIR := inc

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
	i686-elf-ld -T ./src/linker.ld -o ./bin/kernel.bin $(BUILD_DIR)/kernel.asm.o ./build/kernel.o

image: assemble kernel
	cat ./bin/boot.bin ./bin/kernel.bin > ./bin/os.bin
	dd if=/dev/zero bs=512 count=8 >> ./bin/os.bin

clean:
	rm -rf $(BIN_DIR) $(BUILD_DIR)