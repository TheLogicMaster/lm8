; Nunchuck --- Provides support for Wii remote peripherals like the Nunchuck over I2C

    include "I2C.asm"
    include "Utilities.asm"


; Initialize the connected nunchuck
nunchuck_init:
    push A
    push B

    ldr $52,A ; Nunchuck address

    jsr i2c_start_write
    ldr $F0,B
    jsr i2c_send_byte
    ldr $55,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $FB,B
    jsr i2c_send_byte
    ldr $00,B
    jsr i2c_send_byte
    jsr i2c_stop

    pop B
    pop A
    ret


; Retreives data from nunchuck
; Uses delays
nunchuck_update:
    push A
    push B
    push H
    push L

; Set read address to 0
    ldr $52,A ; Nunchuck address
    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    jsr i2c_stop

    ldr #1,B
    jsr delay_milliseconds

; Read 6 bytes
    jsr i2c_start_read
    ldr #5,B
    lda nunchuck_data_0_
nunchuck_update_loop_:
    jsr i2c_receive_byte
    str [HL],A
    ina
    dec B
    jr nunchuck_update_loop_,nC
    jsr i2c_stop

    pop L
    pop H
    pop B
    pop A
    ret


; Retrieves the current nunchuck C button state in A
; Sets Zero flag based on state
nunchuck_get_c_button:
    ldr [nunchuck_data_5_],A
    lsr
    and $1
    xor $1
    ret


; Retrieves the current nunchuck Z button state in A
; Sets Zero flag based on state
nunchuck_get_z_button:
    ldr [nunchuck_data_5_],A
    and $1
    xor $1
    ret


    data
nunchuck_data_0_:
; The joystick X value
nunchuck_joystick_x: var
nunchuck_data_1_:
; The joystick Y value
nunchuck_joystick_y: var
nunchuck_data_2_:
; The gyro X value
nunchuck_gyro_x: var
nunchuck_data_3_:
; The gyro Y value
nunchuck_gyro_y: var
nunchuck_data_4_:
; The gyro Z value
nunchuck_gyro_z: var
nunchuck_data_5_: var
