; RC Car --- Control an RC car using a Nunchuk controller to drive a dual H-bridge such as L298N.
; Uses arduino pins 7-10 for controlling the H-bridge

    jmp main

    include "libraries/Nunchuk.asm"


main:
    jsr nunchuck_init

    ldr #7,A
    out {arduino_output},A
    ldr #8,A
    out {arduino_output},A
    ldr #9,A
    out {arduino_output},A
    ldr #10,A
    out {arduino_output},A


loop:
    jsr nunchuck_update

    ldr [nunchuck_joystick_x],A
    cmp $A0
    jr not_turn_right,C
    ldr $1,A
    out {arduino_7},A
    ldr $0,A
    out {arduino_8},A
    out {arduino_9},A
    ldr $1,A
    out {arduino_10},A
    jmp loop
not_turn_right:
    ldr [nunchuck_joystick_x],B
    ldr $60,A
    cmp B
    jr not_turn_left,C
    ldr $0,A
    out {arduino_7},A
    ldr $1,A
    out {arduino_8},A
    out {arduino_9},A
    ldr $0,A
    out {arduino_10},A
    jmp loop
not_turn_left:
    ldr [nunchuck_joystick_y],A
    cmp $A0
    jr not_drive_forward,C
    ldr $1,A
    out {arduino_7},A
    ldr $0,A
    out {arduino_8},A
    ldr $1,A
    out {arduino_9},A
    ldr $0,A
    out {arduino_10},A
    jmp loop
not_drive_forward:
    ldr [nunchuck_joystick_y],B
    ldr $60,A
    cmp B
    jr not_drive_reverse,C
    ldr $0,A
    out {arduino_7},A
    ldr $1,A
    out {arduino_8},A
    ldr $0,A
    out {arduino_9},A
    ldr $1,A
    out {arduino_10},A
    jmp loop
not_drive_reverse:
    ldr $0,A
    out {arduino_7},A
    out {arduino_8},A
    out {arduino_9},A
    out {arduino_10},A
    jmp loop
