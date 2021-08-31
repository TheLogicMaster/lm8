; Graphics utilities

    include "Math.asm"


; Draws sprite from [HL] at (B,A)
draw_sprite_software:
    push A
    push B
    push H
    push L

    str [graphics_temp_],B
    ldr $0,B
draw_sprite_software_loop_:
    push A

; Calculate Y
    push B
    push A
    push B
    pop A
    ldr $8,B
    jsr divide
    push A
    pop B
    pop A
    add B
    pop B

    push B

; Calculate X
    push A
    push B
    pop A
    ldr $8,B
    jsr modulus
    ldr [graphics_temp_],B
    add B
    push A
    pop B
    pop A

; Draw pixel
    out {graphics_x},B
    out {graphics_y},A
    ldr [HL],A
    ina
    out {draw_pixel},A

    pop B

    inc B
    ldr #64,A
    cmp B
    pop A
    jr draw_sprite_software_loop_,nZ

    pop L
    pop H
    pop B
    pop A
    ret


    data
; Temporary variable for graphics subroutines
graphics_temp_: var
