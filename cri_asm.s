.globl _start

.text

_start:

        addi    t0, t0, 1         # Load the value 1 into register t0
        addi    t1, t1, 3         # Load the value 10 into register t1
jump:   bne     t1, t0, branch    # Branch to the "branch" label if t1 is equal to 0
        add     t1, t1, 1         # Increment t1 by 1
        jal     end               # Jump to the "end" label

branch:
    addi   t1, t1, -1         # Decrement t1 by 1
    jal    jump

end:
    ebreak                    # Exit the program

.end
