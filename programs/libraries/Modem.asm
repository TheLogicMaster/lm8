; Modem --- Communicate with an ESP-01 board with stock firmware as an AT modem
; AT Command reference: https://docs.espressif.com/projects/esp-at/en/release-v2.2.0.0_esp8266/AT_Command_Set/index.html

    def modem_attempts=#10

    include "Serial.asm"
    include "Utilities.asm"

; Puts the modem into WiFi STA mode
at_command_sta_mode: db "AT+CWMODE=1", $0
; Set the modem's WiFi credentials
; Only need to do this once between factory resets
at_command_wifi_credentials: db "AT+CWJAP=\"ssid\",\"password\"", $0
; Restart the modem
at_command_reset: db "AT+RST", $0
; Configure modem UART to use 2 stop bits, doesn't persistently change the setting to avoid bricking
at_command_config_uart: db "AT+UART_CUR=115200,8,2,0,0", $0
; Start telnet server
at_command_telnet_start: db "AT+CIPSERVER=1,23", $0
; Factory reset modem
at_command_factory_reset: db "AT+RESTORE", $0
; Enable multiple TCP connections
at_command_multiple_connections: db "AT+CIPMUX=1", $0
; Get STA connection info
at_command_sta_info: db "AT+CIFSR", $0
; Send data to connected client, don't use directly, use modem_send_string
at_command_send_data: db "AT+CIPSENDEX=0,2048", $0


; Sets up the modem with a telnet server
; Uses delays
modem_setup_telnet:
    push B
    push H
    push L

; Ensure UART pins are initialized
    jsr setup_serial

; Setup modem UART with 2-bit parity
    lda at_command_config_uart
    jsr modem_send_command

; Put modem into STA mode
    lda at_command_sta_mode
    jsr modem_send_command

; Delay for WiFi connection
    ldr $3,B
    jsr delay_seconds

; Enable multiple connections
    lda at_command_multiple_connections
    jsr modem_send_command

; Start telnet server on port 23
    lda at_command_telnet_start
    jsr modem_send_command

    pop L
    pop H
    pop B
    ret


; Send a null terminated command from [HL] to the modem over serial
; Sets Zero flag on success
; Makes {modem_attempts} attempts at sending the command
; Uses delays
modem_send_command:
    push A
    push B
    push H
    push L

    ldr {modem_attempts},B
modem_send_command_attempt_:
    jsr serial_clear_buffer
    jsr print_string_extended
    ldr '\r',A
    out {serial},A
    ldr '\n',A
    out {serial},A

; Wait for response
    push B
    ldr #10,B
    jsr delay_milliseconds
    pop B

; Verify response command echo
    push H
    push L
modem_send_command_check_echo_:
    ldr [HL],A
    jr modem_send_command_check_echo_done_,Z
    ina

; Ensure serial buffer isn't empty
    push A
    in {serial_available},A
    pop A
    jr modem_send_command_check_echo_fail_,Z

; Compare response with command string
    push B
    in {serial},B
    out {serial_available},B
    cmp B
    pop B
    jr modem_send_command_check_echo_,Z
modem_send_command_check_echo_fail_:
    ldr $1,A ; Clear zero flag
modem_send_command_check_echo_done_:
    pop L
    pop H
    jr modem_send_command_done_,Z
    dec B
    jr modem_send_command_attempt_,nZ
    ldr $1,B ; Clear zero flag on failure

modem_send_command_done_:
; Clear line ending from buffer
    out {serial_available},A
    out {serial_available},A

    pop L
    pop H
    pop B
    pop A
    ret


; Checks if the previously executed command resulted in an "OK" response
; Call immediately after the command is executed
; Returns a 1 in A if not successful, sets Zero flag accordingly
modem_check_command_ok:
    out {serial_available},A
    out {serial_available},A
    in {serial},A
    out {serial_available},A
    cmp 'O'
    jr modem_check_command_ok_fail_,nZ
    in {serial},A
    out {serial_available},A
    cmp 'K'
    jr modem_check_command_ok_fail_,nZ
    ldr $0,A ; Set Zero flag
    jr modem_check_command_ok_done_
