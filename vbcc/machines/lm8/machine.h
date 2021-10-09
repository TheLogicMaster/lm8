/*  LM-8 backend for vbcc

*/

#include "dt.h"

/*  This struct can be used to implement machine-specific           */
/*  addressing-modes.                                               */
struct AddressingMode{
  int never_used;
};

/*  The number of registers of the target machine.                  */
#define MAXR 0

/*  Number of commandline-options the code-generator accepts.       */
#define MAXGF 1

/*  If this is set to zero vbcc will not generate ICs where the     */
/*  target operand is the same as the 2nd source operand.           */
/*  This can sometimes simplify the code-generator, but usually     */
/*  the code is better if the code-generator allows it.             */
#define USEQ2ASZ 1

/*  This specifies the smallest integer type that can be added to a */
/*  pointer.                                                        */
#define MINADDI2P CHAR

/*  If the bytes of an integer are ordered most significant byte    */
/*  byte first and then decreasing set BIGENDIAN to 1.              */
#define BIGENDIAN 1

/*  If the bytes of an integer are ordered lest significant byte    */
/*  byte first and then increasing set LITTLEENDIAN to 1.           */
#define LITTLEENDIAN 0

/*  Note that BIGENDIAN and LITTLEENDIAN are mutually exclusive.    */

/*  If switch-statements should be generated as a sequence of       */
/*  SUB,TST,BEQ ICs rather than COMPARE,BEQ ICs set this to 1.      */
/*  This can yield better code on some machines.                    */
#define SWITCHSUBS 0

/*  In optimizing compilation certain library memcpy/strcpy-calls   */
/*  with length known at compile-time will be inlined using an      */
/*  ASSIGN-IC if the size is less or equal to INLINEMEMCPY.         */
/*  The type used for the ASSIGN-IC will be UNSIGNED|CHAR.          */
#define INLINEMEMCPY 0

/*  Parameters on the stack should be pushed in reverse order   */
#define ORDERED_PUSH 0

/*  We have some target-specific variable attributes.               */
//#define HAVE_TARGET_ATTRIBUTES

/* We have target-specific pragmas */
//#define HAVE_TARGET_PRAGMAS

/* size of buffer for asm-output, this can be used to do
   peephole-optimizations of the generated assembly-output */
#define EMIT_BUF_LEN 2048 /* should be enough */
/* number of asm-output lines buffered */
#define EMIT_BUF_DEPTH 8

/* Use unsigned int as size_t */
#define HAVE_INT_SIZET 1

/* Convert multiplications/division by powers of two to shifts */
#define HAVE_POF2OPT 1

/* Prefer BNE rather than BGT. */
#define HAVE_WANTBNE 1
