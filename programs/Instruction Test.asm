; Tests all non-I/O instruction behavior

    jmp main

failed_text: db "Test failed\n", $0
success_text: db "All tests passed!\n", $0
test_bytes: db $1, $2, $3, $4

main:
; Test 1 --- Load instructions
    ; Todo: Check flags changed
    ldr #1,A
    str [test],A
    ldr $AA,A
    cmp $AA
    jr failed_0,nZ
    ldr [test_bytes],A
    cmp $1
    jr failed_0,nZ
    lda test_bytes
    ldr [HL],A
    cmp $1
    jr failed_0,nZ

; Test 2 --- Store instructions
    ldr #2,A
    str [test],A
    ldr $AA,A
    str [temp],A
    ldr [temp],A
    cmp $AA
    jr failed_0,nZ
    lda temp
    str [HL],A
    ldr [temp],A
    cmp $AA
    jr failed_0,nZ

; Test 3 --- Incremental instructions
    ; Todo: Check flags changed
    ldr #3,A
    str [test],A
    ldr $0,A
    inc A
    cmp $1
    jr failed_0,nZ
    dec A
    cmp $0
    jr failed_0,nZ
    lda test_bytes
    ina
    ina
    ldr [HL],A
    cmp $3
    jr failed_0,nZ
    dea
    ldr [HL],A
    cmp $2
    jr failed_0,nZ

; Test 4 --- Stack instructions
    ldr #4,A
    str [test],A
; Ensure FIFO behavior
    ldr $AA,A
    ldr $BB,B
    push A
    push B
    pop A
    cmp $BB
    jr failed_0,nZ
    pop A
    cmp $AA
    jr failed_0,nZ

; Relay for conditional relative jumps
    jr main_1
failed_0:
    jmp failed
main_1:

; Test 5 --- Addition instructions
    ldr #5,A
    str [test],A
    ldr $1,B
; Ensure unsigned carry
    ldr $FF,A
    add $1
    jr failed_1,nZ
    jr failed_1,nC
    jr failed_1,N
    jr failed_1,V
; Ensure signed overflow
    ldr #126,A
    adc B
    jr failed_1,Z
    jr failed_1,C
    jr failed_1,nN
    jr failed_1,nV

; Test 6 --- Subtraction instructions
    ldr #6,A
    str [test],A
    ldr $1,B
; Ensure zero flag
    ldr $1,A
    sub $1
    jr failed_1,nZ
    jr failed_1,C
    jr failed_1,N
    jr failed_1,V
; Ensure unsigned carry
    sub B
    jr failed_1,Z
    jr failed_1,nC
    jr failed_1,nN
    jr failed_1,nV
; Ensure signed overflow
    ldr #129,A
    sbc $1
    jr failed_1,Z
    jr failed_1,C
    jr failed_1,N
    jr failed_1,V
; Ensure CMP doesn't modify A
    cmp #127
    cmp #127
    jr failed_1,nZ

; Test 7 --- Bitwise instructions
    ldr #7,A
    str [test],A
; Ensure zero flag and imm/reg behavior
    ldr $0,B
    ldr $F,A
    and B
    jr failed_1,nZ
    ldr $FF,A
    and $F0
    jr failed_1,Z
    cmp $F0
    jr failed_1,nZ
; Test OR
    or $F
    cmp $FF
    jr failed_1,nZ
; Test XOR
    xor $F0
    cmp $F
    jr failed_1,nZ

; Test 8 --- Subroutine instructions
    ldr #8,A
    str [test],A
    jsr subroutine
    jr failed_1,nZ

; Relay for conditional relative jumps
    jr main_2
failed_1:
    jmp failed
main_2:

; Test 9 --- Variable jumps
    ldr #9,A
    str [test],A
    lda var_jump_target
    jmp HL
    jr failed
var_jump_target:

; Test 10 --- Shift operations
    ldr #10,A
    str [test],A
; Test LSL
    ldr %11010100,A
    lsl
    jr failed,nC
    jr failed,Z
    cmp %10101000
    jr failed,nZ
; Test LSR
    ldr %00101011,A
    lsr
    jr failed,nC
    jr failed,Z
    cmp %00010101
    jr failed,nZ
; Test ASR
    ldr %10101011,A
    asr
    jr failed,nC
    jr failed,Z
    cmp %11010101
    jr failed,nZ
    ldr %00101011,A
    asr
    jr failed,nC
    jr failed,Z
    cmp %00010101
    jr failed,nZ


; End of tests
    ldr =success_text,A
    out {print_string},A
    halt

; Prints the test failed message and outputs the test ID to HEX0
failed:
    ldr [test],A
    out {seven_segment_0},A
    ldr =failed_text,A
    out {print_string},A
    ldr $1,A
    out {led_0},A
    halt

; Sets the Zero flag and returns
subroutine:
    cmp A
    ret
    jr failed

    data
test: var
temp: var