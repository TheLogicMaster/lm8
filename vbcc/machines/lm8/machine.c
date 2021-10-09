/*  LM-8 backend for vbcc
    (c) Justin Marentette 2021

*/

#include "supp.h"

static char FILE_[] = __FILE__;

/*  Public data that MUST be there.                             */

/* Name and copyright. */
char cg_copyright[] = "vbcc LM-8 code-generator V0.1 (c) in 2021 by Justin Marentette";

/*  Commandline-flags the code-generator accepts:
    0: just a flag
    VALFLAG: a value must be specified
    STRINGFLAG: a string can be specified
    FUNCFLAG: a function will be called
    apart from FUNCFLAG, all other versions can only be specified once */
int g_flags[MAXGF] = {0};

/* the flag-name, do not use names beginning with l, L, I, D or U, because
   they collide with the frontend */
char *g_flags_name[MAXGF] = {""};

/* the results of parsing the command-line-flags will be stored here */
union ppi g_flags_val[MAXGF];

/*  Alignment-requirements for all types in bytes.              */
zmax align[MAX_TYPE + 1];

/*  Alignment that is sufficient for every object.              */
zmax maxalign;

/*  CHAR_BIT for the target machine.                            */
zmax char_bit;

/*  sizes of the basic types (in bytes) */
zmax sizetab[MAX_TYPE + 1];

/*  Minimum and Maximum values each type can have.              */
/*  Must be initialized in init_cg().                           */
zmax t_min[MAX_TYPE + 1];
zumax t_max[MAX_TYPE + 1];
zumax tu_max[MAX_TYPE + 1];

/*  Names of all registers. will be initialized in init_cg(),
    register number 0 is invalid, valid registers start at 1 */
char *regnames[MAXR + 1];

/*  The Size of each register in bytes.                         */
zmax regsize[MAXR + 1];

/*  a type which can store each register. */
struct Typ *regtype[MAXR + 1];

/*  regsa[reg]!=0 if a certain register is allocated and should */
/*  not be used by the compiler pass.                           */
int regsa[MAXR + 1];

/*  Specifies which registers may be scratched by functions.    */
int regscratch[MAXR + 1];

/****************************************/
/*  Private data and functions.         */
/****************************************/

/* alignment of basic data-types, used to initialize align[] */
static long malign[MAX_TYPE + 1] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
/* sizes of basic data-types, used to initialize sizetab[] */
static long msizetab[MAX_TYPE + 1] = {1, 1, 2, 2, 4, 8, 4, 4, 4, 0, 2, 3, 3, 0, 0, 0, 1, 0};
static char *mregnames[MAXR + 1];

// Boolean for genreating header once
static int headerGen;
// The current section, 1 for data
static int section;
// The last variable head generated
static struct Var *lastVarHeadVar;
// Whether the last compare insstruction was signed or not
static int lastCompareSigned;
// Linked list for storing variable initialization data
static struct VariableInit {
    char *variable;
    int integer;
    int value;
    struct VariableInit *next;
} *variableInit;

#define ISCHAR(t) ((t&NQ)==CHAR)
#define ISSHORT(t) ((t&NQ)==SHORT||(t&NQ)==INT||(t&NQ)==POINTER)
#define ISLONG(t) ((t&NQ)==LONG)
#define ISLLONG(t) ((t&NQ)==LLONG)

// Emit a comment containing the IC
void emit_ic_comment(FILE *f, struct IC *ic) {
    emit_flush(f);
    fprintf(f, "; ");
    printic(f, ic);
}

// Emit code for a relative jump given a condition and destination label
void relative_jump(FILE *f, char* passCond, int dest) {
    int new_label = ++label;
    emit(f, "\tjr label%d, %s\n", new_label, passCond);
    emit(f, "\tjmp label%d\n", dest);
    emit(f, "label%d:\n", new_label);
}

// Get a byte particular byte from a zmax value
int get_byte(zmax val, int byte) {
    return (val >> (byte * 8)) & 0xFF;
}

// Emit code to transfer AB to HL
void transfer_ab_to_hl(FILE *f) {
    emit(f, "\tpush A\n");
    emit(f, "\tpop H\n");
    emit(f, "\tpush B\n");
    emit(f, "\tpop L\n");
}

// Emit code to transfer HL to AB
void transfer_hl_to_ab(FILE *f) {
    emit(f, "\tpush H\n");
    emit(f, "\tpop A\n");
    emit(f, "\tpush L\n");
    emit(f, "\tpop B\n");
}

// Emit code to transfer HL to AB
void swap_hl_ab(FILE *f) {
    emit(f, "\tpush A\n");
    emit(f, "\tpush B\n");
    emit(f, "\tpush H\n");
    emit(f, "\tpush L\n");
    emit(f, "\tpop B\n");
    emit(f, "\tpop A\n");
    emit(f, "\tpop L\n");
    emit(f, "\tpop H\n");
}

