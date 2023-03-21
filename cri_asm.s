.globl _start

.text

_start:

    ADDI    t0, t0, 12

    ADDI    zero,zero,0    # NOP
    ADDI    zero,zero,0    # NOP
    ADDI    zero,zero,0    # NOP

    ADDI    t1, t1, 18

    ADDI    zero,zero,0    # NOP
    ADDI    zero,zero,0    # NOP
    ADDI    zero,zero,0    # NOP

    ADD     t2, t1, t0

    EBREAK

.end
