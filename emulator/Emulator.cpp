#include <iostream>
#include <cstring>
#include <bitset>
#include <ctime>
#include <cmath>

#include "Emulator.h"

Emulator::Emulator() {
    srand(time(nullptr));
    renderingBuffer = displayBuffers[0];
    drawingBuffer = displayBuffers[1];
    rom = memory;
    ram = memory + 0x8000;
}

void Emulator::load(uint8_t *romData, long size) {
    memset(rom, 0, 0x8000);
    memcpy(rom, romData, size);
}

void Emulator::run() {
    uint8_t instruction = ingestUint8();

//    std::cout << std::hex << "PC: " << pc - 1 << ", INSTR: " << std::bitset<8>(instruction) << ", A: " << (uint16_t)regA << ", B: " << (uint16_t)regB << ", HL: " << regHL.hl << ", F: " << (uint16_t)status << std::endl;

    pwmCount++;
    for (int i = 0; i < 6; i++)
        if (arduinoOutput[PWM_PINS[i]] and pwmEnable[i])
            arduinoIO[PWM_PINS[i]] = pwmDutyCycles[i] == 0xFF or pwmDutyCycles[i] < pwmCount;

    switch ((instruction & 0xFC) >> 2) {
        default:
        case 0b000000: // NOP
            break;
        case 0b000001: // LDR imm8,reg
            getReg(instruction) = ingestUint8();
            setFlag(FLAG_Z, !getReg(instruction));
            break;
        case 0b000010: // LDR [imm16],reg
            getReg(instruction) = readUint8(ingestUint16());
            setFlag(FLAG_Z, !getReg(instruction));
            break;
        case 0b000011: // LDR [HL],reg
            getReg(instruction) = readUint8(regHL.hl);
            setFlag(FLAG_Z, !getReg(instruction));
            break;
        case 0b000100: // STR [imm16],reg
            writeUint8(ingestUint16(), getReg(instruction));
            break;
        case 0b000101: // STR [HL],reg
            writeUint8(regHL.hl, getReg(instruction));
            break;
        case 0b000110: // LDA imm16
            regHL.hl = ingestUint16();
            break;
        case 0b000111: // IN imm8,reg
            getReg(instruction) = readPort(ingestUint8());
            setFlag(FLAG_Z, !getReg(instruction));
            break;
        case 0b001000: // OUT imm8,reg
            writePort(ingestUint8(), getReg(instruction));
            break;
        case 0b001001: // INC reg
            getReg(instruction)++;
            setFlag(FLAG_Z, !getReg(instruction));
            setFlag(FLAG_C, !getReg(instruction));
            break;
        case 0b001010: // DEC reg
            setFlag(FLAG_C, !getReg(instruction));
            getReg(instruction)--;
            setFlag(FLAG_Z, !getReg(instruction));
            break;
        case 0b001011: // INA
            regHL.hl++;
            break;
        case 0b001100: // DEA
            regHL.hl--;
            break;
        case 0b001101: // ADD imm8
            instrADD(ingestUint8());
            break;
        case 0b001110: // ADD reg
            instrADD(getReg(instruction));
            break;
        case 0b001111: // ADC imm8
            instrADC(ingestUint8());
            break;
        case 0b010000: // ADC reg
            instrADC(getReg(instruction));
            break;
        case 0b010001: // SUB imm8
            instrSUB(ingestUint8());
            break;
        case 0b010010: // SUB reg
            instrSUB(getReg(instruction));
            break;
        case 0b010011: // SBC imm8
            instrSBC(ingestUint8());
            break;
        case 0b010100: // SBC reg
            instrSBC(getReg(instruction));
            break;
        case 0b010101: // AND imm8
            instrAND(ingestUint8());
            break;
        case 0b010110: // AND reg
            instrAND(getReg(instruction));
            break;
        case 0b010111: // OR imm8
            instrOR(ingestUint8());
            break;
        case 0b011000: // OR reg
            instrOR(getReg(instruction));
            break;
        case 0b011001: // XOR imm8
            instrXOR(ingestUint8());
            break;
        case 0b011010: // XOR reg
            instrXOR(getReg(instruction));
            break;
        case 0b011011: // CMP imm8
            instrCMP(ingestUint8());
            break;
        case 0b011100: // CMP reg
            instrCMP(getReg(instruction));
            break;
        case 0b011101: // JMP imm16
            pc = ingestUint16();
            break;
        case 0b011110: // JMP HL
            pc = regHL.hl;
            break;
        case 0b011111: // JR imm8
            pc += ingestInt8();
            break;
        case 0b100000: // JR imm8,cc
            if (checkCondition(instruction))
                pc += ingestInt8();
            else
                pc += 1;
            break;
        case 0b100001: // JR imm8,nn
            if (!checkCondition(instruction))
                pc += ingestInt8();
            else
                pc += 1;
            break;
        case 0b100010: // IN reg
            getReg(instruction) = readPort(regA);
            setFlag(FLAG_Z, !getReg(instruction));
            break;
        case 0b100011: // OUT reg
            writePort(regA, getReg(instruction));
            break;
        case 0b100100: // PUSH reg
            writeUint8(0xFF00 + --sp, getReg(instruction));
            break;
        case 0b100101: // POP reg
            getReg(instruction) = readUint8(0xFF00 + sp++);
            break;
        case 0b100110: // JSR imm16
            sp -= 2;
            writeUint16(0xFF00 + sp, pc + 2); // Add two to account for yet to be ingested address
            pc = ingestUint16();
            break;
        case 0b100111: // RET
            pc = readUint16(0xFF00 + sp);
            sp += 2;
            break;
        case 0b101000: // HALT
            throw HaltException();
        case 0b101001: // LSL
            setFlag(FLAG_C, regA & 0x80);
            regA <<= 1;
            setFlag(FLAG_Z, !regA);
            break;
        case 0b101010: // LSR
            setFlag(FLAG_C, regA & 0x1);
            regA >>= 1;
            setFlag(FLAG_Z, !regA);
            break;
        case 0b101011: // ASR
            setFlag(FLAG_C, regA & 0x1);
            regA = (regA & 0x80) | (regA >> 1);
            setFlag(FLAG_Z, !regA);
            break;
    }
}

