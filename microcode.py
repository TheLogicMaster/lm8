#!/bin/python3

# Generates CPU microcode binary

# CPU constants
INSTR_COUNT = 64
INSTR_STATES = 6
STATE_SIZE = 3

# Addressing modes
ADDR_PC = 0
ADDR_SP = 1
ADDR_HL = 2
ADDR_CACHE = 3

# Data destinations
WRITE_A = 0
WRITE_REG = 1
WRITE_H = 2
WRITE_L = 3
WRITE_C0 = 4
WRITE_C1 = 5
WRITE_MEM = 6
WRITE_PORT = 7

# Data sources
READ_A = 0
READ_REG = 1
READ_H = 2
READ_L = 3
READ_C0 = 4
READ_C1 = 5
READ_MEM = 6
READ_PC_LOW = 7
READ_PC_HIGH = 8
READ_PORT = 9

# Data operations
OP_ALU = 0
OP_PASS = 1
OP_INC = 2
OP_DEC = 3

# PC write modes
PC_HL = 0
PC_CACHE = 1
PC_ADD = 2

# ALU modes
ALU_ADD = 0
ALU_ADC = 1
ALU_SUB = 2
ALU_SBC = 3
ALU_AND = 4
ALU_OR = 5
ALU_XOR = 6
ALU_CMP = 7
ALU_ASL = 8
ALU_LSR = 9
ALU_ASR = 10

# Instruction end conditions
COND_FLAG = 0
COND_NOT_FLAG = 1
COND_NOT_ZERO = 2
COND_NOT_MAX = 3

# Microcode generation state
states = [0 for i in range(INSTR_COUNT * INSTR_STATES)]
instruction = 0
instruction_state = 0


# Specify the current instruction
def instr(opcode):
    global instruction, instruction_state
    instruction = opcode
    instruction_state = 0


# Add a state to the current instruction
def state(addr_mode=0, write_op=0, read_sel=0, write_sel=0, mode=0, sp_en=False, sp_inc=False, write=False, f_write=False,
          condition=False, halt=False, pc_inc=False, pc_write=False, instr_done=False):
    global instruction_state
    value = 0
    value |= addr_mode & 0x3
    value |= (write_op & 0x3) << 2
    value |= (read_sel & 0xF) << 4
    value |= (write_sel & 0x7) << 8
    value |= (mode & 0xF) << 11
    value |= sp_en << 15
    value |= sp_inc << 16
    value |= write << 17
    value |= f_write << 18
    value |= condition << 19
    value |= halt << 20
    value |= pc_inc << 21
    value |= pc_write << 22
    value |= instr_done << 23

    states[instruction * INSTR_STATES + instruction_state] = value
    instruction_state += 1


def alu_imm_states(mode, write=True):
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(write=write, write_op=OP_ALU, write_sel=WRITE_A, read_sel=READ_C0, mode=mode, f_write=True, instr_done=True)


def alu_reg_states(mode, write=True):
    state(write=write, write_op=OP_ALU, write_sel=WRITE_A, read_sel=READ_REG, mode=mode, f_write=True, instr_done=True)


