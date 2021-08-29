; I2C LCD Hello World example

jmp main

    include "libraries/LCD.asm"

    message: db "Hello World!", $0

main:
    ldr $27,A
    str [lcd_addr],A

    jsr lcd_init

    jsr lcd_backlight_on

    ldr #1,A
    ldr #4,B
    jsr lcd_set_cursor

    lda message
    jsr lcd_print_string

    halt