void Emulator::reset() {
    regA = 0;
    regB = 0;
    regHL.hl = 0;
    pc = 0;
    sp = 0;
    status = 0;
    memset(displayBuffers, 0, DISPLAY_HEIGHT * DISPLAY_WIDTH * 3 * 2);
    renderingBuffer = displayBuffers[0];
    drawingBuffer = displayBuffers[1];
    memset(ram, 0, 0x8000);
    memset(lights, 0, 10);
    memset(sevenSegmentDisplays, 0, 6);
    for (int i = 0; i < 36; i++)
        if (gpioOutput[i])
            gpio[i] = false;
    memset(gpioOutput, 0, 36);
    for (int i = 0; i < 16; i++)
        if (arduinoOutput[i])
            arduinoIO[i] = false;
    memset(arduinoOutput, 0, 16);
    memset(pwmEnable, 0, 6);
    memset(pwmDutyCycles, 0, 6);
    pwmCount = 0;
    uartEnable = false;
    std::queue<uint8_t>().swap(uartInBuffer);
    memset(timerCounts, 0, TIMER_COUNT);
    memset(timerModes, 0, TIMER_COUNT);
    memset(timerValues, 0, TIMER_COUNT);
    graphicsX = 0;
    graphicsY = 0;
}

uint8_t *Emulator::getDisplayBuffer() {
    return renderingBuffer;
}

std::string &Emulator::getPrintBuffer() {
    return printBuffer;
}

void Emulator::uartReceive(char* bytes, uint8_t length) {
    for (int i = 0; i < length; i++) {
        if (uartInBuffer.size() >= 255)
            break;
        uartInBuffer.push(bytes[i]);
    }
}

bool &Emulator::getSwitch(int id) {
    return switches[id];
}

bool &Emulator::getButton(int id) {
    return buttons[id];
}

bool Emulator::getLight(int id) {
    return lights[id];
}

uint8_t Emulator::getSevenSegmentDisplay(int id) {
    return sevenSegmentDisplays[id];
}

bool &Emulator::getGPIO(int id) {
    return gpio[id];
}

bool &Emulator::getArduinoIO(int id) {
    return arduinoIO[id];
}

uint8_t &Emulator::getADC(int id) {
    return analogDigitalConverters[id];
}

bool Emulator::getGpioOutput(int id) {
    return gpioOutput[id];
}

bool Emulator::getArduinoOutput(int id) {
    return arduinoOutput[id];
}

bool Emulator::getPwmEnable(int id) {
    return pwmEnable[id];
}

uint8_t Emulator::getPwmDutyCycle(int id) {
    return pwmDutyCycles[id];
}

uint8_t Emulator::getPwmCount() {
    return pwmCount;
}

bool Emulator::getUartEnable() {
    return uartEnable;
}

uint8_t Emulator::getTimerMode(int id) {
    return timerModes[id];
}

uint8_t Emulator::getTimerCount(int id) {
    return timerCounts[id];
}

