; Math utilities


; Performs A mod B and stores the result in A
; Only register A is modified
modulus:
    cmp b
    jr modulus_done_,c
    sub b
    jr modulus
modulus_done_:
    ret


; Performs A divided by B and stores the result in A
divide:
    push H
    ldr $0,H
divide_loop_:
    cmp B
    jr divide_done_,C
    sub B
    inc H
    jr divide_loop_
divide_done_:
    push H
    pop A
    pop H
    ret


; Multiplies A by B and stores the result in A
; Only register A is modified
multiply:
    push h
    push b
    push a
    pop h
    ldr #0,a
    cmp b
multiply_next_:
    jr multiply_done_,z
    add h
    dec b
    jr multiply_next_
multiply_done_:
    pop b
    pop h
    ret


; Multiplies A by B and stores the 16 bit result in HL
multiply_extended:
    push A
    push B

    lda $0
    cmp $0
multiply_extended_loop_:
    jr multiply_extended_done_,Z
    push A

    push L
    pop A
    add B
    push A
    pop L
    jr multiply_extended_no_carry_,nC
    inc H
multiply_extended_no_carry_:

    pop A
    dec A
    jr multiply_extended_loop_
multiply_extended_done_:

    pop B
    pop A
    ret


; Adds unsigned A to HL
add_extended:
    push A

    add L
    jr add_extended_no_carry_,nC
    inc H
add_extended_no_carry_:
    push A
    pop L

    pop A
    ret


; Adds AB to HL
add_double_extended:
    push A

    add H
    push A
    pop H
    push B
    pop A
    add L
    push A
    pop L
    jr add_double_extended_no_carry_,nC
    inc H
add_double_extended_no_carry_:

    pop A
    ret
