; Math utilities

; Performs A mod B and stores the result in A
; Only register A is modified
modulus:
    cmp b
    jr modulus_done,c
    sub b
    jr modulus
modulus_done:
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
multiply_next:
    jr multiply_done,z
    add h
    dec b
    jr multiply_next
multiply_done:
    pop b
    pop h
    ret
