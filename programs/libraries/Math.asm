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


; Compares AB to HL
cmp_double_extended:
    push A
    push B
    push H
    push L

; Test for carry
    cmp H
    jr cmp_double_extended_carry_ext_,C
    jr cmp_double_extended_no_carry_,nZ
    push A
    push B
    pop A
    cmp L
    pop A
    jr cmp_double_extended_carry_ext_,C
    jr cmp_double_extended_no_carry_
cmp_double_extended_carry_ext_:
    jmp cmp_double_extended_carry_
cmp_double_extended_no_carry_:
; No carry
    push A
    push B
    push H
    push L
    push A
    push B
    push H
    push L
    pop B
    pop A
    pop L
    pop H
    jsr sub_double_extended
    push H
    pop A
    cmp $0
    pop L
    pop H
    pop B
    pop A
    jr cmp_double_extended_not_carry_neg_,N
; No carry, not negative
    cmp $0
    jr cmp_double_extended_not_carry_not_neg_not_over_,nN
    push A
    push H
    pop A
    cmp $0
    pop A
    jr cmp_double_extended_not_carry_not_neg_not_over_,nN
; No carry, not negative, overflow
    push A
    ldr $80,A
    str [math_carry_1],A
    ldr $80,A
    str [math_carry_2],A
    pop A
    jr cmp_double_extended_not_carry_not_neg_not_over_adjust_zero_
cmp_double_extended_not_carry_not_neg_not_over_:
; No carry, not negative, no overflow
    push A
    ldr $00,A
    str [math_carry_1],A
    ldr $00,A
    str [math_carry_2],A
    pop A
cmp_double_extended_not_carry_not_neg_not_over_adjust_zero_:
    push A
    push B
    push H
    push L
    push A
    push B
    push H
    push L
    pop B
    pop A
    pop L
    pop H
    jsr sub_double_extended
    push A
    push H
    pop A
    cmp $0
    pop A
    jr cmp_double_extended_not_carry_not_neg_not_over_not_zero_,nZ
    push A
    push L
    pop A
    cmp $0
    pop A
    jr cmp_double_extended_not_carry_not_neg_not_over_not_zero_,nZ
    pop L
    pop H
    pop B
    pop A
    jr cmp_double_extended_done_
cmp_double_extended_not_carry_not_neg_not_over_not_zero_:
    pop L
    pop H
    pop B
    pop A
; Add one to first operand if not zero
    ldr [math_carry_1],A
    inc A
    str [math_carry_1],A
    jr cmp_double_extended_done_
cmp_double_extended_not_carry_neg_:
; No carry, negative
    ldr $80,A
    str [math_carry_1],A
    ldr $00,A
    str [math_carry_2],A
    jr cmp_double_extended_done_
cmp_double_extended_carry_:
; Carry
    push A
    push B
    push H
    push L
    push A
    push B
    push H
    push L
    pop B
    pop A
    pop L
    pop H
    jsr sub_double_extended
    push H
    pop A
    cmp $0
    pop L
    pop H
    pop B
    pop A
    jr cmp_double_extended_carry_neg_,N
; Carry, not negative
    ldr $00,A
    str [math_carry_1],A
    ldr $C0,A
    str [math_carry_2],A
    jr cmp_double_extended_done_
cmp_double_extended_carry_neg_:
; Carry, negative
    cmp $0
    jr cmp_double_extended_carry_neg_not_over_,N
    push A
    push H
    pop A
    cmp $0
    pop A
    jr cmp_double_extended_carry_neg_not_over_,N
; Carry, negative, overflow
    ldr $FE,A
    str [math_carry_1],A
    ldr $FF,A
    str [math_carry_2],A
    jr cmp_double_extended_done_
cmp_double_extended_carry_neg_not_over_:
; Carry, negative, no overflow
    ldr $7F,A
    str [math_carry_1],A
    ldr $80,A
    str [math_carry_2],A
cmp_double_extended_done_:
; Set flags
    ldr [math_carry_1],A
    ldr [math_carry_2],B
    cmp B

    pop L
    pop H
    pop B
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


; Subtracts AB from HL
sub_double_extended:
    push A

    push A
    push H
    pop A
    pop H
    sub H
    push A
    pop H
    push L
    pop A
    sub B
    push A
    pop L
    jr sub_double_extended_no_carry_,nC
    dec H
sub_double_extended_no_carry_:

    pop A
    ret


; Shifts AB left by L
shift_left_extended:
    push L

shift_left_extended_loop_:
    dec L
    jr shift_left_extended_done_,C
    push A
    push B
    pop A
    lsl
    push A
    pop B
    pop A
    jr shift_left_extended_carry_,C
    lsl
    jr shift_left_extended_loop_
shift_left_extended_carry_:
    lsl
    or $01
    jr shift_left_extended_loop_
shift_left_extended_done_:

    pop L
    ret


; Shifts AB right by L
shift_right_extended:
    push L

