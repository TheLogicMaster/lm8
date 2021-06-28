#ifndef EMULATOR_EMULATOR_H
#define EMULATOR_EMULATOR_H

#include <cstdint>

#define FLAG_Z 1 << 3
#define FLAG_C 1 << 2
#define FLAG_N 1 << 1
#define FLAG_V 1 << 0

struct HaltException : public std::exception {
    const char *what() const noexcept override {
        return "Emulator HALT";
    }
};

class Emulator {
public:
    Emulator(uint8_t *rom, long size);
    void run();

private:
    uint8_t rom[0x8000]{};
    uint8_t ram[0x8000]{};

    uint8_t regA = 0;
    uint8_t regB = 0;
    union { // Only works on big-endian systems
        uint16_t hl;
        struct {
            uint8_t l;
            uint8_t h;
        } values;
    } regHL{};
    uint8_t status = 0;
    uint16_t pc = 0;

    uint8_t readUint8(uint16_t address);
    void writeUint8(uint16_t address, uint8_t value);
    uint16_t readUint16(uint16_t address);
    uint8_t ingestUint8();
    int8_t ingestInt8();
    uint16_t ingestUint16();
    uint8_t &getReg(uint8_t instruction);
    void setFlag(uint8_t flag, bool set);
    bool checkCondition(uint8_t instruction) const;
    uint8_t readPort(uint8_t port);
    void writePort(uint8_t port, uint8_t value);
    void instrADD(uint8_t value);
    void instrADC(uint8_t value);
    void instrSUB(uint8_t value);
    void instrSBC(uint8_t value);
    void instrAND(uint8_t value);
    void instrOR(uint8_t value);
    void instrXOR(uint8_t value);
    void instrCMP(uint8_t value);
    uint8_t setSubFlags(uint8_t value);
};

#endif //EMULATOR_EMULATOR_H
