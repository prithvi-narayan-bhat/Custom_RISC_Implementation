.globl _start

.text
_start:
    # Initialize registers t1, t2, t3, and t4 to specific values
    # Use the jal instruction to jump to label1 and save the return address in register t1
    # After etecuting the code at label1, use the jalr instruction to jump to the address stored in register t4 and save the return address in register t1
    # Next, use the beq instruction to conditionally jump to label2 if registers t1 and t0 are equal
    # Use the bne instruction to conditionally jump to label3 if registers t1 and t3 are not equal
    # Use the bgt instruction to conditionally jump to label4 if register t1 is greater than register t3
    # Use the bge instruction to conditionally jump to label5 if register t1 is greater than or equal to register t3
    # Increment register t2 in each case where a jump is taken, and skip over the instruction that would have incremented t2 in cases where a jump is not taken
    nop
    # initialize registers
    addi    t1, t0, 5       # t1 = 5
    addi    t2, t0, 0       # t2 = 0
    addi    t3, t0, 10      # t3 = 10
    addi    t4, t0, 20      # t4 = 20

    # jump and link
    jal     label1          # jump to label1 and save return address in t1
    addi    t2, t2, 1       # this instruction is skipped

    label1:
    addi    t2, t2, 1       # increment t2

    # jump and link register
    bge     t1, t3, label5  # if t1 >= t3, jump to label5
    addi    t2, t2, 1       # this instruction is skipped

    # conditional branch
    beq     t1, t0, label2  # if t1 == t0, jump to label2
    addi    t2, t2, 1       # increment t2

    label2:                 # conditional branch
    bne     t1, t3, label3  # if t1 != t3, jump to label3
    addi    t2, t2, 1       # this instruction is skipped

    label3:                 # conditional branch
    bgt     t1, t3, label4  # if t1 > t3, jump to label4
    addi    t2, t2, 1       # this instruction is skipped

    label4:                 # conditional branch
    jalr    t1, t4, 0       # jump to address in t4 and save return address in t1
    addi    t2, t2, 1       # this instruction is skipped

    label5:                 # Etit condition
    ebreak

.end
