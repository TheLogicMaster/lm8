; Serial Parot --- Parots anything recieved over UART back over UART

    jmp program

    include "libraries/Serial.asm"

message: db "Say something!\n",$0

program:
    jsr setup_serial

    ldr =message,l
    jsr print_string

loop:
    in {serial_available},A
    jr loop,Z
    in {serial},A
    out {serial_available},A
    out {serial},A
    jr loop

    halt ; Halt execution
