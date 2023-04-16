.globl _start

.text
_start:
        nop
        # initialize registers
        addi t1, t0, 5    # t1 = 5
        addi t2, t0, 0    # t2 = 0
        addi t3, t0, 10   # t3 = 10

        # conditional branch
        bge t1, t3, label1 # if t1 >= t3, jump to label1
        addi t2, t2, 1     # increment t2

label1: j label2           # jump to label2
        addi t2, t2, 1     # this instruction is skipped

label2: jal label3         # jump to label3 and save return address in t1
        addi t2, t2, 1     # this instruction is skipped

label3: addi t2, t2, 1     # increment t2

        # jump and link register
        addi t4, t0, 20    # t4 = 20
        jalr t1, t4, 0     # jump to address in t4 and save return address in t1
        addi t2, t2, 1     # this instruction is skipped

        # load and store instructions
        lb t5, 0(t4)       # load byte from memory at address t4 and store in t5
        sb t5, 0(t4)       # store byte from t5 to memory at address t4
        ebreak

.end
