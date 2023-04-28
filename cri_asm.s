.globl _start

.text
# define addresses for LED tnd push button
.equ PUSH_BUTTON_ADDR, 0x80000000
.equ LED_ADDR, 0x80000004

_start:
        nop
        nop
        ADDI    t1, zero, 0x200
	ADDI    t2, zero, 0x20
	SB  	 t2, 1(t1) 
	ADDI    t2, zero, 1010
	SH      t2, 12(t1)
	LUI     t2, 0x12345
	ADDI    t2, t2, 0x678
	SW	 t2, 4(t1)
	ADDI	 t2, zero, -40
	SB      t2, 22(t1)
	LB      t3, 1(t1)
	LH      t4, 12(t1)
	LB      t6, 22(t1)
	LW      t5, 4(t1)
        ebreak

.end
