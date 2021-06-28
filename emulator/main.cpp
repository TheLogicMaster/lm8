#include <iostream>
#include <fstream>

#include "Emulator.h"

int main(int argv, char** args) {
    if (argv != 2) {
        std::cout << "Usage: './emulator <program>.bin'" << std::endl;
        return -1;
    }

    std::ifstream input(args[1], std::ios::binary);
    input.seekg(0, std::ios::end);
    std::streamsize len = input.tellg();
    auto *rom = new uint8_t[len];
    input.seekg(0, std::ios::beg);
    input.read(reinterpret_cast<char *>(rom), len);
    input.close();

    //uint8_t testRom[]{0b00100100, 0b00100000, 0, 0b01111100, static_cast<uint8_t>(-5)};

    Emulator emulator{(uint8_t*)rom, len};

    try {
        while (true) {
            emulator.run();
        }
    } catch (HaltException &ignored) {}

    return 0;
}
