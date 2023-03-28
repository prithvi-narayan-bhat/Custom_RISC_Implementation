.globl _start

.text

_start:

    ADDI    t1, t1, 10
    ADDI    t0, t0, 11
    ADD     t0, t0, t1
    ADD     t2, t1, t0
    ADD     t0, t1, t2

    EBREAK

.end
