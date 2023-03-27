#!/bin/bash

echo "Compiling now.."

if [ $# -eq 1 ];
then
    echo "compiling now.."
    riscv32-unknown-elf-gcc -o $1 $1.s -ffreestanding -nostdlib -march=rv32i -mabi=ilp32

    riscv32-unknown-elf-objdump -dr $1 > $1.asm_dump

    riscv32-unknown-elf-objcopy $1 -O binary $1.bin

    hexdump $1.bin

    riscv32-unknown-elf-gcc -o $1 $1.s -march=rv32i -mabi=ilp32 -nostdlib -T/home/prithvi/Documents/Academics/Semester-II/CSE-6351/Labs/Lab1/Part-1/cse4372_riscv.ld

    objcopy -O ihex $1 $1.hex

    /home/prithvi/Documents/Academics/Semester-II/CSE-6351/Labs/Lab1/Part-1/hex_intel_to_quartis $1.hex ram.hex

    riscv32-unknown-elf-objdump -dr $1
else
    echo "Insufficient args"
fi
