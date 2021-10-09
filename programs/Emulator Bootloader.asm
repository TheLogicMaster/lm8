; Emulator Bootloader --- A hacked together emulator compatible bootloader for programs to run in memory

    lda program
    push H
    pop A
    push L
    pop B

    lda $8000
copy:
    push A

    push H
    push L

    push A
    pop H
    push B
    pop L
    ldr [HL],A

    pop L
    pop H
    str [HL],A
    ina

    pop A

; Increment AB
    push H
    push L
    push A
    pop H
    push B
    pop L
    ina
    push H
    pop A
    push L
    pop B
    pop L
    pop H

    push A
    ldr $00,A
    cmp L
    pop A
    jr copy,nZ
    push A
    ldr $C0,A
    cmp H
    pop A
    jr copy,nZ

; Use variable jump to trigger emulator disassembler
    lda $8000
    jmp HL

program: bin "build/test.img"
