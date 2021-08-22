#ifndef EMULATOR_EMULATOR_H
#define EMULATOR_EMULATOR_H

#include <cstdint>
#include <queue>

#define DISPLAY_WIDTH 160
#define DISPLAY_HEIGHT 128

#define TIMER_COUNT 2

#define PRINT_BUFFER 10000

#define FLAG_Z 1 << 3
#define FLAG_C 1 << 2
#define FLAG_N 1 << 1
#define FLAG_V 1 << 0

static const uint8_t PWM_PINS[]{3, 5, 6, 9, 10, 11};

static const char TIMER_MODES[8][11]{
        "micro",
        "centimilli",
        "decimilli",
        "milli",
        "centi",
        "deci",
        "",
        "deca"
};

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
    Emulator();
    void load(uint8_t *romData, long size);
    void run();
    void reset();

    uint8_t* getDisplayBuffer();
    std::string &getPrintBuffer();
    void uartReceive(char* bytes, uint8_t length);
    bool& getSwitch(int id);
    bool& getButton(int id);
    bool getLight(int id);
    uint8_t getSevenSegmentDisplay(int id);
    bool& getGPIO(int id);
    bool& getArduinoIO(int id);
    uint8_t& getADC(int id);
    bool getGpioOutput(int id);
    bool getArduinoOutput(int id);
    bool getPwmEnable(int id);
    uint8_t getPwmDutyCycle(int id);
    uint8_t getPwmCount();
    bool getUartEnable();
    uint8_t getTimerMode(int id);
    uint8_t getTimerCount(int id);
    bool getTimerValue(int id);
    void updateTimers(int delta);

    uint8_t* getMemory();
    uint8_t* getROM();
    uint8_t getRegA() const;
    uint8_t getRegB() const;
    uint8_t getRegH() const;
    uint8_t getRegL() const;
    uint16_t getPC() const;
    uint8_t getSP() const;
    uint8_t getStatus() const;

private:
    uint8_t displayBuffers[2][DISPLAY_HEIGHT * DISPLAY_WIDTH * 3]{};
    uint8_t *renderingBuffer;
    uint8_t *drawingBuffer;
    bool switches[10]{};
    bool lights[10]{};
    bool buttons[2]{};
    uint8_t sevenSegmentDisplays[6]{};
    bool gpio[36]{};
    bool gpioOutput[36]{};
    bool arduinoIO[16]{};
    bool arduinoOutput[16]{};
    bool pwmEnable[6]{};
    uint8_t pwmDutyCycles[6]{};
    uint8_t pwmCount{};
    bool uartEnable{};
    uint8_t timerModes[2]{};
    uint8_t timerCounts[2]{};
    uint64_t timerValues[2]{};
    uint8_t analogDigitalConverters[6]{};
    uint8_t graphicsX = 0;
    uint8_t graphicsY = 0;
    std::queue<uint8_t> uartInBuffer{};
    std::string printBuffer{};

    uint8_t rom[0x8000]{};
    uint8_t ram[0x8000]{};

    uint8_t regA = 0;
    uint8_t regB = 0;
    union { // Only works on little-endian systems
        uint16_t hl;
        struct {
            uint8_t l;
            uint8_t h;
        } values;
    } regHL{};
    uint8_t status = 0;
    uint16_t pc = 0;
    uint8_t sp = 0;

    uint8_t readUint8(uint16_t address);
    void writeUint8(uint16_t address, uint8_t value);
    uint16_t readUint16(uint16_t address);
    void writeUint16(uint16_t address, uint16_t value);

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
