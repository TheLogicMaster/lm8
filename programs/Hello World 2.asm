; This demonstrates printing a string using Print String

    jmp program ; Program entry point

message: db "Hello World!\n",$0 ; Message to print

program:
    ldr =message,a ; Load message address into A
    out {print_string},a ; Print message at [A]
    halt ; Halt execution
