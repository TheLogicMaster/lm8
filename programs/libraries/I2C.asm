; I2C utility library

    def scl=#6
    def sda=#5


; Starts an I2C write mode transmission to address A
; Sets Zero flag if not ACKnowldged and clears it otherwise
i2c_start_write:
    push B
    ldr $0,B
    jsr i2c_start
    pop B
    ret


; Starts an I2C read mode transmission to address A
; Sets Zero flag if not ACKnowldged and clears it otherwise
i2c_start_read:
    push B
    ldr $1,B
    jsr i2c_start
    pop B
    ret


; Begin I2C transmission to address A with mode B
; Set B to a 0 for write mode and 1 for read, anything else is undefined behavior
; Sets Zero flag if not ACKnowldged and clears it otherwise
i2c_start:
    push A
    push B

; Start
    push B
    ldr {sda},B
    out {arduino_output},B
    ldr {scl},B
    out {arduino_input},B
    ldr {scl},B
    out {arduino_output},B
    pop B

; Address byte
    lsl
    or B
    push A
    pop B
    jsr i2c_send_byte

    pop B
    pop A
    ret


; Stops I2C transmission
i2c_stop:
    push H

    ldr {sda},H
    out {arduino_output},H
    ldr {scl},H
    out {arduino_input},H
    ldr {sda},H
    out {arduino_input},H

    pop H
    ret


; Sends a byte from B in current I2C transmission
; Sets Zero flag if not ACKnowldged and clears it otherwise
i2c_send_byte:
    push A
    push B

    push B
    pop A
    ldr $8,B
i2c_send_byte_loop:
    lsl
    push A
    jr i2c_send_bit_1,C
    ldr $0,A
    jr i2c_send_byte_bit
i2c_send_bit_1:
    ldr $1,A
i2c_send_byte_bit:
    jsr i2c_send_bit
    pop A
    dec B
    jr i2c_send_byte_loop,nZ

; Data ACK
    ldr $1,B
    jsr i2c_send_bit
    jr i2c_send_byte_ack,nZ
    ldr $0,B
i2c_send_byte_ack:

    pop B
    pop A
    ret


; Receive a byte into A in the current I2C transmission
i2c_receive_byte:
    push B
    push H

    ldr $0,A
    ldr #8,H
i2c_receive_byte_loop:
    lsl
    ldr $1,B
    jsr i2c_send_bit
    jr i2c_receive_byte_0,nZ
    or $1
i2c_receive_byte_0:
    dec H
    jr i2c_receive_byte_loop,nZ

    ; ACK
    ldr $1,B
    jsr i2c_send_bit

    pop H
    pop B
    ret


; Sends a single bit based on the Zero Flag.
; Sets Zero Flag based on read value on SCL rise
i2c_send_bit:
    push A

; Set SDA pin
    jr send_set_sda_0,Z
    ldr {sda},A
    out {arduino_input},A
    jr send_set_sda_done
send_set_sda_0:
    ldr {sda},A
    out {arduino_output},A
send_set_sda_done:

    ; Read SDA and invert value
    in {arduino_5},A
    xor $1
    push A

; Set SCL high
    ldr {scl},A
    out {arduino_input},A

; Set SCL low
    ldr {scl},A
    out {arduino_output},A

    pop A
    cmp $0

    pop A
    ret
