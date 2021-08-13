; Music player

    ; Set buzzer pin (Arduino 2) to output mode
    ldr $2,B
    out {arduino_output},B

    ; Setup timer 0 for note duration
    ldr {centiseconds},A
    out {timer_unit_0},A

    ; Load song address
    lda song
    str [index_high],H
    str [index_low],L

loop:
; Load current note address
    ldr [index_high],H
    ldr [index_low],L

; Load note length and check for end of song
    ldr [HL],A
    cmp $FF
    jr done,Z
    ina

; Start note length timer
    out {timer_count_0},A
    out {timer_0},A

; Load note
    ldr [HL],A
    push A
    ina
    ldr [HL],B
    ina

; Store new note address
    str [index_high],H
    str [index_low],L

    pop H

; Set A to 0 to enable the buzzer if the note isn't a rest
    or B
    jr rest,Z
    ldr $0,A
    jr play_note
rest:
    ldr $2,A ; Disable buzzer

play_note:
    ldr {milliseconds},L
    out {timer_unit_1},L
    out {timer_count_1},H
    out {timer_1},L
note_millis:
    in {timer_1},L
    jr note_millis,Z

    ldr {centimilliseconds},L
    out {timer_unit_1},L
    out {timer_count_1},B
    out {timer_1},L
note_centimillis:
    in {timer_1},L
    jr note_centimillis,Z

; Toggle buzzer pin
    xor $1
    out {arduino_2},A

; Check if note ended
    in {timer_0},L
    jr play_note,Z

; Short note separation
    ldr $1,L
    out {timer_count_0},L
    out {timer_0},L
separation:
    in {timer_0},L
    jr separation,Z

    jmp loop

done:
    ldr $1,A
    out {led_0},A
    halt

song: bin "songs/cannonind.bin"

    data
index_high: var
index_low: var
