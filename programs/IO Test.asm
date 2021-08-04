; Functionality test for physical I/O

; Test writing to and reading from seven segment displays by counting from 1 to 6
    ldr $1,A
    out {seven_segment_0},A
    in {seven_segment_0},A
    inc A
    out {seven_segment_1},A
    in {seven_segment_1},A
    inc A
    out {seven_segment_2},A
    in {seven_segment_2},A
    inc A
    out {seven_segment_3},A
    in {seven_segment_3},A
    inc A
    out {seven_segment_4},A
    in {seven_segment_4},A
    inc A
    out {seven_segment_5},A

; Test reading and writing from LEDs by toggling every other LED
    ldr {led_0},A
    dec A
    ldr $1,B
led_toggle:
    inc A
    out B
    push A
    in A
    xor $1
    push A
    pop B
    pop A
    cmp {led_9}
    jr led_toggle,nZ

    ; Set GPIO 1 and Arduino 1 to output mode
    ldr #1,A
    out {gpio_output},A
    out {arduino_output},A

; Test VGA capabilities with an ugly color stripe thing
    ldr $0,A
    ldr #127,H
draw_row:
    out {graphics_y},H
    ldr #159,L
draw_pixel:
    out {graphics_x},L
    add $8
    out {draw_pixel},A
    dec L
    jr draw_pixel,nC
    dec H
    jr draw_row,nC
    out {swap_display},A

loop:
    ; Set GPIO 1 Arduino 1 from switches 0 and 1, respectively
    in {gpio_0},A
    out {gpio_1},A
    in {switch_1},A
    out {arduino_1},A

    in {button_0},A
    jr not_button_0,z
    jsr leds_from_switches
not_button_0:

    in {button_1},A
    jr not_button_1,z
    jsr leds_from_io
not_button_1:

    jr loop

; Output to LEDs based on switches when button 0 is pressed
leds_from_switches:
    ldr #9,a
leds_from_switches_loop:
    add {switch_0}
    in b
    sub {switch_0}
    add {led_0}
    out b
    sub {led_0}
    dec a
    jr leds_from_switches_loop,nc
    ret

; Output to LEDs based on GPIO 0-4 and Arduino header 0-4
leds_from_io:
    ldr #9,a
leds_from_io_loop:
    push A
    cmp $5
    jr leds_from_io_arduino,nC
    add {gpio_0}
    jr leds_from_io_out
leds_from_io_arduino:
    sub $4
    add {arduino_0}
leds_from_io_out:
    in b
    pop A
    add {led_0}
    out b
    sub {led_0}
    dec a
    jr leds_from_io_loop,nc
    ret
