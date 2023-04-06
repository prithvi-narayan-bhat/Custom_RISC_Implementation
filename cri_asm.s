.globl _start

.text

_start:
;         nop
;         addi    t0, t0, 1         # Load the value 1 into register t0
;         addi    t1, t1, 3         # Load the value 10 into register t1
; jump:   bne     t1, t0, branch    # Branch to the "branch" label if t1 is equal to 0
;         add     t1, t1, 1         # Increment t1 by 1
;         jal     end               # Jump to the "end" label

; branch:
;     addi   t1, t1, -1         # Decrement t1 by 1
;     jal    jump

; end:
;     ebreak                    # Etit the program


# initialize registers
    addi t1, t0, 5    # t1 = 5
    addi t2, t0, 0    # t2 = 0
    addi t3, t0, 10   # t3 = 10

    # conditional branch
    bge t1, t3, label1 # if t1 >= t3, jump to label1
    addi t2, t2, 1     # increment t2

label1:
    # unconditional jump
    j label2           # jump to label2
    addi t2, t2, 1     # this instruction is skipped

label2:
    # jump and link
    jal label3         # jump to label3 and save return address in t1
    addi t2, t2, 1     # this instruction is skipped

label3:
    addi t2, t2, 1     # increment t2

    # jump and link register
    addi t4, t0, 20    # t4 = 20
    jalr t1, t4, 0     # jump to address in t4 and save return address in t1
    addi t2, t2, 1     # this instruction is skipped

.end
