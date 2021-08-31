; Blinks an LED at 1Hz

    jmp main

    include "libraries/Utilities.asm"

main:

    ldr $0,A

loop:
; Sleep for 1 second
    ldr $1,B
    jsr delay_seconds

; Toggle LED
    xor $1
    out {led_0},A

    jr loop
