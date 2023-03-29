.globl _start

.text

_start:

    addi t0, t0, 1
    addi t1, t1, 6
    add  t2, t1, t0
    add  t3, t2, t0
    add  t4, t2, t1
    add  t5, t2, t2

    EBREAK

.end
