.globl _start

.text
# define addresses for LED tnd push button
.equ PUSH_BUTTON_ADDR, 0x80000000
.equ LED_ADDR, 0x80000004

_start:
        addi    t3, t3, 512
        addi    t5, t5, 0
        addi    t4, t4, 0

        lui     t2, %hi(LED_ADDR)               # Load the upper bits of address of KEY into t0
        addi    t2, t2, 4                       # Load the offset of LEDs into t2

        lui     t0, %hi(PUSH_BUTTON_ADDR)       # Load the upper bits of address of KEY into t0
        # addi    t0, t0, 0                       # Load the offset of KEY into t0

loop:   lw      t1, 0(t0)                       # Load the state of KEY to t1

        nop
        nop
        nop

        beq     t1, t4, jump                    # Branch on equal
        j       exi                             # Unconditional jump

jump:   sw      t3, 0(t2)                       # Store value into LEDs
        nop
        nop
        nop
        j       loop                            # Unconditional jump

exi:    sw      t5, 0(t2)                       # Update LEDs
        ebreak

.end
