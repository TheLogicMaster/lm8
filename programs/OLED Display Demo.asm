; OLED Display Demo --- Demo featuring I2C SSD1306 display at address 0x3C

jmp main

    include "libraries/SSD1306.asm"


main:
; Initialize display with address 0x3C
    ldr $3C,A
    str [ssd1306_addr],A
    jsr setup_ssd1306

loop:
; Clear screen
    ldr $0,A
    str [ssd1306_color],A
    jsr ssd1306_clear

; Draw image to display buffer
    lda image
    jsr ssd1306_draw_image

; Draw lines along sides of sceen over image to demonstrate refresh rate
    ldr $1,A
    str [ssd1306_color],A
    ldr #63,A
draw_lines:
    ldr #0,B
    jsr ssd1306_draw_pixel
    ldr #127,B
    jsr ssd1306_draw_pixel
    dec A
    cmp #15
    jr draw_lines,nZ

; Update display with display buffer
    jsr ssd1306_update

; Display
    lda image
    jsr ssd1306_display

    jmp loop

image: bin "images/lm8.bin"
