#ifndef EMULATOR_DISASSEMBLER_H
#define EMULATOR_DISASSEMBLER_H

#include <cstdint>
#include <string>
#include <vector>
#include <list>

enum AddressingMode {
    Implied,
    Immediate,
    Address,
    Register,
    ImmediateRegister,
    AddressRegister,
    RelativeJump,
    RelativeJumpCondition,
    RelativeJumpInverseCondition
};

const uint8_t ADDRESSING_MODE_SIZES[9]{1, 2, 3, 1, 2, 3, 2, 2, 2};
const char REGISTERS[4]{'A', 'B', 'H', 'L'};
const char CONDITIONS[4]{'z', 'c', 'n', 'v'};

struct InstructionType {
    const char *text;
    AddressingMode mode;
};

struct InstructionData {
    uint16_t address;
    std::string assembly;
    uint8_t size;
    uint8_t data[3];
};

struct Instruction {
    uint16_t address;
    uint8_t size;
    std::string text;
};

const InstructionType INSTRUCTIONS[64]{
        {"NOP", Implied},
        {"LDR ", ImmediateRegister},
        {"LDR ", AddressRegister},
        {"LDR [HL],", Register},
        {"STR ", AddressRegister},
        {"STR [HL],", Register},
        {"LDA ", Address},
        {"IN " , ImmediateRegister},
        {"OUT ", ImmediateRegister},
        {"INC ", Register},
        {"DEC ", Register},
        {"INA", Implied},
        {"DEA", Implied},
        {"ADD ", Immediate},
        {"ADD ", Register},
        {"ADC ", Immediate},
        {"ADC ", Register},
        {"SUB ", Immediate},
        {"SUB ", Register},
        {"SBC ", Immediate},
        {"SBC ", Register},
        {"AND ", Immediate},
        {"AND ", Register},
        {"OR ", Immediate},
        {"OR ", Register},
        {"XOR ", Immediate},
        {"XOR ", Register},
        {"CMP ", Immediate},
        {"CMP ", Register},
        {"JMP ", Address},
        {"JMP HL", Implied},
        {"JR ", RelativeJump},
        {"JR ", RelativeJumpCondition},
        {"JR ", RelativeJumpInverseCondition},
        {"IN ", Register},
        {"OUT ", Register},
        {"PUSH ", Register},
        {"POP ", Register},
        {"JSR ", Address},
        {"RET", Implied},
        {"HALT", Implied},
};

class Disassembler {
public:
    Disassembler(uint8_t *rom, long romSize);
    const std::vector<Instruction> &getDisassembled() const;
    void update(uint16_t address, uint16_t hl);

private:
    uint8_t *rom;
    long romSize;
    std::list<InstructionData> instructions{};
    std::vector<Instruction> disassembled{};
    std::vector<uint16_t> variableJumps{};

    void disassemble(uint16_t address = 0, uint8_t depth = 0);
    InstructionData disassembleInstruction(uint16_t address) const;
    void build();
};

#endif //EMULATOR_DISASSEMBLER_H
