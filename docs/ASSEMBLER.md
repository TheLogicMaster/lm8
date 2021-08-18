# LM-8 Assembler
The assembler is implemented as a Python 3.8 script that assembles programs into machine code binaries
using its command line interface. Run the script without parameters to see the help message. It's primarily
meant to be run by the Jetbrains plugin or the `assemble.sh` script.

## Specifications
- Only string and character literals are case-sensitive.
- Operands must be comma separated and trailing commas aren't allowed.
### Assembler Origin
The `ORG` assembler directive tells the assembler where to place generated machine code in the generated
ROM binary. There are no checks to ensure that later origin changes in the program don't overwrite 
previously generate machine code, so verify the resulting binary in the emulator using the ROM viewer and 
the disassembler.
### Label Definitions
Labels are defined simply by a chain of word characters (numbers, letters, and underscores) followed by 
a colon. Label definitions must be unique, but can be defined after usages in instruction operands. Labels
can be either by themselves or on the same line as an instruction.
### Relative Jumps
`JR` instructions take either a label or a signed immediate for the number to add to the program
counter relative to the address of the instruction following said `JR`. Thus, `JR #-2` is an
infinite loop. If the distance to the label address from the jump exceeds the size of a signed byte,
the program will fail to assemble.
### Operand Types
#### Immediate Values
Hexadecimal, decimal, and binary values can be used for immediate parameters using the prefixes `$`, `#`, 
and `%`, respectively. Character literals can also be used for immediate operands. Using `=` before a 
label with an address of `$FF` or less will provide the address of said label, primarily for printing 
strings. Decimal immediates can also be negative and the value will be stored correctly.
#### Registers
The four program registers can be specified using their respective letters: `A`, `B`, `H`, and `L`.
#### Addresses
Address parameters take either a label or a 16-bit hexadecimal address. Load and Store instructions require
square brackets around the address parameter.
#### Variable Addressing
The `LDR`, `STR`, and `JMP` instructions accept `HL` in place of an address to use the `HL` register as the
address.
#### Conditions
For `JR` instructions, there is an optional conditional parameter that determines whether the jump will 
occur. These correspond to the four CPU flags: `Z`, `C`, `N`, and `V`. To invert the condition, prefix the
flag with an `n`.
#### String and Character Literals
String literals act like in most other languages where you have a quoted string of characters. Character
literals use single quotes. Both types support Python style escaped characters.
### Comments
Comments are signified by the presence of a semicolon in a line. Anything after said semicolon will be
ignored by the assembler.
### Program Constants
Constants can be defined in programs using the `DEF` assembler directive in addition to the default 
constants for ports, time units, and peripherals. Constants can be redefined, and the last value assigned
will be the actual value when evaluated as an instruction parameter. Constants are accessed by surrounding
the constant name with curley brackets.
### Program Variables
Variables get assigned memory addresses sequentially starting at 0x8000 in the order of the `VAR` 
declarations in the program data section. The `DATA` assembler directive tells the assembler that any
instructions after it are variables. Variables can also be arrays of any size. Labels pointing to the `VAR`
assembler directives will point to the variable memory addresses.
### Program Includes
Additional assembly programs can be included into other programs to reuse functionality. Includes are 
recursively processed, so the machine code for the included file will be inserted at the `INCLUDE`
instruction's position. Variables in an included file get assigned addresses before the program that 
included it. Label names must be unique between all included files. Circular dependencies are not allowed.
### Program Binary Injection
The `BIN` assembly directive reads all bytes from a specified file and inserts them at the current assembler
origin. This reads the target file in binary mode, so the raw bytes from the file are what is read.

## Manual Usage
To assemble a program manually from the command line, enter the directory with the program and run:
```bash
# If using the repo project structure, just use ".." in place of <ASSEMBLER_DIR>
# Otherwise, just use the actual path to the assembler for the first parameter
# Replace <PROGRAM>.asm with the actual program name
python3 <ASSEMBLER_DIR>/assembler.py <PROGRAM>.asm
```
The ROM will be placed in the created `build` folder in the working directory. To run the rom, just
run the Emulator and open the ROM binary file. 

## Automatic Usage
The `assemble.sh` script can be run to assemble all assembly files in the programs directory. The Jetbrains
plugin can automatically generate run configurations that assemble and run programs in the emulator.

## Optional Parameters
- --run (-r): Run the assembled program with the compiled emulator.
- --fpga (-f) <none|patch|flash>: Patch the FPGA ROM code with the assembled binary and or flash the FPGA.
- --emulator (-e): Specify the path to the compiled emulator if not using the default project structure
- --simulator (-s): Specify the path to the `simulation` directory if not using the default project structure