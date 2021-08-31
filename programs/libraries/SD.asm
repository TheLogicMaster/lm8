; SD card utility functions for SDHC/SDXC cards

; Reference: https://github.com/arduino-libraries/SD/blob/master/src/utility/Sd2Card.cpp

    def sd_cs={gpio_7}

    include "SPI.asm"


; Reset and initialize the SD card
setup_sd_card:
    push A

    jsr setup_spi

    ldr #7,A
    out {gpio_output},A

    ldr $1,A
    out {sd_cs},A

; Dummy bytes for 74+ clock cycles
    ldr $FF,A
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte

; Start communication with card
    ldr $0,A
    out {sd_cs},A

; Send CMD0 to reset card
setup_sd_card_reset_:
    ldr $FF,A
    jsr spi_send_byte
    ldr $40,A
    jsr spi_send_byte
    ldr $00,A
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    ldr $95,A
    jsr spi_send_byte
    jsr sd_get_response
    jr setup_sd_card_reset_,Z
    cmp $1
    jr setup_sd_card_reset_,nZ

; Send CMD8 to get card version info (Not actually used for simplicity since only version 2 and up is supported)
    ldr $FF,A
    jsr spi_send_byte
    ldr $48,A
    jsr spi_send_byte
    ldr $00,A
    jsr spi_send_byte
    jsr spi_send_byte
    ldr $01,A
    jsr spi_send_byte
    ldr $AA,A
    jsr spi_send_byte
    ldr $87,A
    jsr spi_send_byte
    jsr sd_get_response
    jsr spi_receive_byte
    jsr spi_receive_byte
    jsr spi_receive_byte
    jsr spi_receive_byte

; Initialize the card and wait for it to be ready
setup_sd_card_init_:
; Send CMD55
    ldr $FF,A
    jsr spi_send_byte
    ldr $77,A
    jsr spi_send_byte
    ldr $00,A
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr sd_get_response
    jr setup_sd_card_init_,Z

; Send ACMD41
    ldr $FF,A
    jsr spi_send_byte
    ldr $69,A
    jsr spi_send_byte
    ldr $40,A
    jsr spi_send_byte
    ldr $00,A
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr sd_get_response
    jr setup_sd_card_init_,Z
    cmp $0
    jr setup_sd_card_init_,nZ

; End communication with card
    ldr $1,A
    out {sd_cs},A

    pop A
    ret


; Send CMD58 command to get SD card info.
; Fills A, B, H, and L with the 4 received bytes, repectively.
; Sets Zero flag upon failure
get_sd_card_info:
    ldr $0,A
    out {sd_cs},A

    ldr $FF,A
    jsr spi_send_byte
    ldr $7A,A
    jsr spi_send_byte
    ldr $00,A
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    jsr sd_get_response
    jr get_sd_card_info_read_,nZ
    ldr $0,A
    ret
get_sd_card_info_read_:
    jsr spi_receive_byte
    push A
    jsr spi_receive_byte
    push A
    jsr spi_receive_byte
    push A
    jsr spi_receive_byte
    push A

    ldr $1,A
    out {sd_cs},A

    pop L
    pop H
    pop B
    pop A

    ret


; Requests a read of block at the index in A and waits for data start
; Uses timer 1 with 600 ms timeout
; Sets Zero flag upon failure
sd_read_block:
    push A

; CMD17 to request single block read
    ldr $FF,A
    jsr spi_send_byte
    ldr $51,A
    jsr spi_send_byte
    ldr $00,A
    jsr spi_send_byte
    jsr spi_send_byte
    jsr spi_send_byte
    pop A
    push A
    jsr spi_send_byte
    ldr $00,A
    jsr spi_send_byte
    jsr sd_get_response
    jr sd_read_block_wait_,nZ
    pop A
    ret
sd_read_block_wait_:
    jsr sd_data_block_wait

    pop A
    ret


; Wait for data block start.
; Uses timer 1 for a 600 ms timeout.
; Sets the Zero flag if it times out.
sd_data_block_wait:
    push A
    ldr {deciseconds},A
    out {timer_unit_1},A
    ldr #6,A
    out {timer_count_1},A
    out {timer_1},A
sd_data_block_wait_loop_:
    jsr spi_receive_byte
    cmp $FE
    jr sd_data_block_wait_done_,Z
    in {timer_1},A
    jr sd_data_block_wait_loop_,Z
    ldr $0,A
    pop A
    ret
sd_data_block_wait_done_:
    ldr $1,A
    pop A
    ret


; Wait up to 256 clk cycles for an SD card reponse to a command and return it in A
; Zero flag is set upon failure
sd_get_response:
    push B
    ldr $FF,B
sd_get_response_loop_:
    dec B
    jr sd_get_response_timeout_,C
    jsr spi_receive_byte
    push A
    and $80
    pop A
    jr sd_get_response_loop_,nZ
    ldr $1,B
    pop B
    ret
sd_get_response_timeout_:
    ldr $0,A
    pop B
    ret
