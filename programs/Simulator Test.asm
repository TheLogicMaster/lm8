; Simulator Test

; Load and store operations
    ldr $FF,A
    str [var0],A
    ldr [var0],B
    ldr $EE,A
    lda var0
    ina
    str [HL],A
    ldr [HL],B
    dea
    ldr [HL],A

; Arithmatic opertions
    inc A
    inc B
    inc H
    inc L
    dec A
    ina
    dea
    add $FF
    add B
    adc $1
    adc H
    sub $1
    sub L
    sbc $1
    sbc A
    and $3
    and H
    or $4
    or B
    xor $F
    xor A
    cmp $0
    inc A
    cmp A

; Branching and subroutines
label0:
    jmp label1
    halt
label1:
    lda label2
    jmp HL
    halt
label2:
    ldr $0,A
    jr label5,nZ
    jr label3,Z
    halt
label3:
    ldr $1,A
    jr label5,Z
    jr label4,nZ
    halt
label4:
    jsr label6
    jr label7
    halt
label5:
    halt
label6:
    ret
    halt
label7:

; Stack functionality
    ldr $FF,A
    ldr $EE,B
    push A
    push B
    pop A
    pop B

; Port instructions
    in {rand},A
    out {seven_segment_0},A
    ldr {rand},A
    in H
    ldr {seven_segment_1},A
    out H

    halt

    data
var0: var
var1: var