// Load FP + offset into HL, trashes A and B
void load_fp_offset(FILE *f, int offset) {
    emit(f, "\tldr #%d,A\n", get_byte(abs(offset), 1));
    emit(f, "\tldr #%d,B\n", get_byte(abs(offset), 0));
    emit(f, "\tldr [__fp_h],H\n");
    emit(f, "\tldr [__fp_l],L\n");
    emit(f, "\tjsr %s_double_extended\n", offset >= 0 ? "add" : "sub");
}

// Adds a signed int to the FP
void add_fp_offset(FILE *f, int amount) {
    load_fp_offset(f, amount);
    emit(f, "\tstr [__fp_h],H\n");
    emit(f, "\tstr [__fp_l],L\n");
}

// Load address of object into HL, trashes A and B
void load_address(FILE *f, int integer, obj o) {
    if (o.v->storage_class == AUTO || o.v->storage_class == REGISTER)
        load_fp_offset(f, o.v->offset - (o.v->offset < 0 && integer) + o.val.vmax);
    else {
        if (o.v->storage_class == STATIC)
            emit(f, "\tlda label%d\n", o.v->offset);
        else 
            emit(f, "\tlda _%s\n", o.v->identifier);
        if (o.val.vmax) {
            emit(f, "\tldr #%d,A\n", get_byte(o.val.vmax, 1));
            emit(f, "\tldr #%d,B\n", get_byte(o.val.vmax, 0));
            emit(f, "\tjsr add_double_extended\n");
        }
    }
}

// Store A or AB into z
void store_z(FILE *f, int integer, obj z) {
    emit(f, "\tpush A\n");
    if (integer)
        emit(f, "\tpush B\n");

    load_address(f, integer, z);

    // Dereference pointer
    if(z.flags & DREFOBJ) {
        emit(f, "\tldr [HL],A\n");
        emit(f, "\tina\n");
        emit(f, "\tldr [HL],B\n");
        transfer_ab_to_hl(f);
    }

    if (integer)
        emit(f, "\tpop B\n");
    emit(f, "\tpop A\n");

    emit(f, "\tstr [HL],A\n");
    if (integer) {
        emit(f, "\tina\n");
        emit(f, "\tstr [HL],B\n");
    }
}

// Load obj into A or AB
void load_obj(FILE *f, int integer, obj o) {
    if (o.flags & KONST) {
        if (!integer)
            emit(f, "\tldr #%d,A\n", get_byte(o.val.vmax, 0));
        else {
            emit(f, "\tldr #%d,A\n", get_byte(o.val.vmax, 1));
            emit(f, "\tldr #%d,B\n", get_byte(o.val.vmax, 0));
        }
    } else {
        load_address(f, integer, o);

        // Load address of obj instead
        if(o.flags & VARADR) {
            transfer_hl_to_ab(f);
            return;
        }

        // Dereference pointer
        if(o.flags & DREFOBJ) {
            emit(f, "\tldr [HL],A\n");
            emit(f, "\tina\n");
            emit(f, "\tldr [HL],B\n");
            transfer_ab_to_hl(f);
        }

        // Load from [HL] into A or AB
        emit(f, "\tldr [HL],A\n");
        if (integer) {
            emit(f, "\tina\n");
            emit(f, "\tldr [HL],B\n");
        }
    }
}

// Loads q1 into AB or A and q2 into HL or H
void load_q1_and_q2(FILE *f, struct IC *ic) {
    load_obj(f, ISSHORT(q1typ(ic)), ic->q2);
    emit(f, "\tpush A\n");
    emit(f, "\tpush B\n");
    load_obj(f, ISSHORT(q1typ(ic)), ic->q1);
    emit(f, "\tpop L\n");
    emit(f, "\tpop H\n");
}

// Switch code sections if not in the desired one
void ensure_section(FILE *f, int dataSection) {
    if (section != dataSection) {
        if (dataSection == 0)
            emit(f, "\trodata\n");
        else
            emit(f, "\tdata\n");
    }

    section = dataSection;
}

