# LM-8 Architecture

## Specifications
- 8-bit (Obviously)
- 16-bit big-endian addressing
- Only 28 unique instructions
- 4 program registers
- Programmable CPU microcode

## Memory Map
- 0x0000 - 0x7FFF: Program ROM
- 0x8000 - 0xFEFF: Program RAM
- 0xFF00 - 0xFFFF: Stack

## Microcode
The `microcode.py` script generates the `microcode.bin` binary which controls the CPU. It works
by specifying which wires should be high or low based on which state of which instruction is
currently active in the CPU. There are 64 possible instructions, with each instruction having upto
6 states, with each state occupying 3 bytes or 24 wires.

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
|LDR imm,reg|000001rr|reg = imm|Z***|2|
|LDR [addr],reg|000010rr|reg = [addr]|Z***|5|
|LDR [HL],reg|000011rr|reg = [HL]|Z***|3|
|STR [addr],reg|000100rr|[addr] = reg|****|4|
|STR [HL],reg|000101rr|[HL] = reg|****|2|
|LDA addr|000110**|HL = addr|****|3|
|IN imm,reg|000111rr|reg = PORT[imm]|Z***|3|
|OUT imm,reg|001000rr|PORT[imm] = reg|****|3+|
|INC reg|001001rr|reg = reg + 1|ZC**|1|
|DEC reg|001010rr|reg = reg - 1|ZC**|1|
|INA|001011**|HL = HL + 1|****|2 or 3|
|DEA|001100**|HL = HL - 1|****|2 or 3|
|ADD imm|001101**|A = A + imm|ZCNV|3|
|ADD reg|001110rr|A = A + reg|ZCNV|1|
|ADC imm|001111**|A = A + imm + C|ZCNV|3|
|ADC reg|010000rr|A = A + reg + C|ZCNV|1|
|SUB imm|010001**|A = A - imm|ZCNV|3|
|SUB reg|010010rr|A = A - reg|ZCNV|1|
|SBC imm|010011**|A = A - imm - C|ZCNV|3|
|SBC reg|010100rr|A = A - reg - C|ZCNV|1|
|AND imm|010101**|A = A & imm|Z***|3|
|AND reg|010110rr|A = A & reg|Z***|1|
|OR imm|010111**|A = A &#124; imm|Z***|3|
|OR reg|011000rr|A = A &#124; reg|Z***|1|
|XOR imm|011001**|A = A ^ imm|Z***|3|
|XOR reg|011010rr|A = A ^ reg|Z***|1|
|CMP imm|011011**|A - imm|ZCNV|3|
|CMP reg|011100rr|A - reg|ZCNV|1|
|JMP addr|011101**|PC = addr|****|4|
|JMP HL|011110**|PC = HL|****|1|
|JR rel|011111**|PC = PC + rel|****|3|
|JR rel,cc|100000cc|If cc, PC = PC + rel|****|3 or 4|
|JR rel,nn|100001nn|If nn, PC = PC + rel|****|3 or 4|
|IN reg|100010rr|reg = PORT[A]|Z***|3|
|OUT reg|100011rr|PORT[A] = reg|****|3+|
|PUSH reg|100100rr|[--SP] = reg|****|2|
|POP reg|100101rr|reg = [SP++]|****|3|
|JSR addr|100110**|SP = SP - 2, [SP] = PC|****|6|
|RET|100111**|PC = [SP], SP = SP + 2|****|6|
|HALT|101000**|Halt CPU|****|2|
### Key:
- __*__: Unused
- __rr__: Register (__A__, __B__, __H__, or __L__)
- __cc__: Condition (__Z__, __C__, __N__, or __V__)
- __nn__: Condition Inverse (__nZ__, __nC__, __nN__, or __nV__)
- __imm__: 8-bit Immediate (%10101010, #255, #-90, $FF, or '\n')
- __rel__: Relative Distance (Label or signed 8-bit immediate)
- __addr__: Address (Label or 16-bit immediate)
### Cycle Exceptions
- `OUT` instructions can take any number more than 3 cycles based on the port selected.
- `JR` instructions with conditions take 3 if the condition failed and 4 otherwise.
- `INA` and `DEA` instructions take an extra cycle if `L` rolls around and changes `H`.