shift_right_extended_loop_:
    dec L
    jr shift_right_extended_done_,C
    lsr
    jr shift_right_extended_carry,C
    push A
    push B
    pop A
    lsr
    push A
    pop B
    pop A
    jr shift_right_extended_loop_
shift_right_extended_carry:
    push A
    push B
    pop A
    lsr
    or $80
    push A
    pop B
    pop A
    jr shift_right_extended_loop_
shift_right_extended_done_:

    pop L
    ret


; Stores the resulting sign from multiplying or dividing AB by HL and makes them unsigned
; Use to put signed numbers into 15-bit unsigned forms
setup_mul_div_parameters:
    push A
    push B
    and $80
    push A
    push H
    pop A
    and $80
    push A
    pop B
    pop A
    xor B
    str [mul_div_sign_],A
    pop B
    push H
    pop A
    and $80
    jr setup_mul_div_parameters_H_pos_,Z
    push H
    pop A
    xor $FF
    push A
    pop H
    push L
    pop A
    xor $FF
    push A
    pop L
    ina
setup_mul_div_parameters_H_pos_:
    pop A
    push A
    and $80
    pop A
    jr setup_mul_div_parameters_A_pos_,Z
    push H
    push L
    xor $FF
    push A
    push B
    pop A
    xor $FF
    push A
    pop L
    pop H
    ina
    push H
    pop A
    push L
    pop B
    pop L
    pop H
setup_mul_div_parameters_A_pos_:
    ret


; Sets the sign of HL based on the last call to get_multiplication_sign
adjust_mul_div_result:
    push A
    push B
    push H
    pop A
    ldr [mul_div_sign_],B
    or B
    push A
    pop H
    pop B
    pop A
    ret


; Multiplies AB by HL and store the result in HL
multiply_double_extended:
    push A
    ldr $0,A
    str [math_temp_h_],A
    str [math_temp_l_],A
    pop A
multiply_double_extended_loop_:
    push H
    push L
    ldr [math_temp_h_],H
    ldr [math_temp_l_],L
    jsr add_double_extended
    str [math_temp_h_],H
    str [math_temp_l_],L
    pop L
    pop H
    dea
    push A
    ldr $0,A
    cmp H
    pop A
    jr multiply_double_extended_loop_,nZ
    push A
    ldr $0,A
    cmp L
    pop A
    jr multiply_double_extended_loop_,nZ
    ldr [math_temp_h_],H
    ldr [math_temp_l_],L
    ret


; Multiplies signed AB by signed HL and store the result in HL
multiply_double_extended_signed:
    jsr setup_mul_div_parameters
    jsr multiply_double_extended
    jsr adjust_mul_div_result
    ret


; Divides AB by HL and store the result in HL
divide_double_extended:
    push A
    push B

    push A
    ldr $0,A
    str [math_temp_h_],A
    str [math_temp_l_],A
    pop A
divide_double_extended_loop_:
    jsr cmp_double_extended
    jr divide_double_extended_done_,C
    push A
    push B
    push H
    push L
    pop B
    pop A
    pop L
    pop H
    jsr sub_double_extended
    push A
    push B
    push H
    push L
    pop B
    pop A
    ldr [math_temp_h_],H
    ldr [math_temp_l_],L
    ina
    str [math_temp_h_],H
    str [math_temp_l_],L
    pop L
    pop H
    jr divide_double_extended_loop_
divide_double_extended_done_:

    pop B
    pop A
    ldr [math_temp_h_],H
    ldr [math_temp_l_],L
    ret


; Divides signed AB by signed HL and store the signed result in HL
divide_double_extended_signed:
    jsr setup_mul_div_parameters
    jsr divide_double_extended
    jsr adjust_mul_div_result
    ret


; Performs AB mod HL and store the result in HL
modulus_double_extended:
    push A
    push B

modulus_double_extended_loop_:
    jsr cmp_double_extended
    jr modulus_double_extended_done_,C
    push A
    push B
    push H
    push L
    pop B
    pop A
    pop L
    pop H
    jsr sub_double_extended
    push A
    push B
    push H
    push L
    pop B
    pop A
    pop L
    pop H
    jr modulus_double_extended_loop_
modulus_double_extended_done_:
    push A
    pop H
    push B
    pop L

    pop B
    pop A
    ret


; Performs unsigned AB mod unsigned HL and store the result in HL
modulus_double_extended_signed:
    push A
    push B

    push A
    push B
    jsr setup_mul_div_parameters
    jsr modulus_double_extended
    pop B
    pop A
    and $80
    push A
    push H
    pop A
    and $80
    push A
    pop B
    pop A
    xor B
    jr modulus_double_extended_signed_positive_,Z
    push H
    pop A
    xor $FF
    push A
    pop H
    push L
    pop A
    xor $FF
    push A
    pop L
    ina
modulus_double_extended_signed_positive_:

    pop B
    pop A
    ret


data
    math_temp_h_: var
    math_temp_l_: var
    mul_div_sign_: var
    math_carry_1: var
    math_carry_2: var
