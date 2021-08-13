; Ultrasonic sensor test --- Measures the distance and outputs the number of decimillis to HEX0
; Doesn't work yet

    ldr $2,H
    out {gpio_output},H

; Setup timer 0 for 10 microseconds
    ldr {microseconds},A
    out {timer_unit_0},A
    ldr $10,A
    out {timer_count_0},A

; Setup timer 1 for measuring echo and timeout
    ldr {decimilliseconds},A
    out {timer_unit_1},A

loop:
; Set Trigger high
    ldr $1,A
    out {arduino_2},A

; 10 microsecond delay
    out {timer_0},A
trigger_delay:
    in {timer_0},A
    jr trigger_delay,Z

; Set Trigger low
    ldr $0,A
    out {arduino_2},A

; Wait for Echo start
    ldr $FF,A
    out {timer_count_1},A
    out {timer_1},A
echo_start:
    in {timer_1},A
    jr loop,nZ
    in {arduino_3},A
    jr echo_start,Z

; Measure Echo time in B
    ldr $1,A
    out {timer_count_1},A
    ldr $0,B
measure:
    out {timer_1},A
measure_wait:
    in {timer_1},A
    jr measure_wait,Z
    inc B
    in {arduino_3},A
    jr measure,Z

; Output to HEX0
    out {seven_segment_0},B

    jmp loop

    halt
