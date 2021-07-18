; This is a test of the emulator's static/dynamic disassembler functionality

    nop
    ldr $1,a
    ldr [$1234],b
    ldr [HL],h
    str [$4321],l
    str [HL],a
    lda $2345
    in $2,h
    out $3,b
    inc h
    dec l
    jmp label0
    ina
    dea


label0:
    add $4
    add a
    adc $5
    adc b
    ldr #1,a
    jr label0,z
    add $4
    add a
    ldr #0,a
    jr label0,nz
    adc $5
    adc b
    jr label1
    adc $5
    adc b

label1:
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
    in a
    out b
    push h
    pop l
    jsr label2
    lda $80
    jmp HL

label2:
    sub $6
    sub h
    sbc $7
    sbc l
    ret
    adc $5
    adc b

    org $80
label3:
    or $9
    or b
    xor $a
    xor h
    halt