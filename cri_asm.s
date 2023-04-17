.globl _start

.text
_start:
;         nop
;         # initialize registers
;         addi t1, t0, 5    # t1 = 5
;         addi t2, t0, 0    # t2 = 0
;         addi t3, t0, 10   # t3 = 10
;         # load and store instructions
;         lb t5, 0(t4)       # load byte from memory at address t4 and store in t5
;         nop
;         nop
;         nop
;         sb t5, 0(t4)       # store byte from t5 to memory at address t4

;         # conditional branch
;         bge t1, t3, label1 # if t1 >= t3, jump to label1
;         addi t2, t2, 1     # increment t2

; label1: j label2           # jump to label2
;         addi t2, t2, 1     # this instruction is skipped

; label2: jal label3         # jump to label3 and save return address in t1
;         addi t2, t2, 1     # this instruction is skipped

; label3: addi t2, t2, 1     # increment t2

;         # jump and link register
;         addi t4, t0, 20    # t4 = 20
;         jalr t1, t4, 0     # jump to address in t4 and save return address in t1
;         addi t2, t2, 1     # this instruction is skipped
;         ebreak

        # Load byte (LB) instruction example
        lb a0, 0(s0)  # Load a byte from address s0+0 into register a0
        nop
        nop
        nop

        # Store byte (SB) instruction example
        sb a1, 1(s0)  # Store a byte from register a1 into address s0+1
        nop
        nop
        nop

        # Load half-word (LH) instruction example
        lh a2, 0(s0)  # Load a half-word from address s0+0 into register a2
        nop
        nop
        nop

        # Load word (LW) instruction example
        lw a3, 0(s0)  # Load a word from address s0+0 into register a3
        nop
        nop
        nop

        # Store word (SW) instruction example
        sw a4, 4(s0)  # Store a word from register a4 into address s0+4
        nop
        nop
        nop

        # Load half-word unsigned (LHU) instruction example
        lhu a5, 0(s0)  # Load a half-word unsigned from address s0+0 into register a5
        nop
        nop
        nop

        # Store half-word unsigned (SHU) instruction example
        sh a6, 2(s0)  # Store a half-word unsigned from register a6 into address s0+2
        nop
        nop
        nop

        ebreak

.end
