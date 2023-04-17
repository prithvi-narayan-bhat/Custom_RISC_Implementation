.globl _start

.text
_start:
        nop
        # Store byte (SB) instruction example
        addi    t1, t1, 40      # Load 40 into register t1
        sb      t1, 0(t1)       # Store a byte from register t1 into address s0

        nop
        nop
        nop

        # Load byte (LB) instruction example
        lb      t2, 0(t1)       # Load a byte from address s0+0 into register a0

        nop
        nop
        nop
        ebreak

.end
