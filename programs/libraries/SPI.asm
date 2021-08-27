; SPI serial utilities

    def clk={gpio_4}
    def miso={gpio_5}
    def mosi={gpio_6}


; Todo: Remove delay NOPs if not needed


; Setup the pins for SPI communication
setup_spi:
    push A

    ldr #4,A
    out {gpio_output},A
    ldr #6,A
    out {gpio_output},A

    ldr $0,A
    out {clk},A

    pop A
    ret


; Receive a byte from the currently enabled SPI device in A
spi_receive_byte:
    push B
    push H
    ldr $1,H
    out {mosi},H
    ldr $0,A
    ldr $8,B
spi_receive_byte_loop:
    ldr $1,H
    out {clk},H
    nop
    nop
    nop
    lsl
    in {miso},H
    or H
    ldr $0,H
    out {clk},H
    dec B
    jr spi_receive_byte_loop,nZ
    pop H
    pop B
    ret


; Send a single byte to the currently enabled SPI slave from A
spi_send_byte:
    push A
    push B
    nop
    nop
    nop
    ldr $8,B
spi_send_byte_loop:
    lsl
    push A
    jr spi_send_bit_1,C
    ldr $0,A
    jr spi_send_byte_bit
spi_send_bit_1:
    ldr $1,A
spi_send_byte_bit:
    jsr spi_send_bit
    pop A
    dec B
    jr spi_send_byte_loop,nZ
    nop
    nop
    nop
    pop B
    pop A
    ret


; Send a single bit in A to the currently enabled SPI slave
spi_send_bit:
    push B
    out {mosi},A
    ldr $1,B
    out {clk},B
    nop
    nop
    nop
    ldr $0,B
    out {clk},B
    pop B
    ret
