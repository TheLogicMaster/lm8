; I2C LCD driver library
; Based on: https://github.com/johnrickman/LiquidCrystal_I2C/blob/master/LiquidCrystal_I2C.cpp

    include "I2C.asm"


; Initialized the I2C LCD
; Set the [lcd_addr] address before calling
; Uses timer 1 for initialization delays
lcd_init:
    push A

; 50 ms delay for power on
    ldr {milliseconds},A
    out {timer_unit_1},A
    ldr #50,A
    out {timer_count_1},A
    out {timer_1},A
lcd_init_delay_0_:
    in {timer_1},A
    jr lcd_init_delay_0_,Z

; Reset expander
    ldr $0,A
    jsr lcd_expander_write

; One second delay
    ldr {seconds},A
    out {timer_unit_1},A
    ldr #1,A
    out {timer_count_1},A
    out {timer_1},A
lcd_init_delay_1_:
    in {timer_1},A
    jr lcd_init_delay_1_,Z

    ldr {milliseconds},A
    out {timer_unit_1},A
    ldr #5,A
    out {timer_count_1},A

; Set 4-bit mode
    ldr $30,A
    jsr lcd_write_4_bits

    out {timer_1},A
lcd_init_delay_2_:
    in {timer_1},A
    jr lcd_init_delay_2_,Z

    ldr $30,A
    jsr lcd_write_4_bits

    out {timer_1},A
lcd_init_delay_3_:
    in {timer_1},A
    jr lcd_init_delay_3_,Z

    ldr $30,A
    jsr lcd_write_4_bits

    ldr {microseconds},A
    out {timer_unit_1},A
    ldr #150,A
    out {timer_count_1},A
    out {timer_1},A
lcd_init_delay_4_:
    in {timer_1},A
    jr lcd_init_delay_4_,Z

; Set to 4-bit interface
    ldr $20,A
    jsr lcd_write_4_bits

; Set display line number and font size
    ldr $20,A ; Function set
    or $08 ; 2 line mode
    jsr lcd_command

; Set default control mode
    ldr $4,A
    str [lcd_control_state_],A
    jsr lcd_control_command

    jsr lcd_clear

; Set default display mode
    ldr $2,A
    str [lcd_mode_state_],A
    jsr lcd_mode_command

    jsr lcd_home

    pop A
    ret


; Clears the LCD
; Uses timer 1 for a delay
lcd_clear:
    push A
    ldr $1,A ; Clear display command
    jsr lcd_command
    jsr lcd_long_command_delay
    pop A
    ret


; Resets LCD cursor
; Uses timer 1 for a delay
lcd_home:
    push A
    ldr $2,A ; Return home command
    jsr lcd_command
    jsr lcd_long_command_delay
    pop A
    ret


; Delays a bit for long commands
; Uses timer 1 for a delay
lcd_long_command_delay:
    push A

    ldr {milliseconds},A
    out {timer_unit_1},A
    ldr #2,A
    out {timer_count_1},A
    out {timer_1},A
lcd_long_command_delay_loop_:
    in {timer_1},A
    jr lcd_long_command_delay_loop_,Z

    pop A
    ret


; Sets the cursor position to row A column B
lcd_set_cursor:
    push A

; Get row start address
    cmp #0
    jr lcd_set_cursor_got_row_,Z
    cmp #1
    jr lcd_set_cursor_not_row_1_,nZ
    ldr $40,A
    jr lcd_set_cursor_got_row_
lcd_set_cursor_not_row_1_:
    cmp #2
    jr lcd_set_cursor_not_row_2_,nZ
    ldr $14,A
    jr lcd_set_cursor_got_row_
lcd_set_cursor_not_row_2_:
    ldr $54,A
lcd_set_cursor_got_row_:

    add B
    or $80 ; Set DRAM address command
    jsr lcd_command

    pop A
    ret


; Scroll display left
lcd_scroll_left:
    push A
    ldr $18,A
    jsr lcd_command
    pop A
    ret


; Scroll display right
lcd_scroll_right:
    push A
    ldr $1C,A
    jsr lcd_command
    pop A
    ret


; Turn LCD display on
lcd_display_on:
    push A
    ldr [lcd_control_state_],A
    or $04
    str [lcd_control_state_],A
    jsr lcd_control_command
    pop A
    ret


