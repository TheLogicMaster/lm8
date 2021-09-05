; PCA9685 --- I2C PWM expander
; Based on: https://github.com/adafruit/Adafruit-PWM-Servo-Driver-Library/blob/master/Adafruit_PWMServoDriver.cpp

    include "I2C.asm"
    include "Math.asm"


; Resets the PCA9685
; Uses timer 1 for a 10 ms delay
pwm_expander_reset:
    push A
    push B

    ldr $80,A ; Mode 1 reset bit
    ldr $0,B ; Mode 1 register address
    jsr pwm_expander_write_byte

    ; 10 ms delay
    ldr {milliseconds},B
    out {timer_unit_1},B
    ldr #10,B
    out {timer_count_1},B
    out {timer_1},B
pwm_expander_reset_delay_:
    in {timer_1},B
    jr pwm_expander_reset_delay_,Z

    pop B
    pop A
    ret


; Sets the PWM expander prescale value A between 3 and 255 (inclusive)
; Uses timer 1 for a 5 ms delay
; Prescaler equation: prescale = oscillator_freq / (target_freq * 4096.0)
pwm_expander_set_prescaler:
    push A
    push B
    push H

    push A
    pop H

; Get current mode
    ldr $0,B ; Mode 1 register address
    jsr pwm_expander_read_byte
    push A

; Sleep
    and $7F ; Clear reset bit
    or $10 ; Set sleep bit
    ldr $0,B ; Mode 1 register address
    jsr pwm_expander_write_byte

; Set prescaler
    push H
    pop A
    ldr $FE,B ; Prescale address
    jsr pwm_expander_write_byte

; Restore previous mode
    pop A
    ldr $0,B ; Mode 1 register address
    jsr pwm_expander_write_byte

; 5 ms delay
    ldr {milliseconds},B
    out {timer_unit_1},B
    ldr #5,B
    out {timer_count_1},B
    out {timer_1},B
pwm_expander_set_prescaler_delay_:
    in {timer_1},B
    jr pwm_expander_set_prescaler_delay_,Z

; Turn on auto-increment
    or $80 ; Set restart bit
    or $20 ; Set auto-increment bit
    ldr $0,B ; Mode 1 register address
    jsr pwm_expander_write_byte

    pop H
    pop B
    pop A
    ret


; Sets the PWM duty cycle of pin A to B
; Uses 8-bit precision rather than 12-bit precision for convenience
; Pulse length equation: length = 1 / frequency / 255 * duty
pwm_expander_set_pin:
    push A
    push B

; Start transmission
    push A
    ldr [pwm_expander_addr],A
    jsr i2c_start_write
    pop A

; Send address
    push B
    ldr #4,B
    jsr multiply
    add $06 ; Start address of PWM on/off ticks
    push A
    pop B
    jsr i2c_send_byte
    pop B

; Send on/off tick data
    push B
    pop A
    cmp $FF
    jr pwm_expander_set_pin_not_full_on_,nZ
    ldr $00,B
    jsr i2c_send_byte
    ldr $10,B
    jsr i2c_send_byte
    ldr $00,B
    jsr i2c_send_byte
    jsr i2c_send_byte
    jr pwm_expander_set_pin_done_
pwm_expander_set_pin_not_full_on_:
    cmp $0
    jr pwm_expander_set_pin_not_full_off_,nZ
    ldr $00,B
    jsr i2c_send_byte
    jsr i2c_send_byte
    jsr i2c_send_byte
    ldr $10,B
    jsr i2c_send_byte
    jr pwm_expander_set_pin_done_
pwm_expander_set_pin_not_full_off_:
    ldr $00,B
    jsr i2c_send_byte
    jsr i2c_send_byte
    push A
    lsl
    lsl
    lsl
    lsl
    push A
    pop B
    jsr i2c_send_byte
    pop A
    lsr
    lsr
    lsr
    lsr
    push A
    pop B
    jsr i2c_send_byte
pwm_expander_set_pin_done_:

; End transmission
    jsr i2c_stop

    pop B
    pop A
    ret


; Reads a byte from expander's address in B into A
pwm_expander_read_byte:
    push B

    ldr [pwm_expander_addr],A
    jsr i2c_start_write
    jsr i2c_send_byte
    jsr i2c_stop
    jsr i2c_start_read
    ldr $0,B
    jsr i2c_receive_byte
    jsr i2c_stop

    pop B
    ret


; Writes a byte in A to expander's address in B
pwm_expander_write_byte:
    push A
    push B

    push A
    ldr [pwm_expander_addr],A
    jsr i2c_start_write
    jsr i2c_send_byte
    pop B
    jsr i2c_send_byte
    jsr i2c_stop

    pop B
    pop A
    ret


    data
; The address of the PWM expander
pwm_expander_addr: var
