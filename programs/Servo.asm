; Servo test --- A worse version of the Arduino sweep example

; Set servo pin (Arduino 3) to output mode
    ldr $3,B
    out {arduino_output},B

; Setup timer 0 for 20ms cycles
    ldr {milliseconds},A
    out {timer_unit_0},A
    ldr #20,A
    out {timer_count_0},A

; Setup timer 1 for pulse
    ldr {centimilliseconds},A
    out {timer_unit_1},A

loop:
; Reset timer 0
    out {timer_0},B

; Set Servo pin high
    ldr $1,B
    out {arduino_3},B

; Wait for pulse length
    out {timer_count_1},A
    out {timer_1},B
pulse:
    in {timer_1},B
    jr pulse,Z

; Set Servo pin low
    ldr $0,B
    out {arduino_3},B

; Wait for next cycle
finish_cycle:
    in {timer_0},B
    jr finish_cycle,Z

    inc A
    cmp #250
    jr not_reset,nZ
    ldr #50,A
not_reset:

    jr loop