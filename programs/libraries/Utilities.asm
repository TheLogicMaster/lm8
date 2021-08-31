; Utilities


; Sets the C flag if running in memory, clears it otherwise
is_in_memory:
    push A
    push H
    push L

    lda is_in_memory
    ldr $7F,A
    cmp H

    pop L
    pop H
    pop A
    ret


; Waits for duration B of time unit A
; Uses the timer specified in [delay_timer]
delay:
    push A
    push B
    push H

; Set timer count
    push A
    ldr [delay_timer],H
    ldr {timer_count_0},A
    add H
    out B
    pop A

; Set timer unit
    push A
    pop B
    ldr [delay_timer],H
    ldr {timer_unit_0},A
    add H
    out B

; Clear and wait for timer
    ldr [delay_timer],B
    ldr {timer_0},A
    add B
    out B
    delay_loop_:
    in B
    jr delay_loop_,Z

    pop H
    pop B
    pop A
    ret


; Wait for B decaseconds using timer [delay_timer]
delay_decaseconds:
    push A
    ldr {decaseconds},A
    jsr delay
    pop A
    ret


; Wait for B secondsseconds using timer [delay_timer]
delay_seconds:
    push A
    ldr {seconds},A
    jsr delay
    pop A
    ret


; Wait for B deciseconds using timer [delay_timer]
delay_deciseconds:
    push A
    ldr {deciseconds},A
    jsr delay
    pop A
    ret


; Wait for B centiseconds using timer [delay_timer]
delay_centiseconds:
    push A
    ldr {centiseconds},A
    jsr delay
    pop A
    ret


; Wait for B milliseconds using timer [delay_timer]
delay_milliseconds:
    push A
    ldr {milliseconds},A
    jsr delay
    pop A
    ret


; Wait for B decimilliseconds using timer [delay_timer]
delay_decimilliseconds:
    push A
    ldr {decimilliseconds},A
    jsr delay
    pop A
    ret


; Wait for B centimilliseconds using timer [delay_timer]
delay_centimilliseconds:
    push A
    ldr {centimilliseconds},A
    jsr delay
    pop A
    ret


; Wait for B microseconds using timer [delay_timer]
delay_microseconds:
    push A
    ldr {microseconds},A
    jsr delay
    pop A
    ret


    data
; The timer used for delays, either 0 or 1
delay_timer: var
