#!/bin/bash

echo "Compiling now.."

if [ $# -le 1 ];
then
    echo "compiling now.."
    riscv32-unknown-elf-gcc -o cri_asm cri_asm.s -ffreestanding -nostdlib -march=rv32i -mabi=ilp32

    riscv32-unknown-elf-objdump -dr cri_asm > cri_asm.asm_dump

    riscv32-unknown-elf-objcopy cri_asm -O binary cri_asm.bin

    hexdump cri_asm.bin

    riscv32-unknown-elf-gcc -o cri_asm cri_asm.s -march=rv32i -mabi=ilp32 -nostdlib -T/home/prithvi/Documents/Academics/Semester-II/CSE-6351/Labs/Lab1/Part-1/cse4372_riscv.ld

    objcopy -O ihex cri_asm cri_asm.hex

    /home/prithvi/Documents/Academics/Semester-II/CSE-6351/Labs/Lab1/Part-1/hex_intel_to_quartis cri_asm.hex ram.hex

    riscv32-unknown-elf-objdump -dr cri_asm
else
    echo "Insufficient args"
fi
