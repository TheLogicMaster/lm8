/**
 * This is a CC0 1.0 licensed C++11 std::string formatting utility function to get C++20 std::format functionality
 */

#ifndef EMULATOR_STRINGFORMAT_H
#define EMULATOR_STRINGFORMAT_H

#include <memory>
#include <string>
#include <stdexcept>

template<typename ... Args>
inline std::string stringFormat(const std::string &format, Args ... args) {
    int size_s = std::snprintf(nullptr, 0, format.c_str(), args ...) + 1; // Extra space for '\0'
    if (size_s <= 0)
        throw std::runtime_error("Error during formatting.");
    auto size = static_cast<size_t>(size_s);
    auto buf = std::make_unique<char[]>(size);
    std::snprintf(buf.get(), size, format.c_str(), args ...);
    return std::string(buf.get(), buf.get() + size - 1); // We don't want the '\0' inside
}

#endif //EMULATOR_STRINGFORMAT_H
