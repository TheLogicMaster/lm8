; This demonstrates manually printing out a string using Print

    jmp program ; Program entry point

message: db "Hello World!\n",$0 ; Message to print

program:
    ; Enable Serial output
    ldr $1,A
    out {arduino_output},A
    out {serial_enable},A

    ldr #0,h ; Zero High address register
    ldr =message,l ; Load message address into L

print:
    ldr [hl],a ; Load character into A
    jr done,z ; Jump to "done" if A is zero, i.e. end of string
    out {serial},a ; Print character in A
    ina ; Increment HL register
    jr print ; Jump to print

done:
    halt ; Halt execution
