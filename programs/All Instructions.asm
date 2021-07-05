    ; A simple list of all current instructions in order with distinguishable parameters.

    nop
    ldr $1,a
    ldr [$1234],b
    ldr [HL],h
    str [$4321],l
    str [HL],a
    lda $2345
    in $2,a
    out $3,b
    inc h
    dec l
    ina
    dea
    add $4
    add a
    adc $5
    adc b
    sub $6
    sub h
    sbc $7
    sbc l
    and $8
    and a
    or $9
    or b
    xor $a
    xor h
    cmp $b
    cmp l
    jmp $3456
    jmp HL
    jr $c
    jr $d,z
    jr $e,nz
    in a
    out b
    push h
    pop l
    jsr $4567
    ret
    halt
