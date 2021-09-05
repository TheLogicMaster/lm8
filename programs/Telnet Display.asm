; Telnet Dislay --- A demo of the modem telnet functionality using the I2C LCD peripheral

    jmp main

    include "libraries/LCD.asm"
    include "libraries/Modem.asm"


main:
; Initialize LCD
    ldr $27,A
    str [lcd_addr],A
    jsr lcd_init
    jsr lcd_backlight_on

; Initialize modem with telnet server
    jsr modem_setup_telnet

; Display modem IP on LCD
    jsr modem_get_ip
    lda modem_ip
    ldr #1,A
    ldr #4,B
    jsr lcd_set_cursor
    jsr lcd_print_string

loop:
    ldr $10,A
    jsr delay_milliseconds

; Display received string to LCD and echo to client
    jsr modem_receive_string
    jr loop,nZ
    lda modem_received_string
    jsr lcd_clear
    ldr #1,A
    ldr #4,B
    jsr lcd_set_cursor
    jsr lcd_print_string
    jsr modem_send_string

    jmp loop
