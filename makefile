.PHONY: all assemble clean

## Assemble ====================
all: assemble

assemble:
	nasm -f bin ./src/boot.asm -o ./bin/boot.bin

## Clean =======================
clean:
	rm -f ./bin/boot.bin