def main():
    # NOP
    instr(0b000000)
    state(instr_done=True)

    # LDR imm,reg
    instr(0b000001)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_REG, read_sel=READ_MEM, pc_inc=True, f_write=True, instr_done=True)

    # LDR [addr],reg
    instr(0b000010)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C1, read_sel=READ_MEM, pc_inc=True)
    state(addr_mode=ADDR_CACHE)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_REG, read_sel=READ_MEM, addr_mode=ADDR_CACHE, f_write=True, instr_done=True)

    # LDR [HL],reg
    instr(0b000011)
    state()
    state(addr_mode=ADDR_HL)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_REG, read_sel=READ_MEM, addr_mode=ADDR_HL, f_write=True, instr_done=True)

    # STR [addr],reg
    instr(0b000100)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C1, read_sel=READ_MEM, pc_inc=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_MEM, read_sel=READ_REG, addr_mode=ADDR_CACHE, instr_done=True)

    # STR [HL],reg
    instr(0b000101)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_MEM, read_sel=READ_REG, addr_mode=ADDR_HL, instr_done=True)

    # LDA addr
    instr(0b000110)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_H, read_sel=READ_MEM, pc_inc=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_L, read_sel=READ_MEM, pc_inc=True, instr_done=True)

    # IN imm,reg
    instr(0b000111)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_REG, read_sel=READ_PORT, f_write=True, instr_done=True)

    # OUT imm,reg
    instr(0b001000)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_PORT, read_sel=READ_REG, instr_done=True)

    # INC reg
    instr(0b001001)
    state(write=True, write_op=OP_INC, write_sel=WRITE_REG, read_sel=READ_REG, f_write=True, instr_done=True)

    # DEC reg
    instr(0b001010)
    state(write=True, write_op=OP_DEC, write_sel=WRITE_REG, read_sel=READ_REG, f_write=True, instr_done=True)

    # INA
    instr(0b001011)
    state(write=True, write_op=OP_INC, write_sel=WRITE_L, read_sel=READ_L, f_write=True)
    state(read_sel=READ_L, write_op=OP_PASS, condition=True, mode=COND_NOT_ZERO)
    state(write=True, write_op=OP_INC, write_sel=WRITE_H, read_sel=READ_H, f_write=True, instr_done=True)

    # DEA
    instr(0b001100)
    state(write=True, write_op=OP_DEC, write_sel=WRITE_L, read_sel=READ_L, f_write=True)
    state(read_sel=READ_L, write_op=OP_PASS, condition=True, mode=COND_NOT_MAX)
    state(write=True, write_op=OP_DEC, write_sel=WRITE_H, read_sel=READ_H, f_write=True, instr_done=True)

    # ADD imm
    instr(0b001101)
    alu_imm_states(ALU_ADD)

    # ADD reg
    instr(0b001110)
    alu_reg_states(ALU_ADD)

    # ADC imm
    instr(0b001111)
    alu_imm_states(ALU_ADC)

    # ADC reg
    instr(0b010000)
    alu_reg_states(ALU_ADC)

    # SUB imm
    instr(0b010001)
    alu_imm_states(ALU_SUB)

    # SUB reg
    instr(0b010010)
    alu_reg_states(ALU_SUB)

    # SBC imm
    instr(0b010011)
    alu_imm_states(ALU_SBC)

    # SBC reg
    instr(0b010100)
    alu_reg_states(ALU_SBC)

    # AND imm
    instr(0b010101)
    alu_imm_states(ALU_AND)

    # AND reg
    instr(0b010110)
    alu_reg_states(ALU_AND)

    # OR imm
    instr(0b010111)
    alu_imm_states(ALU_OR)

    # OR reg
    instr(0b011000)
    alu_reg_states(ALU_OR)

    # XOR imm
    instr(0b011001)
    alu_imm_states(ALU_XOR)

    # XOR reg
    instr(0b011010)
    alu_reg_states(ALU_XOR)

    # CMP imm
    instr(0b011011)
    alu_imm_states(ALU_CMP, False)

    # CMP reg
    instr(0b011100)
    alu_reg_states(ALU_CMP, False)

    # JMP addr
    instr(0b011101)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C1, read_sel=READ_MEM, pc_inc=True)
    state(pc_write=True, mode=PC_CACHE, instr_done=True)

    # JMP HL
    instr(0b011110)
    state(pc_write=True, mode=PC_HL, instr_done=True)

    # JR imm
    instr(0b011111)
    state()
    state(read_sel=READ_MEM, write_op=OP_PASS, pc_write=True, mode=PC_ADD)
    state(pc_inc=True, instr_done=True)

    # JR imm,cc
    instr(0b100000)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(condition=True, mode=COND_NOT_FLAG)
    state(read_sel=READ_C0, write_op=OP_PASS, pc_write=True, mode=PC_ADD, instr_done=True)

    # JR imm,nn
    instr(0b100001)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(condition=True, mode=COND_FLAG)
    state(read_sel=READ_C0, write_op=OP_PASS, pc_write=True, mode=PC_ADD, instr_done=True)

    # IN reg
    instr(0b100010)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_A)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_REG, read_sel=READ_PORT, f_write=True, instr_done=True)

    # OUT reg
    instr(0b100011)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_A)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_PORT, read_sel=READ_REG, instr_done=True)

    # PUSH reg
    instr(0b100100)
    state(sp_en=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_MEM, read_sel=READ_REG, addr_mode=ADDR_SP, instr_done=True)

    # POP reg
    instr(0b100101)
    state()
    state(addr_mode=ADDR_SP)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_REG, read_sel=READ_MEM, addr_mode=ADDR_SP, sp_en=True, sp_inc=True, instr_done=True)

    # JSR addr
    instr(0b100110)
    state()
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, pc_inc=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C1, read_sel=READ_MEM, pc_inc=True, sp_en=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_MEM, read_sel=READ_PC_LOW, addr_mode=ADDR_SP, sp_en=True)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_MEM, read_sel=READ_PC_HIGH, addr_mode=ADDR_SP)
    state(pc_write=True, mode=PC_CACHE, instr_done=True)

    # RET
    instr(0b100111)
    state()
    state(addr_mode=ADDR_SP)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C0, read_sel=READ_MEM, addr_mode=ADDR_SP, sp_en=True, sp_inc=True)
    state(addr_mode=ADDR_SP)
    state(write=True, write_op=OP_PASS, write_sel=WRITE_C1, read_sel=READ_MEM, addr_mode=ADDR_SP, sp_en=True, sp_inc=True)
    state(pc_write=True, mode=PC_CACHE, instr_done=True)

    # HALT
    instr(0b101000)
    state()
    state(halt=True)

    # LSL
    instr(0b101001)
    state(write=True, write_op=OP_ALU, write_sel=WRITE_A, read_sel=READ_REG, mode=ALU_ASL, f_write=True, instr_done=True)

    # LSR
    instr(0b101010)
    state(write=True, write_op=OP_ALU, write_sel=WRITE_A, read_sel=READ_REG, mode=ALU_LSR, f_write=True, instr_done=True)

    # ASR
    instr(0b101011)
    state(write=True, write_op=OP_ALU, write_sel=WRITE_A, read_sel=READ_REG, mode=ALU_ASR, f_write=True, instr_done=True)

    output = bytearray(len(states) * STATE_SIZE)
    for i in range(len(states)):
        output[i * 3] = states[i] >> 16
        output[i * 3 + 1] = (states[i] & 0xFF00) >> 8
        output[i * 3 + 2] = states[i] & 0xFF
    f = open('microcode.bin', 'wb')
    f.write(output)
    f.close()


if __name__ == '__main__':
    main()
