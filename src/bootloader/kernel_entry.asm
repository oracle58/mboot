[bits 32]
global _start
[extern start_kernel]

_start:
    call start_kernel
    jmp $