; Servo Wave --- Example using a PCA9685 I2C PWM expander to control 12 servos in a "wave" motion

jmp main

    include "libraries/PCA9685.asm"


main:
    ldr $40,A
    str [pwm_expander_addr],A

; Reset expander
    jsr pwm_expander_reset

; Set prescaler to produce ~60 Hz for servo control
    ldr #122,A
    jsr pwm_expander_set_prescaler

; Setup timer 0 for 200 ms delay
    ldr {milliseconds},B
    out {timer_unit_0},B
    ldr #200,B
    out {timer_count_0},B

; Set initial PWM duty cycle
; Assuming servo accepts 600 to 2400 microsecond pulse length range for full range of motion
; For those pulse lengths, the duty cycle value range is from 9 to 37 at 60 Hz
    ldr #9,B


loop:

; Set servo values on all 12 channels
    ldr #0,A
set_servos:
    jsr pwm_expander_set_pin

; 200 ms delay
    out {timer_0},H
delay:
    in {timer_0},H
    jr delay,Z

    inc A
    cmp #12
    jr set_servos,nZ

; Flip servo direction
    ldr #9,A
    cmp B
    jr flip_9,Z
    ldr #9,B
    jr flip_done
flip_9:
    ldr #37,B
flip_done:

    jmp loop