modem_check_command_ok_fail_:
    ldr $1,A ; Clear Zero flag
modem_check_command_ok_done_:
    ret


; Send a string at [HL] to the connected client
; Returns a 1 in A if not successful, sets Zero flag accordingly
modem_send_string:
    push H
    push L
    lda at_command_send_data
    jsr modem_send_command
    pop L
    pop H
    jsr modem_check_command_ok
    jr modem_send_string_send_,Z
    ldr $1,A
    ret
modem_send_string_send_:
    jsr print_string_extended
    ldr '\\',A
    out {serial},A
    ldr '0',A
    out {serial},A
    ldr $0,A
    ret


; Attempt to receive a string from a client into [modem_received_string]
; Returns a 1 in A if not successful, sets Zero flag accordingly
modem_receive_string:
    push H
    push L

; Find received string message
modem_receive_string_find_:
    in {serial_available},A
    jr modem_receive_string_fail_,Z
    in {serial},A
    out {serial_available},A
    cmp '+'
    jr modem_receive_string_find_,nZ
    in {serial},A
    out {serial_available},A
    cmp 'I'
    jr modem_receive_string_find_,nZ
    in {serial},A
    out {serial_available},A
    cmp 'P'
    jr modem_receive_string_find_,nZ
    in {serial},A
    out {serial_available},A
    cmp 'D'
    jr modem_receive_string_find_,nZ

; Find start of received string
modem_receive_string_start_:
    in {serial_available},A
    jr modem_receive_string_fail_,Z
    in {serial},A
    out {serial_available},A
    cmp ':'
    jr modem_receive_string_start_,nZ

; Skip if first byte is 0xFF, to skip connection message
    in {serial},A
    cmp $FF
    jr modem_receive_string_start_,Z

; Store string to [modem_received_string]
    lda modem_received_string
modem_receive_string_store_:
    in {serial_available},A
    jr modem_receive_string_fail_,Z
    in {serial},A
    cmp '\r'
    jr modem_receive_string_store_done_,Z
    out {serial_available},A
    str [HL],A
    ina
    jr modem_receive_string_store_
modem_receive_string_store_done_:
    ldr $0,A
    str [HL],A
    jr modem_receive_string_done_
modem_receive_string_fail_:
    ldr $1,A
modem_receive_string_done_:

    pop L
    pop H
    ret


; Query the modem's ip and store the resulting string in [modem_ip]
; Sets the Zero flag on success
; Uses delays
modem_get_ip:
    push A
    push B
    push H
    push L

    lda at_command_sta_info
    jsr modem_send_command
    jr modem_get_ip_failed_,nZ

; Clear next 14 characters in response
    ldr #14,A
modem_get_ip_clear_loop_:
    out {serial_available},A
    dec A
    jr modem_get_ip_clear_loop_,nZ

; Save IP to [modem_ip]
    lda modem_ip
modem_get_ip_loop_:
    in {serial_available},A
    jr modem_get_ip_failed_,Z
    in {serial},A
    out {serial_available},A
    cmp '"'
    jr modem_get_ip_done_success_,Z
    str [HL],A
    ina
    jr modem_get_ip_loop_
modem_get_ip_done_success_:
    ldr $0,A
    str [HL],A

    ldr $0,B ; Set Zero Flag
    jr modem_get_ip_done_
modem_get_ip_failed_:
    ldr $1,B ; Clear Zero Flag
modem_get_ip_done_:

    pop L
    pop H
    pop B
    pop A
    ret


    data
; The modem's IP. Call modem_get_ip to populate this.
modem_ip: var[33]
; The last string received from a client, invalid after a failed call to modem_receive_string
modem_received_string: var[246]
