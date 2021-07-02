; A snake game using the controller peripheral

jmp loop ; Program entry point

message: db "Message\n",$0 ; Message to print

; Program loop
loop:
    ; Limit game speed with a counter and dummy operations
    ldr $FF,a
delay:
    nop
    nop
    nop
    nop
    dec a
    jr delay,nz

    ; Clear screen with black
    ldr #0,a
    out {clear_screen},a

    ldr #8,a
    out {draw_sprite},a

    jr loop ; GOTO loop

    org $200 ; Start sprites at ID 8
    incbin "sprites/snake_head.bin"
    incbin "sprites/snake_body.bin"
    incbin "sprites/apple.bin"

data ; Enter data section
score: var ; Number of apples collected
snake: var[320] ; Array of snake body directions starting from head
