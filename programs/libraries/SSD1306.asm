; SSD1306 128x64 I2C OLED display library that uses a 1 KB display buffer
; Reference: https://github.com/adafruit/Adafruit_SSD1306/blob/master/Adafruit_SSD1306.cpp

    include "I2C.asm"
    include "Math.asm"


; Initialize I2C SSD1306 display
; Set [ssd1306_addr] to the display's I2C address before calling
setup_ssd1306:
    push A
    push B

    ldr [ssd1306_addr],A

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $AE,B
    jsr i2c_send_byte
    ldr $D5,B
    jsr i2c_send_byte
    ldr $80,B
    jsr i2c_send_byte
    ldr $A8,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $3F,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $D3,B
    jsr i2c_send_byte
    ldr $0,B
    jsr i2c_send_byte
    ldr $40,B
    jsr i2c_send_byte
    ldr $8D,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $14,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $20,B
    jsr i2c_send_byte
    ldr $0,B
    jsr i2c_send_byte
    ldr $A1,B
    jsr i2c_send_byte
    ldr $C8,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $DA,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $12,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $81,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $CF,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $D9,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $F1,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $DB,B
    jsr i2c_send_byte
    ldr $40,B
    jsr i2c_send_byte
    ldr $A4,B
    jsr i2c_send_byte
    ldr $A6,B
    jsr i2c_send_byte
    ldr $2E,B
    jsr i2c_send_byte
    ldr $AF,B
    jsr i2c_send_byte
    jsr i2c_stop

    pop B
    pop A
    ret


; Draws sprite from [HL] at (B,A)
; Modifies [ssd1306_color]
ssd1306_draw_sprite:
    push A
    push B
    push H
    push L

    str [ssd1306_temp_1_],B
    ldr $0,B
ssd1306_draw_sprite_loop_:
    push A

; Set color
    push B
    ldr [HL],B
    str [ssd1306_color],B
    ina
    pop B

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
    ldr [ssd1306_temp_1_],B
    add B
    push A
    pop B
    pop A

; Draw pixel
    jsr ssd1306_draw_pixel

    pop B

    inc B
    ldr #64,A
    cmp B
    pop A
    jr ssd1306_draw_sprite_loop_,nZ

    pop L
    pop H
    pop B
    pop A
    ret


; Draw a monochrome pixel to the display buffer with [ssd1306_color] at (B,A)
ssd1306_draw_pixel:
    push A
    push B
    push H
    push L

; Get address of pixel's column
    push A
    push B
    ldr $8,B
    jsr divide
    ldr #128,B
    jsr multiply_extended
    pop A
    jsr add_extended
    push H
    pop A
    push L
    pop B
    lda ssd1306_buffer
    jsr add_double_extended
    pop A

; Set bit for pixel
    ldr $8,B
    jsr modulus
    push A
    pop B
    ldr $1,A
    push A
    ldr $0,A
    cmp B
    pop A
ssd1306_draw_pixel_shift_:
    jr ssd1306_draw_pixel_shift_done_,Z
    lsl
    dec B
    jr ssd1306_draw_pixel_shift_
ssd1306_draw_pixel_shift_done_:
    ldr [ssd1306_color],B
    jr ssd1306_draw_pixel_0_,Z
    push A
    pop B
    ldr [HL],A
    or B
    jr ssd1306_draw_pixel_store_
ssd1306_draw_pixel_0_:
    xor $FF
    push A
    pop B
    ldr [HL],A
    and B
ssd1306_draw_pixel_store_:
    str [HL],A

    pop L
    pop H
    pop B
    pop A
    ret


; Clears the display buffer with [ssd1306_color]
ssd1306_clear:
    push A
    push B
    push H
    push L

    ldr $0,B
    ldr [ssd1306_color],A
    jr ssd1306_clear_0_,Z
    ldr $FF,B
ssd1306_clear_0_:
    str [ssd1306_temp_1_],B
    ldr #4,A
    ldr $0,B
    lda ssd1306_buffer
ssd1306_clear_loop_:
    push B
    ldr [ssd1306_temp_1_],B
    str [HL],B
    ina
    pop B
    dec B
    jr ssd1306_clear_loop_,nZ
    dec A
    jr ssd1306_clear_loop_,nZ

    pop L
    pop H
    pop B
    pop A
    ret


; Push the display buffer to the SSD1306 display
ssd1306_update:
    push H
    push L

    lda ssd1306_buffer
    jsr ssd1306_display

    pop L
    pop H
    ret


; Draw a 128x64 binary image at [HL] to the display buffer
ssd1306_draw_image:
    push A
    push B
    push H
    push L

    str [ssd1306_temp_1_],H
    str [ssd1306_temp_2_],L
    lda ssd1306_buffer
    ldr #4,A
    ldr $0,B
ssd1306_draw_image_loop_:
    push A

; Read byte
    push H
    push L
    ldr [ssd1306_temp_1_],H
    ldr [ssd1306_temp_2_],L
    ldr [HL],A
    ina
    str [ssd1306_temp_1_],H
    str [ssd1306_temp_2_],L
    pop L
    pop H

; Store byte
    str [HL],A

    pop A

    ina
    dec B
    jr ssd1306_draw_image_loop_,nZ
    dec A
    jr ssd1306_draw_image_loop_,nZ

    pop L
    pop H
    pop B
    pop A
    ret


; Update display with pixel data at [HL]
ssd1306_display:
    push A
    push B

    ldr [ssd1306_addr],A

; Set display start address
    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $22,B
    jsr i2c_send_byte
    ldr $00,B
    jsr i2c_send_byte
    ldr $FF,B
    jsr i2c_send_byte
    ldr $21,B
    jsr i2c_send_byte
    ldr $0,B
    jsr i2c_send_byte
    jsr i2c_stop
    jsr i2c_start_write
    ldr $0,B
    jsr i2c_send_byte
    ldr $7F,B
    jsr i2c_send_byte
    jsr i2c_stop

    jsr i2c_start_write
    ldr $40,B
    jsr i2c_send_byte

    ldr #4,A
    ldr $0,B
ssd1306_display_loop_:
    push B
    ldr [HL],B
    ina
    jsr i2c_send_byte
    pop B
    dec B
    jr ssd1306_display_loop_,nZ
    dec A
    jr ssd1306_display_loop_,nZ

    jsr i2c_stop

    pop B
    pop A
    ret


    data
; The I2C address of the display
ssd1306_addr: var
; The current color to draw with
ssd1306_color: var

ssd1306_temp_1_: var
ssd1306_temp_2_: var
ssd1306_buffer: var[1024]
