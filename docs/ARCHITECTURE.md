# LM-8 Architecture
The architectural design of this computer was heavily influenced by classic 8-bit processors
like the 6502. 

## Specifications
- 8-bit (Obviously)
- 16-bit big-endian addressing
- Only 27 unique instructions
- 4 8-bit general program registers
- 4-bit status register
- Programmable CPU microcode
- 32 KB of both ROM and RAM
- 160x128 display output with sprite rendering and double buffering

## Memory Map
- 0x0000 - 0x7FFF: Program ROM
- 0x8000 - 0xFEFF: Program RAM
- 0xFF00 - 0xFFFF: Stack

## Microcode
The `microcode.py` script generates the `microcode.bin` binary which controls the CPU. It works
by specifying which wires should be high or low based on which state of which instruction is
currently active in the CPU. There are 64 possible instructions, with each instruction having upto
6 states, with each state occupying 3 bytes or 24 wires.

## CPU Flags
- `Z`: The Zero flag, set if the result of an instruction is zero.
- `C`: The Carry flag, set if there is a carry or borrow during an instruction.
- `N`: The Negative flag, set if the signed result of an instruction is negative.
- `V`: The Overflow flag, set if a signed overflow takes place during an instruction.

## Instructions
|Instruction|Machine Code|Function|Flags (ZCNV)|Cycles|
|-----------|------------|--------|------------|------|
|DEF term=value|N/A|Define a program constant|N/A|N/A|
|ORG addr|N/A|Set the assembler origin|N/A|N/A|
|INCLUDE|N/A|Include an assembly file|N/A|N/A|
|DATA|N/A|Enter the data section|N/A|N/A|
|VAR|N/A|A variable placeholder|N/A|N/A|
|VAR[n]|N/A|A variable array placeholder|N/A|N/A|
|DB "HI",'\n',$0|N/A|Define bytes|N/A|N/A|
|BIN|N/A|Inject a binary file|N/A|N/A|
|NOP|000000**|No operation|****|1|
|LDR imm,reg|000001rr|reg = imm|Z***|3|
|LDR [addr],reg|000010rr|reg = [addr]|Z***|7|
|LDR [HL],reg|000011rr|reg = [HL]|Z***|3|
|STR [addr],reg|000100rr|[addr] = reg|****|6|
|STR [HL],reg|000101rr|[HL] = reg|****|2|
|LDA addr|000110**|HL = addr|****|5|
|IN imm,reg|000111rr|reg = PORT[imm]|Z***|4|
|OUT imm,reg|001000rr|PORT[imm] = reg|****|4+|
|INC reg|001001rr|reg = reg + 1|ZC**|1|
|DEC reg|001010rr|reg = reg - 1|ZC**|1|
|INA|001011**|HL = HL + 1|****|2 or 3|
|DEA|001100**|HL = HL - 1|****|2 or 3|
|ADD imm|001101**|A = A + imm|ZCNV|4|
|ADD reg|001110rr|A = A + reg|ZCNV|1|
|ADC imm|001111**|A = A + imm + C|ZCNV|4|
|ADC reg|010000rr|A = A + reg + C|ZCNV|1|
|SUB imm|010001**|A = A - imm|ZCNV|4|
|SUB reg|010010rr|A = A - reg|ZCNV|1|
|SBC imm|010011**|A = A - imm - C|ZCNV|4|
|SBC reg|010100rr|A = A - reg - C|ZCNV|1|
|AND imm|010101**|A = A & imm|Z***|4|
|AND reg|010110rr|A = A & reg|Z***|1|
|OR imm|010111**|A = A &#124; imm|Z***|4|
|OR reg|011000rr|A = A &#124; reg|Z***|1|
|XOR imm|011001**|A = A ^ imm|Z***|4|
|XOR reg|011010rr|A = A ^ reg|Z***|1|
|CMP imm|011011**|A - imm|ZCNV|4|
|CMP reg|011100rr|A - reg|ZCNV|1|
|JMP addr|011101**|PC = addr|****|6|
|JMP HL|011110**|PC = HL|****|1|
|JR rel|011111**|PC = PC + rel|****|4|
|JR rel,cc|100000cc|If cc, PC = PC + rel|****|4 or 5|
|JR rel,nn|100001nn|If nn, PC = PC + rel|****|4 or 5|
|IN reg|100010rr|reg = PORT[A]|Z***|3|
|OUT reg|100011rr|PORT[A] = reg|****|3+|
|PUSH reg|100100rr|[--SP] = reg|****|2|
|POP reg|100101rr|reg = [SP++]|****|3|
|JSR addr|100110**|SP = SP - 2, [SP] = PC|****|8|
|RET|100111**|PC = [SP], SP = SP + 2|****|6|
|HALT|101000**|Halt CPU|****|2|
|LSL|101001**|C <-- reg <-- 0|ZC**|1|
|LSR|101010**|0 --> reg --> C|ZC**|1|
|ASR|101011**|reg[7] --> reg --> C|ZC**|1|
### Key:
- __*__: Unused
- __rr__: Register (__A__, __B__, __H__, or __L__)
- __cc__: Condition (__Z__, __C__, __N__, or __V__)
- __nn__: Condition Inverse (__nZ__, __nC__, __nN__, or __nV__)
- __imm__: 8-bit Immediate (%10101010, #255, #-90, $FF, or '\n')
- __rel__: Relative Distance (Label or signed 8-bit immediate)
- __addr__: Address (Label or 16-bit immediate)
### Cycle Exceptions
- `OUT` instructions can take any number more than 4 cycles based on the port selected.
- `JR` instructions with conditions take 4 if the condition failed and 5 otherwise.
- `INA` and `DEA` instructions take an extra cycle if `L` rolls around and changes `H`.

## I/O Ports
For binary ports, reading will return a 0 or 1 and writing anything but a 0 is seen as a 1.

|Port|Id(s)|Function|
|----|-----|--------|
|serial|0|Output a character to the console or UART, read to get UART input|
|serial_available|1|Read to get available UART bytes, write to pop a value|
|seven_segment_n|2-7|Access seven segment display register n (0-5)|
|button_n|8-9|Read the binary state of button n (0-1)|
|led_n|10-19|Read or write to LED n (0-9)|
|switch_n|20-29|Read the binary state of switch n (0-9)|
|graphics_x|30|Access the graphics X register|
|graphics_y|31|Access the graphics Y register|
|draw_pixel|32|Draws a single RGB332 pixel at (X,Y)|
|draw_sprite|33|Draws an 8x8 RGB332 sprite from the address (HL) at (X,Y)|
|clear_screen|34|Clears the screen with the specified RGB332 color|
|gpio_n|35-70|Access GPIO pin n (0-35)|
|arduino_n|71-86|Access Arduino header I/O pin n (0-15)|
|adc_n|87-92|Read from ADC n (0-6)|
|rand|93|Read a random number|
|swap_display|94|Swap the emulator display buffers|
|gpio_output|95|Set the specified GPIO pin to output mode (0-35)|
|gpio_input|96|Set the specified GPIO pin to input mode (0-35)|
|arduino_output|97|Set the Arduino pin (value & 0xF) to output mode (0-15)|
|arduino_input|98|Set the Arduino pin (value & 0xF) to input mode (0-15)|
|pwm_enable|99|Enable PWM for a compatible Arduino pin (3, 5, 6, 9, 10, 11)|
|pwm_disable|100|Disable PWM for a compatible Arduino pin (3, 5, 6, 9, 10, 11)|
|pwm_n|101-106|Set the PWM duty cycle for compatible pin n (3, 5, 6, 9, 10, 11)|
|serial_enable|107|Enables or disables the UART output, TX, on Arduino pin 1|
|timer_unit_n|108-109|Sets the timer count of timer n (0-1) to (50 * 10 ^ value) (0-7)|
|timer_count_n|110-111|Sets the count multiplier for timer n (0-1)|
|timer_n|112-113|Returns whether timer n (0-1) has triggered, write to reset timer|