; Turn LCD display off
lcd_display_off:
    push A
    ldr [lcd_control_state_],A
    and $FB
    str [lcd_control_state_],A
    jsr lcd_control_command
    pop A
    ret


; Turn LCD cursor on
lcd_cursor_on:
    push A
    ldr [lcd_control_state_],A
    or $02
    str [lcd_control_state_],A
    jsr lcd_control_command
    pop A
    ret


; Turn LCD cursor off
lcd_cursor_off:
    push A
    ldr [lcd_control_state_],A
    and $FD
    str [lcd_control_state_],A
    jsr lcd_control_command
    pop A
    ret


; Turn LCD cursor blinking on
lcd_cursor_blink_on:
    push A
    ldr [lcd_control_state_],A
    or $01
    str [lcd_control_state_],A
    jsr lcd_control_command
    pop A
    ret


; Turn LCD cursor blinking off
lcd_cursor_blink_off:
    push A
    ldr [lcd_control_state_],A
    and $FE
    str [lcd_control_state_],A
    jsr lcd_control_command
    pop A
    ret


; Set LCD text direction to left to right
lcd_left_to_right:
    push A
    ldr [lcd_mode_state_],A
    or $02
    str [lcd_mode_state_],A
    jsr lcd_mode_command
    pop A
    ret


; Set LCD text direction to right to left
lcd_right_to_left:
    push A
    ldr [lcd_mode_state_],A
    and $FD
    str [lcd_mode_state_],A
    jsr lcd_mode_command
    pop A
    ret


; Set LCD to 'right justify' from cursor
lcd_autoscroll_on:
    push A
    ldr [lcd_mode_state_],A
    or $01
    str [lcd_mode_state_],A
    jsr lcd_mode_command
    pop A
    ret


; Set LCD to 'left justify' from cursor
lcd_autoscroll_off:
    push A
    ldr [lcd_mode_state_],A
    and $FE
    str [lcd_mode_state_],A
    jsr lcd_mode_command
    pop A
    ret


; Turn LCD backlight on
lcd_backlight_on:
    push A
    ldr $8,A
    str [lcd_backlight_state_],A
    ldr $0,A
    jsr lcd_expander_write
    pop A
    ret


; Turn lcd_backlight_off
lcd_backlight_off:
    push A
    ldr $0,A
    str [lcd_backlight_state_],A
    jsr lcd_expander_write
    pop A
    ret


; Sends a display control command with the current control state
lcd_control_command:
    push A
    ldr [lcd_control_state_],A
    or $08 ; Display control command
    jsr lcd_command
    pop A
    ret


; Sends a display mode command with the current mode
lcd_mode_command:
    push A
    ldr [lcd_mode_state_],A
    or $04 ; Display mode command
    jsr lcd_command
    pop A
    ret


; Send a command in A to the LCD
lcd_command:
    push B
    ldr $0,B
    jsr lcd_send
    pop B
    ret


; Print a null terminated string at [HL] to the LCD
lcd_print_string:
    push A

lcd_print_string_loop_:
    ldr [hl],a
    jr lcd_print_string_done_,z
    jsr lcd_print
    ina
    jr lcd_print_string_loop_
lcd_print_string_done_:

    pop A
    ret


; Print a character in A to the LCD
lcd_print:
    push B
    ldr $1,B
    jsr lcd_send
    pop B
    ret


; Send value A with mode B
lcd_send:
    push A

    push A
    and $F0
    or B
    jsr lcd_write_4_bits
    pop A

    lsl
    lsl
    lsl
    lsl
    or B
    jsr lcd_write_4_bits

    pop A
    ret


; Write 4 bits and mode in A and pulse the enable line
lcd_write_4_bits:
    jsr lcd_expander_write
    jsr lcd_pulse_enable
    ret


; Pulse the LCD enable line and data in A
lcd_pulse_enable:
    push A
    or $4 ; Enable line high
    jsr lcd_expander_write
    pop A
    jsr lcd_expander_write
    ret


; Write data in A to the expander in addition to the backlight state
lcd_expander_write:
    push A
    push B

    push A
    pop B

    ldr [lcd_addr],A
    jsr i2c_start_write

    ldr [lcd_backlight_state_],A
    or B
    push A
    pop B
    jsr i2c_send_byte
    jsr i2c_stop

    pop B
    pop A
    ret


    data
; The I2C address of the LCD, set before initializing
lcd_addr: var

lcd_backlight_state_: var
lcd_control_state_: var
lcd_mode_state_: var
