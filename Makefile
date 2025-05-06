.PHONY: all assemble kernel image clean

BIN_DIR     := bin
BUILD_DIR   := build
SOURCE_DIR  := src
INCLUDE_DIR := inc

FILES := $(BUILD_DIR)/kernel.asm.o $(BUILD_DIR)/kernel.o
FLAGS := -g -ffreestanding -nostdlib -nostartfiles -nodefaultlibs \
         -Wall -O0 -I$(INCLUDE_DIR) -fno-pic -fno-pie

all: image

$(BIN_DIR) $(BUILD_DIR):
	mkdir -p $@

assemble: | $(BIN_DIR) $(BUILD_DIR)
	nasm -f bin    $(SOURCE_DIR)/boot.asm       -o $(BIN_DIR)/boot.bin
	nasm -f elf32  -g $(SOURCE_DIR)/kernel.asm  -o $(BUILD_DIR)/kernel.asm.o

kernel: | $(BUILD_DIR)
	# compile C with the i686-elf cross-compiler
	i686-elf-gcc $(FLAGS) -std=gnu99 \
	  -c $(SOURCE_DIR)/kernel.c \
	  -o $(BUILD_DIR)/kernel.o

	# glue into one relocatable object
	i686-elf-ld -r $(FILES) \
	  -o $(BUILD_DIR)/completeKernel.o

	# link to flat binary using your custom linker script
	i686-elf-gcc $(FLAGS) \
	  -T $(SOURCE_DIR)/linker.ld \
	  -o $(BUILD_DIR)/kernel.elf \
	  $(BUILD_DIR)/completeKernel.o

	# final kernel image
	cp $(BUILD_DIR)/kernel.elf $(BIN_DIR)/kernel.bin

image: assemble kernel
	# build the final OS image
	cat $(BIN_DIR)/boot.bin $(BIN_DIR)/kernel.bin > $(BIN_DIR)/os.bin
	dd if=/dev/zero bs=512 count=8 >> $(BIN_DIR)/os.bin

clean:
	rm -rf $(BIN_DIR) $(BUILD_DIR)
