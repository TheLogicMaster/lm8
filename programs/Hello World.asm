; Hello World --- The classic "Hello World" program using 8-bit and 16-bit string addressing

    jmp program ; Program entry point

    include "libraries/Serial.asm"

message: db "Hello World!\n",$0 ; Message to print
message_extended: db "Extended Hello!\n",$0

program:
    jsr setup_serial ; Enable Serial output

; Print message from 8-bit address
    ldr =message,l ; Load message address into L
    jsr print_string ; Print message

; Print message from 16-bit address
    lda message_extended ; Load message address into HL
    jsr print_string_extended ; Print message

    halt ; Halt execution
