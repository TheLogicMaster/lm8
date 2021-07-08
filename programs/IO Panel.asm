; This demonstrates using DE10-Lite I/O or the emulator I/O panel

    jmp loop ; Program entry point

message: db "Pressed Button ",$0 ; Message to print

; Program loop
loop:
    ; Set LED 2-9 to SW 2-9
    ldr #7,a        ; A = 7
set_leds:
    add {switch_2}  ; A = A + {switch_2}
    in b            ; B = SW
    sub {switch_2}  ; A = A - {switch_2}
    add {led_2}     ; A = A + {led_2}
    out b           ; SW = B
    sub {led_2}     ; A = A - {led_2}
    dec a           ; A--
    jr set_leds,nc  ; If not Carry GOTO set_leds

    ; Set LED0 to SW0 AND BTN0
    in {switch_0},a ; A = SW0
    in {button_0},b ; B = BTN0
    and b           ; A = A & B
    out {led_0},a   ; LED0 = A

    ; Set LED1 to SW1 OR BTN1
    in {switch_1},a ; A = SW1
    in {button_1},b ; B = BTN1
    or b            ; A = A | B
    out {led_1},a   ; LED1 = A

    ; Print which buttons are just pressed
    ldr {button_1},a        ; A = {button_1}
    inc a                   ; A++
    lda btn1                ; HL = btn1
    ina                     ; HL++
check_buttons:
    dea                     ; HL--
    dec a                   ; A--
    in b                    ; B = btn
    jr not_btn,z            ; If Zero GOTO not_btn
    ldr [hl],b              ; B = [hl]
    jr not_btn,nz           ; If not Zero GOTO not_btn
    ldr =message,b          ; B = message
    out {print_string},b    ; Print message
    str [temp],a            ; [temp] = A
    ldr [temp],b            ; B = [temp]
    ldr '0',a               ; A = '0'
    sub {button_0}          ; A = A - {button_0}
    add b                   ; A = A + B
    out {print_char},a      ; Print A
    ldr [temp],a            ; A = [temp]
    ldr '\n',b              ; B = '\n'
    out {print_char},b      ; Print '\n'
not_btn:
    in b                    ; B = btn
    str [hl],b              ; [hl] = B
    cmp {button_0}          ; Compare A with {button_0}
    jr check_buttons,nz     ; If not Zero GOTO check_buttons

    ; 7-segment counter
    ldr {seven_segment_5},a ; A = {seven_segment_5}
counter:
    str [temp],a            ; [temp] = A
    in a                    ; A = port[A]
    inc a                   ; A++
    str [temp2],a           ; [temp2] = A
    cmp $A                  ; Compare A with $A
    ldr [temp],a            ; A = [temp]
    ldr [temp2],b           ; B = [temp2]
    jr counter_done,c       ; GOTO counter_done if Carry
    ldr #0,b                ; B = 0
    out b                   ; port[A] = B
    dec a                   ; A--
    cmp {seven_segment_0}   ; Compare A with {seven_segment_0}
    jr counter,nc           ; GOTO counter if not Carry
    inc a                   ; A++
counter_done:
    out b                   ; port[A] = B

    jr loop ; GOTO loop

    data ; Enter data section
btn0:  var  ; Btn0 state variable
btn1:  var  ; Btn1 state variable
temp:  var  ; Temp variale
temp2: var  ; Temp variable 2
