cmake_minimum_required(VERSION 3.19)
project(emulator)

set(CMAKE_CXX_STANDARD 14)

add_executable(emulator main.cpp Emulator.cpp Emulator.h)