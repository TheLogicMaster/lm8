; LED Dimmer --- Dims an LED on arduino pin 3

; Enable PWM on LED pin
    ldr #3,A
    out {arduino_output},A
    out {pwm_enable},A

; Set a ~50% duty cycle for half brightness
    ldr $80,A
    out {pwm_3},A

; Infinite loop to maintain PWM in emulator
loop:
    jr loop
