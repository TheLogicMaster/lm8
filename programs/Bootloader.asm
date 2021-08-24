; Bootloader --- An SDHC/SDXC SD card program loader

    jmp program

    include "libraries/Serial.asm"
    include "libraries/SD.asm"

program:
    ;jsr setup_serial ; Uncomment for debugging

    jsr setup_sd_card

; Start communication with card
    ldr $0,A
    out {sd_cs},A

; Copy program into RAM
    lda $8000
    ldr #0,A
    str [block_index],A
load_program:
    cmp #0
    jr first_block,Z
    push A
    jsr spi_receive_byte
    jsr spi_receive_byte
    pop A
first_block:
    jsr sd_read_block
    jr program,Z

; Copy block into memory
    ldr $2,A
    ldr $0,B
copy_loop:
    push A
    jsr spi_receive_byte
    ;out {serial},A ; Uncomment for debugging
    str [HL],A
    pop A
    ina
    dec B
    jr copy_loop,nZ
    dec A
    jr copy_loop,nZ

    ldr [block_index],A
    inc A
    str [block_index],A
    cmp #32
    jr load_program,nZ

; Stop communication with card
    ldr $1,A
    out {sd_cs},A

; Execute program
    jmp $8000

    data
    org $C000
block_index: var ; The current block number
