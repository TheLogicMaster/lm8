#include "Disassembler.h"

#include "StringFormat.h"

Disassembler::Disassembler(uint8_t *rom, long romSize) : rom(rom), romSize(romSize) {
    disassemble();
    build();
}

const std::vector<Instruction> &Disassembler::getDisassembled() const {
    return disassembled;
}

void Disassembler::update(uint16_t address, uint16_t hl) {
    for (auto jump: variableJumps)
        if (address == jump) {
            disassemble(hl);
            build();
            break;
        }
}

void Disassembler::disassemble(uint16_t address, uint8_t depth) {
    if (depth > 100)
        return;

    while (address < romSize) {
        auto instruction = disassembleInstruction(address);
        uint16_t end = address + instruction.size - 1;
        if (instruction.size == 0 or end >= romSize)
            return;

        auto it = instructions.end();
        if (!instructions.empty()) {
            do {
                it--;
                if ((*it).address <= end)
                    break;
            } while (it != instructions.begin());
            if ((*it).address + (*it).size > address)
                return;
            it++;
        }
        instructions.insert(it, instruction);

        uint8_t instr = instruction.data[0] >> 2;
        if (instr == 0b011101) { // JMP immediate
            disassemble(instruction.data[1] << 8 | instruction.data[2], depth + 1);
            return;
        } else if (instr == 0b011110) { // JMP HL
            variableJumps.emplace_back(address);
            return;
        } else if (instr == 0b011111) { // JR always
            disassemble(end + 1 + *(int8_t*)&instruction.data[1], depth + 1);
            return;
        } else if (instr == 0b100000 or instr == 0b100001) { // JR conditional
            disassemble(end + 1 + *(int8_t*)&instruction.data[1], depth + 1);
        } else if (instr == 0b100110) { // JSR
            disassemble(instruction.data[1] << 8 | instruction.data[2], depth + 1);
        } else if (instr == 0b100111) { // RET
            return;
        }
        address = end + 1;
    }
}

InstructionData Disassembler::disassembleInstruction(uint16_t address) const {
    uint8_t instr = rom[address];
    auto type = INSTRUCTIONS[instr >> 2];
    if (type.text == nullptr)
        return InstructionData{address, "Invalid"};
    uint8_t conditionOrRegister = instr & 0x3;
    InstructionData instruction{address, type.text, ADDRESSING_MODE_SIZES[type.mode]};
    for (int i = 0; i < instruction.size; i++)
        instruction.data[i] = rom[address + i];

    switch (type.mode) {
        case Implied:
            break;
        case Immediate:
            instruction.assembly += stringFormat("$%02x", instruction.data[1]);
            break;
        case Address:
            instruction.assembly += stringFormat("$%04x", instruction.data[1] << 8 | instruction.data[2]);
            break;
        case Register:
            instruction.assembly += stringFormat("%c", REGISTERS[conditionOrRegister]);
            break;
        case ImmediateRegister:
            instruction.assembly += stringFormat("$%02x,%c", instruction.data[1], REGISTERS[conditionOrRegister]);
            break;
        case AddressRegister:
            instruction.assembly += stringFormat("[$%04x],%c", instruction.data[1] << 8 | instruction.data[2], REGISTERS[conditionOrRegister]);
            break;
        case RelativeJump:
            instruction.assembly += stringFormat("#%d", *(int8_t*)&instruction.data[1]);
            break;
        case RelativeJumpCondition:
            instruction.assembly += stringFormat("#%d,%c", *(int8_t*)&instruction.data[1], CONDITIONS[conditionOrRegister]);
            break;
        case RelativeJumpInverseCondition:
            instruction.assembly += stringFormat("#%d,n%c", *(int8_t*)&instruction.data[1], CONDITIONS[conditionOrRegister]);
            break;
    }
    return instruction;
}

void Disassembler::build() {
    disassembled.clear();
    for (auto & instruction : instructions) {
        std::string entry = stringFormat("$%04x", instruction.address) + ": ";
        for (int i = 0; i < 3; i++)
            entry += stringFormat(i < instruction.size ? "$%02x " : "    ", instruction.data[i]);
        entry += "  ";
        entry += instruction.assembly;
        disassembled.emplace_back(Instruction{instruction.address, instruction.size, entry});
    }
}