// Create the assembler file header code if not created already
void header(FILE *f) {
    if (headerGen)
        return;

    emit(f, "; Generated LM-8 Assembly Program\n\n");
    emit(f, "; Run initialization code\n");
    emit(f, "\tjmp __initialize\n\n");
    
    // Todo: Move stack to end of memory
    emit(f, "; Virtual stack\n");
    ensure_section(f, 1);
    emit(f, "__fp_h: var\n");
    emit(f, "__fp_l: var\n");
    ensure_section(f, 0);

    emit(f, "; Library includes\n");
    emit(f, "\tinclude \"libraries/Math.asm\"\n");
    emit(f, "\tinclude \"libraries/Serial.asm\"\n\n");
    
    emit(f, "; Built-in print function\n");
    emit(f, "print:\n");
    emit(f, "\tldr [__fp_h],H\n");
    emit(f, "\tldr [__fp_l],L\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],B\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    transfer_ab_to_hl(f);
    emit(f, "\tjsr print_string_extended\n");
    emit(f, "\tret\n\n");
    
    emit(f, "; Built-in port draw_sprite function\n");
    emit(f, "draw_sprite:\n");
    emit(f, "\tldr [__fp_h],H\n");
    emit(f, "\tldr [__fp_l],L\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    emit(f, "\tout {graphics_x},A\n");
    emit(f, "\tdea\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    emit(f, "\tout {graphics_y},A\n");
    emit(f, "\tdea\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],B\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    transfer_ab_to_hl(f);
    emit(f, "\tout {draw_sprite},A\n");
    emit(f, "\tret\n\n");
    
    emit(f, "; Built-in port draw_pixel function\n");
    emit(f, "draw_pixel:\n");
    emit(f, "\tldr [__fp_h],H\n");
    emit(f, "\tldr [__fp_l],L\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    emit(f, "\tout {graphics_x},A\n");
    emit(f, "\tdea\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    emit(f, "\tout {graphics_y},A\n");
    emit(f, "\tdea\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    emit(f, "\tout {draw_pixel},A\n");
    emit(f, "\tret\n\n");

    emit(f, "; Built-in port write function\n");
    emit(f, "write:\n");
    emit(f, "\tldr [__fp_h],H\n");
    emit(f, "\tldr [__fp_l],L\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    emit(f, "\tdea\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],B\n");
    emit(f, "\tout B\n");
    emit(f, "\tret\n\n");
    
    emit(f, "; Built-in port read function\n");
    emit(f, "read:\n");
    emit(f, "\tldr [__fp_h],H\n");
    emit(f, "\tldr [__fp_l],L\n");
    emit(f, "\tdea\n");
    emit(f, "\tdea\n");
    emit(f, "\tdea\n");
    emit(f, "\tldr [HL],A\n");
    emit(f, "\tin B\n");
    emit(f, "\tina\n");
    emit(f, "\tpush H\n");
    emit(f, "\tldr [HL],H\n");
    emit(f, "\tina\n");
    emit(f, "\tldr [HL],L\n");
    emit(f, "\tpop H\n");
    emit(f, "\tldr $0,A\n");
    emit(f, "\tstr [HL],A\n");
    emit(f, "\tina\n");
    emit(f, "\tstr [HL],B\n");
    emit(f, "\tret\n\n");

    emit(f, "; Copies [__copy_bytes_h][__copy_bytes_l] bytes from HL to AB, trashes __copy_bytes and registers\n");
    ensure_section(f, 1);
    emit(f, "__copy_bytes_h: var\n");
    emit(f, "__copy_bytes_l: var\n");
    emit(f, "__copy_memory_dest_h_: var\n");
    emit(f, "__copy_memory_dest_l_: var\n");
    ensure_section(f, 0);
    emit(f, "__copy_memory:\n");
    emit(f, "\tstr [__copy_memory_dest_h_],A\n");
    emit(f, "\tstr [__copy_memory_dest_l_],B\n");
    emit(f, "__copy_memory_loop_:\n");
    emit(f, "\tpush H\n");
    emit(f, "\tpush L\n");
    emit(f, "\tldr $0,A\n");
    emit(f, "\tldr [__copy_bytes_h],H\n");
    emit(f, "\tldr [__copy_bytes_l],L\n");
    emit(f, "\tcmp H\n");
    emit(f, "\tjr __copy_memory_not_done_,nZ\n");
    emit(f, "\tcmp L\n");
    emit(f, "\tjr __copy_memory_not_done_,nZ\n");
    emit(f, "\tpop L\n");
    emit(f, "\tpop H\n");
    emit(f, "\tjr __copy_memory_done_\n");
    emit(f, "__copy_memory_not_done_:\n");
    emit(f, "\tdea\n");
    emit(f, "\tstr [__copy_bytes_h],H\n");
    emit(f, "\tstr [__copy_bytes_l],L\n");
    emit(f, "\tpop L\n");
    emit(f, "\tpop H\n");
    emit(f, "\tldr [HL],A\n");
    emit(f, "\tpush H\n");
    emit(f, "\tpush L\n");
    emit(f, "\tldr [__copy_memory_dest_h_],H\n");
    emit(f, "\tldr [__copy_memory_dest_l_],L\n");
    emit(f, "\tstr [HL],A\n");
    emit(f, "\tina\n");
    emit(f, "\tstr [__copy_memory_dest_h_],H\n");
    emit(f, "\tstr [__copy_memory_dest_l_],L\n");
    emit(f, "\tpop L\n");
    emit(f, "\tpop H\n");
    emit(f, "\tina\n");
    emit(f, "\tjr __copy_memory_loop_\n");
    emit(f, "__copy_memory_done_:\n");
    emit(f, "\tret\n");

    emit(f, "\n");

    headerGen = 1;
}

// Find the next Call IC after the current ic
struct IC *get_next_call(struct IC *ic) {
    while (ic = ic->next)
        if (ic->code == CALL)
            return ic;
    return NULL;
}

// Returns true if the next Call IC after the current ic has a return value
int next_call_has_return(struct IC *ic) {
    ic = get_next_call(ic);
    return ic->next && ic->next->code == GETRETURN;
}

/****************************************/
/*  End of private data and functions.  */
/****************************************/

/*  Does necessary initializations for the code-generator. Gets called  */
/*  once at the beginning and should return 0 in case of problems.      */
int init_cg(void) {
    maxalign = l2zm(1L);
    char_bit = l2zm(8L);
    stackalign = l2zm(1L);

    for (int i = 0; i <= MAX_TYPE; i++) {
        sizetab[i] = l2zm(msizetab[i]);
        align[i] = l2zm(malign[i]);
    }

    mregnames[0] = regnames[0] = "noreg";

    /*  Initialize the min/max-settings. Note that the types of the     */
    /*  host system may be different from the target system and you may */
    /*  only use the smallest maximum values ANSI guarantees if you     */
    /*  want to be portable.                                            */
    /*  That's the reason for the subtraction in t_min[INT]. Long could */
    /*  be unable to represent -2147483648 on the host system.          */
    t_min[CHAR] = l2zm(-128L);
    t_min[SHORT] = l2zm(-32768L);
    t_min[LONG] = zmsub(l2zm(-2147483647L), l2zm(1L));
    t_min[INT] = t_min(SHORT);
    t_min[LLONG] = zmlshift(l2zm(1L), l2zm(63L));
    t_min[MAXINT] = t_min(LLONG);
    t_max[CHAR] = ul2zum(127L);
    t_max[SHORT] = ul2zum(32767UL);
    t_max[LONG] = ul2zum(2147483647UL);
    t_max[INT] = t_max(SHORT);
    t_max[LLONG] = zumrshift(zumkompl(ul2zum(0UL)), ul2zum(1UL));
    t_max[MAXINT] = t_max(LLONG);
    tu_max[CHAR] = ul2zum(255UL);
    tu_max[SHORT] = ul2zum(65535UL);
    tu_max[LONG] = ul2zum(4294967295UL);
    tu_max[INT] = t_max(UNSIGNED | SHORT);
    tu_max[LLONG] = zumkompl(ul2zum(0UL));
    tu_max[MAXINT] = t_max(UNSIGNED | LLONG);

    for (int i = 1; i <= 5; i++)
        regscratch[i] = 1;

    variableInit = NULL;
    section = 0;
    headerGen = 0;
    lastCompareSigned = 0;

    return 1;
}

/* If debug-information is requested, this functions is called after init_cg(), but
 * before any code is generated.*/
void init_db(FILE *f) {
}

/*  Returns the register in which variables of type t are returned. */
/*  If the value cannot be returned in a register returns 0.        */
/*  A pointer MUST be returned in a register. The code-generator    */
/*  has to simulate a pseudo register if necessary.                 */
int freturn(struct Typ *t) {
    return 0;
}

/* Returns 0 if the register is no register pair. If r  */
/* is a register pair non-zero will be returned and the */
/* structure pointed to p will be filled with the two   */
/* elements.                                            */
int reg_pair(int r, struct rpair *p) {
    return 0;
}

/*  Returns 0 if register r cannot store variables of   */
/*  type t. If t==POINTER and mode!=0 then it returns   */
/*  non-zero only if the register can store a pointer   */
/*  and dereference a pointer to mode.                  */
int regok(int r, int t, int mode) {
    return 0;
}

/*  Returns zero if the IC p can be safely executed     */
/*  without danger of exceptions or similar things.     */
/*  vbcc may generate code in which non-dangerous ICs   */
/*  are sometimes executed although control-flow may    */
/*  never reach them (mainly when moving computations   */
/*  out of loops).                                      */
/*  Typical ICs that generate exceptions on some        */
/*  machines are:                                       */
/*      - accesses via pointers                         */
/*      - division/modulo                               */
/*      - overflow on signed integer/floats             */
int dangerous_IC(struct IC *p) {
    return 0;
}

/*  Returns zero if code for converting np to type t    */
/*  can be omitted.                                     */
/*  On the PowerPC cpu pointers and 32bit               */
/*  integers have the same representation and can use   */
/*  the same registers.                                 */
int must_convert(int o, int t, int const_expr) {
    return 1;
}

/*  This function has to create <size> bytes of storage */
/*  initialized with zero.                              */
void gen_ds(FILE *f, zmax size, struct Typ *t) {
    header(f);

    if (section == 0) {
        emit(f, "\tdb ");
        for (int i = 0; i < size; i++) {
            if (i > 0)
                emit(f, ", ");
            emit(f, "$0");
        }
        emit(f, "\n");
    } else
        emit(f, "\tvar[%d]\n", size);
}

/*  This function has to make sure the next data is     */
/*  aligned to multiples of <align> bytes.              */
void gen_align(FILE *f, zmax align) {
    header(f);
}

/*  This function has to create the head of a variable  */
/*  definition, i.e. the label and information for      */
/*  linkage etc.                                        */
void gen_var_head(FILE *f, struct Var *v) {
    // Todo: Exclude list of built-in subroutines
    header(f);

    if(ISFUNC(v->vtyp->flags)) 
        return;

    lastVarHeadVar = v;

    ensure_section(f, !(v->clist && is_const(v->vtyp)));

    if (v->storage_class == STATIC)
        emit(f, "label%d:", v->offset);
    else if (v->storage_class == EXTERN)
        emit(f, "_%s:", v->identifier);

    if (v->clist && is_const(v->vtyp))
        emit(f, "\n");

    if (v->clist && !is_const(v->vtyp)) {
        struct const_list *last = v->clist;
        while (last->next)
            last = last->next;
        emit(f, "\tvar[%d]\n", last->idx + 1);
    }
}

/*  This function has to create static storage          */
/*  initialized with const-list p.                      */
void gen_dc(FILE *f, int typf, struct const_list *p) {
    header(f);

    struct VariableInit *init;
    if (section == 1) {
        init = mymalloc(sizeof(struct VariableInit));
        init->next = NULL;
        char *variable = mymalloc(65);
        if (lastVarHeadVar->storage_class == STATIC)
            snprintf(variable, 65, "label%d", zm2zi(lastVarHeadVar->offset));
        else if (lastVarHeadVar->storage_class == EXTERN)
            snprintf(variable, 65, "_%s", lastVarHeadVar->identifier);
        init->variable = variable;
        if (variableInit) {
            struct VariableInit *last = variableInit;
            while (last->next)
                last = last->next;
            last->next = init;
        } else
            variableInit = init;
    }
    
    switch (typf & NQ)
	{
		case CHAR:
            if (section == 0)
			    emit(f, "\tdb $%x\n", p->val.vuchar);
            else {
                init->integer = 0;
                init->value = p->val.vuchar;
            }
			break;

		case SHORT:
		case INT:
		reallyanint:
            if (section == 0)
			    emit(f, "\tdb $%x, $%x\n", p->val.vint >> 8,  p->val.vint & 0xFF);
            else {
                init->integer = 1;
                init->value = p->val.vint;
            }
			break;

		// case LONG:
		// 	emit(f, "\tdb $%x, $%x, $%x, $%x\n", p->val.vlong >> 24, (p->val.vlong >> 16) & 0xFF, (p->val.vlong >> 8) & 0xFF, p->val.vlong & 0xFF);
		// 	break;

		/*case POINTER:
			if (!p->tree)
				goto reallyanint;
			{
				struct obj* obj = &p->tree->o;
                
				switch (obj->v->storage_class) {
					case EXTERN:
                    
						break;

					case STATIC:

						break;

					default:
						ierror(0);
				}
				
			}
			break;*/

		default:
			printf("Unimplemented gen_dc type %d\n", typf);
			ierror(0);
	}
}


/* The code generator itself.
 * This big, complicated, hairy and scary function does the work to actually
 * produce the code.  f is the output stream, ic the beginning of the ic
 * chain, func is a pointer to the actual function and stackframe is the size
 * of the function's stack frame.
 */
void gen_code(FILE *f, struct IC *firstIC, struct Var *func, zmax stackframe) {
    header(f);
    ensure_section(f, 0);

    emit(f, "%s:\n", func->identifier);

    printf("%s\n", func->identifier);
    printiclist(stdout, firstIC);
    printf("\n");

    int pushedBytes = 0;

    struct IC *ic = firstIC;
    
    for (; ic; ic = ic->next) {
        ensure_section(f, 0);
        
        int code = ic->code;
        int typf = ic->typf;

        switch (code) {
			case SUBPFP:
			case SUBIFP:
				code = SUB;
				break;

			case ADDI2P:
				code = ADD;
				break;
		}

        switch (code) {
            case NOP: /* No operation */
                break;

            case LABEL: /* Emit jump target */
                emit(f, "label%d:\n", iclabel(ic));
                break;

			case BRA: /* Unconditional jump */
				emit(f, "\tjmp label%d\n", iclabel(ic));
				break;

            case GETRETURN: /* Read the last function call's return parameter */
            case SETRETURN: /* Set this function's return parameter */
                // Uses pushed pointer instead
                break;

            case ASSIGN:
                // Todo: Handle array initialization and possibly memcpy
                emit_ic_comment(f, ic);
                switch (typf & NQ) {
                    case CHAR:
                        if (ic->q2.val.vmax != 1)
                            goto assign_copy_array;

                        load_obj(f, 0, ic->q1);
                        store_z(f, 0, ic->z);
                        break;

                    case SHORT:
                    case INT:
                    case POINTER:
                        load_obj(f, 1, ic->q1);
                        store_z(f, 1, ic->z);
                        break;

                    case STRUCT:
                    case VOID:
                    case ARRAY:
                    assign_copy_array:
                        emit(f, "\tldr #%d,A\n", get_byte(ic->q2.val.vmax, 1));
                        emit(f, "\tldr #%d,B\n", get_byte(ic->q2.val.vmax, 0));
                        emit(f, "\tstr [__copy_bytes_h],A\n");
                        emit(f, "\tstr [__copy_bytes_l],B\n");
                        load_address(f, 0, ic->z);
                        transfer_hl_to_ab(f);
                        emit(f, "\tpush A\n");
                        emit(f, "\tpush B\n");
                        load_address(f, 0, ic->q1);
                        emit(f, "\tpop B\n");
                        emit(f, "\tpop A\n");
                        emit(f, "\tjsr __copy_memory\n");
                        break;
                    
                    default:
                        printf("Unsupported assign type:");
                        printic(stdout, ic);
                        ierror(0);
                        break;
                }
                emit(f, "\n");
                break;

			case ADDRESS: /* Fetch the address of something, always AUTO or STATIC */
                emit_ic_comment(f, ic);
                load_address(f, ISSHORT(q1typ(ic)), ic->q1);
                transfer_hl_to_ab(f);
                store_z(f, 1, ic->z);
                emit(f, "\n");
                break;

			case PUSH: /* Push a value onto the stack */
                if (opsize(ic) > 2) {
                    printf("Unsupported type: ");
                    printic(stdout, ic);
                    ierror(0);
                } else {
                    emit_ic_comment(f, ic);
                    load_obj(f, 1, ic->q1);
                    emit(f, "\tpush A\n");
                    emit(f, "\tpush B\n");

                    // Return value pointers get pushed in wrong order
                    if (next_call_has_return(ic)) {
                        if (ic->next->code == CALL)
                            load_fp_offset(f, stackframe + pushedargsize(get_next_call(ic)) - 2);
                        else
                            load_fp_offset(f, stackframe + pushedargsize(get_next_call(ic)) - 2 - pushedBytes - 2);
                    } else 
                        load_fp_offset(f, stackframe + pushedargsize(get_next_call(ic)) - 2 - pushedBytes);
                    
                    pushedBytes += 2;
                    emit(f, "\tpop B\n");
                    emit(f, "\tpop A\n");
                    emit(f, "\tstr [HL],A\n");
                    emit(f, "\tina\n");
                    emit(f, "\tstr [HL],B\n");
                    emit(f, "\n");
                }
                break;

            case MINUS: /* Unary minus */
                emit_ic_comment(f, ic);
                load_obj(f, 1, ic->q1);
                emit(f, "\txor $FF\n");
                emit(f, "\tpush A\n");
                emit(f, "\tpop H\n");
                emit(f, "\tpush B\n");
                emit(f, "\tpop A\n");
                emit(f, "\txor $FF\n");
                emit(f, "\tpush A\n");
                emit(f, "\tpop L\n");
                emit(f, "\tina\n");
                transfer_hl_to_ab(f);
                store_z(f, 1, ic->z);
                emit(f, "\n");
                break;

			case KOMPLEMENT: /* Unary komplement */
                emit_ic_comment(f, ic);
                load_obj(f, 1, ic->q1);
                emit(f, "\txor $FF\n");
                emit(f, "\tpush A\n");
                emit(f, "\tpush B\n");
                emit(f, "\tpop A\n");
                emit(f, "\txor $FF\n");
                emit(f, "\tpush A\n");
                emit(f, "\tpop B\n");
                emit(f, "\tpop A\n\n");
                store_z(f, 1, ic->z);
                emit(f, "\n");
                break;

			case ADD: /* Add two numbers */
            case SUB: /* Subtract two numbers */
            case MULT: /* Multiply two numbers */
            case DIV: /* Divide two numbers */
            case MOD: /* Modulo two numbers */
            case OR: /* Bitwise or */
            case XOR: /* Bitwise xor */
            case AND: /* Bitwise and */
            case LSHIFT: /* Shift left */
            case RSHIFT: /* Shift right */
                emit_ic_comment(f, ic);
                load_q1_and_q2(f, ic);
                
                switch (code) {
                    case SUB:
                        swap_hl_ab(f);
                    case ADD:
                        emit(f, "\tjsr %s_double_extended\n", code == ADD ? "add" : "sub");
                        transfer_hl_to_ab(f);
                        break;
                    case MULT:
                    case DIV:
                    case MOD:
                        emit(f, "\tjsr %s_double_extended%s\n", code == MULT ? "multiply" : (code == DIV ? "divide" : "modulus"), UNSIGNED & typf ? "" : "_signed");
                        transfer_hl_to_ab(f);
                        break;
                    case OR:
                    case XOR:
                    case AND:
                        emit(f, "\t%s H\n", code == OR ? "or" : (code == XOR ? "xor" : "and"));
                        emit(f, "\tpush A\n");
                        emit(f, "\tpush B\n");
                        emit(f, "\tpop A\n");
                        emit(f, "\t%s L\n", code == OR ? "or" : (code == XOR ? "xor" : "and"));
                        emit(f, "\tpush A\n");
                        emit(f, "\tpop B\n");
                        emit(f, "\tpop A\n");
                        break;
                    case LSHIFT:
                    case RSHIFT:
                        emit(f, "\tjsr shift_%s_extended\n", code == LSHIFT ? "left" : "right");
                        break;
                }
                
                store_z(f, 1, ic->z);
                emit(f, "\n");
                break;

		    case CONVERT: /* Convert */
                {
                    emit_ic_comment(f, ic);
                    load_obj(f, ISSHORT(q1typ(ic)), ic->q1);
                    if ((q1typ(ic) & NU) == INT && (ztyp(ic) & NU) == (UNSIGNED|INT)) { // Signed int to unsigned int
                        // Do nothing?

                        /*int newLabel = ++label;
                        emit(f, "\tcmp A\n");
                        emit(f, "\tjr label%d, nN\n", newLabel);
                        emit(f, "\tldr $FF,H\n");
                        emit(f, "\tldr $FF,L\n");
                        emit(f, "\tjsr add_double_extended\n");
                        transfer_hl_to_ab(f);
                        emit(f, "label%d:\n", newLabel);*/
                    } else if ((q1typ(ic) & NU) == (UNSIGNED|INT) && (ztyp(ic) & NU) == INT) { // Unsigned int to signed int
                        // Nothing required
                    } else if ((q1typ(ic) & NU) == (UNSIGNED|INT) && (ztyp(ic) & NU) == CHAR) { // Unsigned int to signed char
                        emit(f, "\tpush B\n");
                        emit(f, "\tpop A\n");
                    } else if ((q1typ(ic) & NU) == CHAR && (ztyp(ic) & NU) == INT) { // Signed char to signed int
                        int newLabel = ++label;
                        emit(f, "\tpush A\n");
                        emit(f, "\tldr $0,B\n");
                        emit(f, "\tcmp B\n");
                        emit(f, "\tjr label%d, nN\n", newLabel);
                        emit(f, "\tldr $FF,B\n");
                        emit(f, "label%d:\n", newLabel);
                        emit(f, "\tpush B\n");
                        emit(f, "\tpop A\n");
                        emit(f, "\tpop B\n");
                    } else if ((q1typ(ic) & NU) == (UNSIGNED|CHAR) && (ztyp(ic) & NQ) == INT) { // Unsigned char to (unsigned or signed) int
                        emit(f, "\tpush A\n");
                        emit(f, "\tpop B\n");
                        emit(f, "\tldr $0,A\n");
                    } else if (((q1typ(ic) & NU) == INT && (ztyp(ic) & NU) == CHAR) // Signed int to signed char
                        || ((q1typ(ic) & NU) == (UNSIGNED|INT) && (ztyp(ic) & NU) == (UNSIGNED|CHAR))) { // Unsigned int to unsigned char
                        emit(f, "\tpush B\n");
                        emit(f, "\tpop A\n");
                    } else {
                        printf("Unsupported conversion:");
                        printic(stdout, ic);
                        ierror(0);
                    }
                    store_z(f, ISSHORT(ztyp(ic)), ic->z);
                    emit(f, "\n");
                }
                break;
            
			 case COMPARE: /* Compare */
                emit_ic_comment(f, ic);
                lastCompareSigned = !(UNSIGNED & q1typ(ic));
                load_q1_and_q2(f, ic);
                if (ISSHORT(q1typ(ic)))
                    emit(f, "\tjsr cmp_double_extended\n");
                else
                    emit(f, "\tcmp H\n");
                emit(f, "\n");
                break;

			case TEST: /* Compare against zero */
                emit_ic_comment(f, ic);
                load_obj(f, ISSHORT(q1typ(ic)), ic->q1);
                if (ISSHORT(q1typ(ic))) {
                    emit(f, "\tlda $0000\n");
                    emit(f, "\n");
                    emit(f, "\tjsr cmp_double_extended\n");
                } else
                    emit(f, "\tcmp $0\n");
                emit(f, "\n");
                break;

			case BEQ: /* Branch if equal */
                emit_ic_comment(f, ic);
                relative_jump(f, "nZ", iclabel(ic));
                emit(f, "\n");
                break;

			case BNE: /* Branch if not equal */
                emit_ic_comment(f, ic);
                relative_jump(f, "Z", iclabel(ic));
                emit(f, "\n");
                break;

			case BLT: /* Branch if less */
                emit_ic_comment(f, ic);
                if (lastCompareSigned) {
                    int notNClearVSetLabel = ++label;
                    int notNSetVClearLabel = ++label;
                    emit(f, "\tjr label%d, N\n", notNClearVSetLabel);
                    emit(f, "\tjr label%d, nV\n", notNClearVSetLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", notNClearVSetLabel);
                    emit(f, "\tjr label%d, nN\n", notNSetVClearLabel);
                    emit(f, "\tjr label%d, V\n", notNSetVClearLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", notNSetVClearLabel);
                } else
                    relative_jump(f, "nC", iclabel(ic));
                emit(f, "\n");
                break;

			case BGE: /* Branch if greater or equal */
                emit_ic_comment(f, ic);
                if (lastCompareSigned) {
                    int notClearLabel = ++label;
                    int notSetLabel = ++label;
                    emit(f, "\tjr label%d, N\n", notClearLabel);
                    emit(f, "\tjr label%d, V\n", notClearLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", notClearLabel);
                    emit(f, "\tjr label%d, nN\n", notSetLabel);
                    emit(f, "\tjr label%d, nV\n", notSetLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", notSetLabel);
                } else
                    relative_jump(f, "C", iclabel(ic));
                emit(f, "\n");
                break;

			case BLE: /* Branch if less or equal */
                emit_ic_comment(f, ic);
                if (lastCompareSigned) {
                    int notZLabel = ++label;
                    int notNClearVSetLabel = ++label;
                    int notNSetVClearLabel = ++label;
                    emit(f, "\tjr label%d, nZ\n", notZLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", notZLabel);
                    emit(f, "\tjr label%d, N\n", notNClearVSetLabel);
                    emit(f, "\tjr label%d, nV\n", notNClearVSetLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", notNClearVSetLabel);
                    emit(f, "\tjr label%d, nN\n", notNSetVClearLabel);
                    emit(f, "\tjr label%d, V\n", notNSetVClearLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", notNSetVClearLabel);
                } else {
                    relative_jump(f, "nC", iclabel(ic));
                    relative_jump(f, "nZ", iclabel(ic));
                }
                emit(f, "\n");
                break;

			case BGT: /* Branch if greater */
                emit_ic_comment(f, ic);
                if (lastCompareSigned) {
                    int skipLabel = ++label;
                    int notClearLabel = ++label;
                    emit(f, "\tjr label%d, Z\n", skipLabel);
                    emit(f, "\tjr label%d, N\n", notClearLabel);
                    emit(f, "\tjr label%d, V\n", notClearLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", notClearLabel);
                    emit(f, "\tjr label%d, nN\n", skipLabel);
                    emit(f, "\tjr label%d, nV\n", skipLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", skipLabel);
                } else {
                    int newLabel = ++label;
                    emit(f, "\tjr label%d, C\n", newLabel);
                    emit(f, "\tjr label%d, Z\n", newLabel);
                    emit(f, "\tjmp label%d\n", iclabel(ic));
                    emit(f, "label%d:\n", newLabel);
                }
                emit(f, "\n");
                break;

			case CALL: /* Call function */
                pushedBytes = 0;

				if ((ic->q1.flags & VAR) && ic->q1.v->fi && ic->q1.v->fi->inline_asm) {
                    emit(f, "; Inline ASM:\n");
                    emit_inline_asm(f, ic->q1.v->fi->inline_asm);
                    emit(f, "\n");
				} else {
                    emit(f, "; Call function\n");
                    emit(f, "; Set new FP\n");
                    add_fp_offset(f, stackframe + pushedargsize(ic));
                    emit(f, "; Jump to function subroutine\n");
                    emit(f, "\tjsr %s\n", ic->q1.v->identifier);
                    emit(f, "; Set old FP\n");
                    add_fp_offset(f, -(stackframe + pushedargsize(ic)));
                    emit(f, "\n");
				}
                break;

            default:
                printf("Unsupported operation:");
                printic(stdout, ic);
			    //ierror(0);
                break;
        }
    }

    if (!strcmp(func->identifier, "main"))
        emit(f, "\thalt\n\n");
    else
        emit(f, "\tret\n\n");
}

/* In C no operations are done with chars and shorts because of integral promotion.
However sometimes vbcc might see that an operation could be performed with
the short types yielding the same result.
Before generating such an instruction with short types vbcc will ask the code
generator by calling shortcut() to find out whether it should do so. Return
true iff it is a win to perform the operation code with type t rather than
promoting the operands and using e.g. int. */
int shortcut(int code, int typ) {
    return 0;
}

void cleanup_cg(FILE *f) {
    header(f);

    // Todo: Zero memory before initializaing FP and running program

    ensure_section(f, 0);
    emit(f, "\n__initialize:\n");
    char *previousVariable = NULL;
    struct VariableInit *init = variableInit;
    while (init) {
        if (!previousVariable || strcmp(previousVariable, init->variable))
            emit(f, "\tlda %s\n", init->variable);
        if (init->integer) {
            emit(f, "\tldr #%i,A\n", init->value >> 8);
            emit(f, "\tstr [HL],A\n");
            emit(f, "\tina\n");
            emit(f, "\tldr #%i,A\n", init->value & 0xFF);
            emit(f, "\tstr [HL],A\n");
            emit(f, "\tina\n");
        } else {
            emit(f, "\tldr #%i,A\n", init->value & 0xFF);
            emit(f, "\tstr [HL],A\n");
            emit(f, "\tina\n");
        }
        previousVariable = init->variable;
        init = init->next;
    }
    emit(f,"; Run main function\n");
    emit(f, "\tlda __stack\n");
    emit(f, "\tstr [__fp_h],H\n");
    emit(f, "\tstr [__fp_l],L\n");
    emit(f, "\tjmp main\n\n");

    ensure_section(f, 1);
    emit(f, "__stack:\n");
}

void cleanup_db(FILE *f) {
}
