# LM-8 Assembly Programming

## Code Style
This is the code style used in the example programs, libraries, and by the Jetbrains Plugin 
auto-formatting for consistency.
### Label Naming 
Labels aren't case-sensitive, but all lowercase names should be used. For labels used in
subroutines, they should be the subroutine name with a descriptive suffix added with a trailing 
underscore. Any label that ends with an underscore won't be included in the IDE auto-complete
suggestions, so that should be preferred for non-public variables and locations.
### Label Placement
Labels should generally be placed at the start of a line with instructions following at
the next line. In the case of single `DB` directives and single byte variable directives, the labels 
should generally be placed in the same line as the directive.
### Subroutine Spacing
Subroutines should have two blank lines above and below to differentiate between 
subroutine boundaries and intra-subroutine organizational spacing. A blank line should be present after
the register push declarations and before those pushed registers are popped from the stack. Additional
spaces should be present, potentially with comments, to organize the different tasks the subroutine
accomplishes. 
### Comments
No spaces should be present before comments on blank lines, but a space should be present if the comment 
is on the same line as an instruction. Comments on consecutive lines preceding a label will be treated as 
documentation and shown when hovering over a reference to said label in an IDE.
### Documentation
Each assembly file should have a comment at the top of the file describing its purpose. Subroutines
should have comments directly before the label which thoroughly describe the function of the routine
and which registers and variables are modified by it. Publicly facing variables in libraries should
be commented to describe their function.
### Subroutine Mutability
Subroutines should explicitly state any registers and variables that they modify. Any useful CPU flags
that are set should be mentioned, otherwise it's assuming that the flags could have any value. Subroutines
should modify only registers that return values, otherwise any registers that are modified during the
subroutine should be pushed and popped from the stack to preserve their previous values. Temporary
variables don't need to be mentioned.
### Include Placement
When possible, include directives should be placed near the top of a file for the sake of organization.
This may present an issue if using 8-bit addressing, since included assembly data gets inserted directly
at the include directive. 
### Constant Data and Binary placement
Small constant definitions like strings should go at the top of the program under the includes, but large
blocks of data like injected binary files should go at the end of the program before the data section.

## Common Issues
- Assembly programs always begin execution at the top of the program, so ensure that there is a jump
  instruction before any constants or includes at the top of the file or they will be treated as the
  start of the program and executed, leading to unexpected behavior.
- End each program with a `HALT` instruction or an infinite loop or the program counter will "escape"
  and execute whatever happens to be in ROM after that point and then whatever is in RAM, at which point
  it will likely roll over and return to the start of the program. If the program seems to restart
  constantly, this is likely the cause.
- Ensure that the number pushes and pops to the stack in a subroutine are equal, or the wrong return
  address will be pulled from the stack, and the behavior will be completely unpredictable. An easy
  way to determine that this is occurring would be to look at the stack pointer in the emulator and it
  will likely be going crazy and constantly rolling over. Any timers or delays that are used should be
  stated to avoid conflicts.
- If using the `ORG` directive, ensure that there is no overlap with other code regions to avoid 
  the assembler overwriting other data with unpredictable results. This could occur due to a region
  expanding after modifying a library included in said region.
  
## Tips
- Since there are only 4 registers, two of which are used for 16-bit addressing, the Stack is your
  best friend. There aren't register transfer instructions, so push from one register and pop to
  another to accomplish that. If you need to perform an operation with a specific register like `A`
  but need to later use that value, simply push the value to the stack and pop it back after
  performing said operation. This technique is more convenient than using a temporary variable, but
  is limited in that the operation performed has to end without changing the stack pointer.
- If you need to create a loop that repeats a multiple of 256 times, you can simply accomplish
 this as follows:
```assembly
    ldr #10,A
    ldr $0,B
loop:
    nop ; This line would be called 256 * 10 times
    dec B
    jr loop,nZ ; Inner loop
    dec A
    jr loop,nZ ; Outer loop
```