bool Emulator::getTimerValue(int id) {
    return timerValues[id] >= pow(10.0L, timerModes[id]) * timerCounts[id];
}

void Emulator::updateTimers(int delta) {
    for (int i = 0; i < TIMER_COUNT; i++)
        if (!getTimerValue(i))
            timerValues[i] += delta;
}

uint8_t *Emulator::getMemory() {
    return memory;
}

uint8_t *Emulator::getRAM() {
    return ram;
}

uint8_t *Emulator::getROM() {
    return rom;
}

uint8_t Emulator::getRegA() const {
    return regA;
}

uint8_t Emulator::getRegB() const {
    return regB;
}

uint8_t Emulator::getRegH() const {
    return regHL.values.h;
}

uint8_t Emulator::getRegL() const {
    return regHL.values.l;
}

uint16_t Emulator::getPC() const {
    return pc;
}

uint8_t Emulator::getSP() const {
    return sp;
}

uint8_t Emulator::getStatus() const {
    return status;
}

uint8_t Emulator::readUint8(uint16_t address) {
    if (address <= 0x7FFF)
        return rom[address];
    else
        return ram[address - 0x8000];
}

void Emulator::writeUint8(uint16_t address, uint8_t value) {
    if (address >= 0x8000)
        ram[address - 0x8000] = value;
}

uint16_t Emulator::readUint16(uint16_t address) {
    return readUint8(address) << 8 | readUint8(address + 1);
}

void Emulator::writeUint16(uint16_t address, uint16_t value) {
    writeUint8(address, (value & 0xFF00) >> 8);
    writeUint8(address + 1, value & 0xFF);
}

uint8_t Emulator::ingestUint8() {
    return readUint8(pc++);
}

int8_t Emulator::ingestInt8() {
    uint8_t value = ingestUint8();
    return *(int8_t*)&value; // Casting normally destroys the value
}

uint16_t Emulator::ingestUint16() {
    pc += 2;
    return readUint16(pc - 2);
}

uint8_t &Emulator::getReg(uint8_t instruction) {
    switch (instruction & 0x3) {
        default:
        case 0:
            return regA;
        case 1:
            return regB;
        case 2:
            return regHL.values.h;
        case 3:
            return regHL.values.l;
    }
}

void Emulator::setFlag(uint8_t flag, bool set) {
    if (set)
        status |= flag;
    else
        status &= ~flag;
}

bool Emulator::checkCondition(uint8_t instruction) const {
    return status & (1 << (3 - instruction & 0x3));
}

uint8_t Emulator::readPort(uint8_t port) {
    switch (port) {
        case 0:
            return uartInBuffer.front();
        case 1:
            return uartInBuffer.size();
        case 2 ... 7: // Seven Segment Displays
            return sevenSegmentDisplays[port - 2];
        case 8 ... 9: // I/O Panel Buttons
            return buttons[port - 8];
        case 10 ... 19: // LEDs
            return lights[port - 10];
        case 20 ... 29: // I/O Panel Switches
            return switches[port - 20];
        case 30: // Graphics X
            return graphicsX;
        case 31: // Graphics Y
            return graphicsY;
        case 35 ... 70: // GPIO
            return gpio[port - 35];
        case 71 ... 86: // Arduino I/O
            return arduinoIO[port - 71];
        case 87 ... 92: // ADCs
            return analogDigitalConverters[port - 87];
        case 93: // Random
            return rand() % 256;
        case 101 ... 106: // PWM Duty Cycles
            return pwmDutyCycles[port - 101];
        case 108 ... 109:
            return timerModes[port - 108];
        case 110 ... 111:
            return timerCounts[port - 110];
        case 112 ... 113:
            return getTimerValue(port - 112);
        default:
            return 0;
    }
}

