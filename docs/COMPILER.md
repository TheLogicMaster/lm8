# LM-8 C Compiler

## Background
C compiler support is provided by a custom backend written for the VBCC compiler. This is only intended
to be used as a proof-of-concept, as the LM-8 architecture is not well suited for supporting C and the
generated assembly code is huge, easily ten times as much as would be expected due to the challenge of
performing 16-bit operations using only four registers. 

## Usage
- The [VBCC](http://www.compilers.de/vbcc.html) compiler source are required to be extracted to the `vbcc`
directory.
- Build the compiler from the `vbcc` directory: `make TARGET=lm8 bin/vbcclm8`
- Compile a C program from the `programs` directory: `../vbcc/bin/vbcclm8 <program>.c`
- Assemble the produced assembly file per usual.
