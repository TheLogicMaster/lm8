; Blinks an LED at 1Hz

; Setup and reset timer 0 with a period of 1 second
    ldr {seconds},B
    out {timer_unit_0},B ; Set timer unit to seconds
    ldr #1,B
    out {timer_count_0},B ; Set timer period to 1 second
    out {timer_0},B ; Clear timer

loop:
    in {timer_0},B ; Check current timer value
    jr loop,Z ; Jump to loop if timer isn't triggered
    xor $1
    out {led_0},A ; Toggle LED
    out {timer_0},A ; Clear timer
    jr loop