void Emulator::writePort(uint8_t port, uint8_t value) {
    switch (port) {
        case 0: // Print Char
            if (value == 0)
                break;
            std::cout << value << std::flush;
            printBuffer.push_back(*(char*)&value);
            if (printBuffer.length() > PRINT_BUFFER)
                printBuffer.erase(0, 1);
            break;
        case 1: // Pop first UART read value
            if (!uartInBuffer.empty())
                uartInBuffer.pop();
            break;
        case 2 ... 7: // Seven Segment Displays
            sevenSegmentDisplays[port - 2] = value;
            break;
        case 10 ... 19: // LEDs
            lights[port - 10] = value;
            break;
        case 30: // Graphics X
            graphicsX = value;
            break;
        case 31: // Graphics Y
            graphicsY = value;
            break;
        case 32: // Draw Pixel
            drawPixel(graphicsX, graphicsY, rgb332To888(value));
            break;
        case 33: // Draw Sprite
            drawSprite(value);
            break;
        case 34: // Clear Screen
            fillScreen(rgb332To888(value));
            break;
        case 35 ... 70: // GPIO
            gpio[port - 35] = value;
            break;
        case 71 ... 86: // Arduino Header I/O
            arduinoIO[port - 71] = value;
            break;
        case 94:
            if (displayBuffers[0] == renderingBuffer) {
                renderingBuffer = displayBuffers[1];
                drawingBuffer = displayBuffers[0];
            } else {
                renderingBuffer = displayBuffers[0];
                drawingBuffer = displayBuffers[1];
            }
            break;
        case 95: // GPIO Output
            if (value < 36)
                gpioOutput[value] = true;
            break;
        case 96: // GPIO Input
            if (value < 36)
                gpioOutput[value] = false;
            break;
        case 97: // Arduino I/O Output
            arduinoOutput[value & 0xF] = true;
            break;
        case 98: // Arduino I/O Input
            arduinoOutput[value & 0xF] = false;
            break;
        case 99 ... 100: // PWM Enable/Disable
            for (int i = 0; i < 6; i++)
                if (PWM_PINS[i] == value)
                    pwmEnable[i] = port == 99;
            break;
        case 101 ... 106: // PWM Duty Cycle
            pwmDutyCycles[port - 101] = value;
            break;
        case 107: // UART Enable
            uartEnable = value;
            break;
        case 108 ... 109: // Timer Mode
            timerModes[port - 108] = value;
            break;
        case 110 ... 111: // Timer Count
            timerCounts[port - 110] = value;
            break;
        case 112 ... 113: // Timer Reset
            timerValues[port - 112] = 0;
            break;
        default:
            break;
    }
}

void Emulator::instrADD(uint8_t value) {
    uint8_t newValue = regA + value;
    setFlag(FLAG_Z, !newValue);
    setFlag(FLAG_C, value + regA > 0xFF);
    setFlag(FLAG_N, newValue & 0x80);
    setFlag(FLAG_V, (regA & 0x80) == (value & 0x80) and (regA & 0x80) != (newValue & 0x80));
    regA = newValue;
}

void Emulator::instrADC(uint8_t value) {
    instrADD(value + ((status & FLAG_C) != 0));
}

void Emulator::instrSUB(uint8_t value) {
    regA = setSubFlags(value);
}

void Emulator::instrSBC(uint8_t value) {
    instrSUB(value + ((status & FLAG_C) != 0));
}

void Emulator::instrAND(uint8_t value) {
    regA &= value;
    setFlag(FLAG_Z, !regA);
}

void Emulator::instrOR(uint8_t value) {
    regA |= value;
    setFlag(FLAG_Z, !regA);
}

void Emulator::instrXOR(uint8_t value) {
    regA ^= value;
    setFlag(FLAG_Z, !regA);
}

void Emulator::instrCMP(uint8_t value) {
    setSubFlags(value);
}

uint8_t Emulator::setSubFlags(uint8_t value) {
    uint8_t newValue = regA - value;
    setFlag(FLAG_Z, !newValue);
    setFlag(FLAG_C, value > regA);
    setFlag(FLAG_N, newValue & 0x80);
    setFlag(FLAG_V, (regA & 0x80) == (value & 0x80) and (regA & 0x80) != (newValue & 0x80));
    return newValue;
}

RGB888 Emulator::rgb332To888(uint8_t color) {
    return RGB888{
        static_cast<uint8_t>(((color & 0xE0) >> 5) * 0xFF / 0x7),
        static_cast<uint8_t>(((color & 0x1C) >> 2) * 0xFF / 0x7),
        static_cast<uint8_t>((color & 0x03) * 0xFF / 0x3)
    };
}

void Emulator::drawPixel(uint8_t x, uint8_t y, RGB888 color) {
    if (x >= DISPLAY_WIDTH or y >= DISPLAY_HEIGHT)
        return;
    memcpy(drawingBuffer + (DISPLAY_WIDTH * y + x) * 3, &color, 3);
}

void Emulator::drawSprite(uint8_t id) {
    for (int y = 0; y < 8; y++)
        for (int x = 0; x < 8; x++) {
            auto color = readUint8(regHL.hl + 8 * y + x);
            if (color != 0)
                drawPixel(graphicsX + x, graphicsY + y, rgb332To888(color));
        }
}

void Emulator::fillScreen(RGB888 color) {
    for (int y = 0; y < DISPLAY_HEIGHT; y++)
        for (int x = 0; x < DISPLAY_WIDTH; x++)
            drawPixel(x, y, color);
}
