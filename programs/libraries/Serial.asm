; Serial utility functions


; Setup UART pins and output a null byte to prevent the first byte being corrupted
setup_serial:
    push A

    ldr $1,A
    out {arduino_output},A
    out {serial_enable},A
    ldr $0,A
    out {serial},A

    pop A
    ret


; Print a null terminated string from [L]
print_string:
    push H

    ldr $0,H
    jsr print_string_extended

    pop H
    ret


; Print a null terminated string from [HL]
print_string_extended:
    push A
    push H
    push L

print_string_extended_loop_:
    ldr [hl],a
    jr print_string_extended_done_,z
    out {serial},a
    ina
    jr print_string_extended_loop_
print_string_extended_done_:

    pop L
    pop H
    pop A
    ret


; Clears the serial receive buffer
serial_clear_buffer:
    push A

serial_clear_buffer_loop_:
    out {serial_available},A
    in {serial_available},A
    jr serial_clear_buffer_loop_,nZ

    pop A
    ret
