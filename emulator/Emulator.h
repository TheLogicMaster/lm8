#ifndef EMULATOR_EMULATOR_H
#define EMULATOR_EMULATOR_H

#include <cstdint>

#define DISPLAY_WIDTH 160
#define DISPLAY_HEIGHT 128

#define PRINT_BUFFER 10000

#define FLAG_Z 1 << 3
#define FLAG_C 1 << 2
#define FLAG_N 1 << 1
#define FLAG_V 1 << 0

struct HaltException : public std::exception {
    const char *what() const noexcept override {
        return "Emulator HALT";
    }
};

struct RGB888 {
    uint8_t r, g, b;
};

class Emulator {
public:
    void load(uint8_t *romData, long size);
    void run();
    void reset();

    uint8_t* getDisplayBuffer();
    std::string &getPrintBuffer();
    void setSwitch(int id, bool value);
    void setButton(int id, bool value);
    bool getLight(int id);
    uint8_t getSevenSegmentDisplay(int id);

    uint8_t* getMemory();
    uint8_t* getROM();
    uint8_t getRegA() const;
    uint8_t getRegB() const;
    uint8_t getRegH() const;
    uint8_t getRegL() const;
    uint16_t getPC() const;
    uint8_t getStatus() const;

private:
    uint8_t displayBuffer[DISPLAY_HEIGHT * DISPLAY_WIDTH * 3]{};
    bool switches[10]{};
    bool lights[10]{};
    bool buttons[2]{};
    uint8_t sevenSegmentDisplays[6]{};
    uint8_t graphicsX = 0;
    uint8_t graphicsY = 0;
    std::string printBuffer{};

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

    static RGB888 rgb332To888(uint8_t color);
    void drawPixel(uint8_t x, uint8_t y, RGB888 color);
    void drawSprite(uint8_t id);
    void fillScreen(RGB888 color);
};

#endif //EMULATOR_EMULATOR_H
