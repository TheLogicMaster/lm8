; Incremental rotary encoder with pins CLK on Arduino 2 and DT on Arduino 3

; Setup timer 0 for 20 millis for "debounce"
    ldr {milliseconds},A
    out {timer_unit_0},A
    ldr #20,A
    out {timer_count_0},A

loop:
    jsr update_encoder

    ldr [rotation],A
    out {seven_segment_0},A

    jmp loop


; Update the rotation variable based on the encoder
update_encoder:
    push A
    push B
    push H

; Load previous rotation
    ldr [rotation],H

; Check if rotation event has occured
    in {arduino_2},A
    jr update_encoder_done,nZ
    ldr [prevCLK],B
    cmp B
    jr update_encoder_done,Z

    ; Update rotation value
    in {arduino_3},B
    cmp B
    jr update_encoder_ccw,nZ
    dec H
    jr update_encoder_changed
update_encoder_ccw:
    inc H
update_encoder_changed:

; Debounce
    out {timer_0},B
update_encoder_debounce:
    in {timer_0},B
    jr update_encoder_debounce,Z

; Store new values
update_encoder_done:
    str [prevCLK],A
    str [rotation],H

    pop H
    pop B
    pop A
    ret

    data
prevCLK: var
rotation: var