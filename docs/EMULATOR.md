# LM-8 Emulator

## Features
- Modular C++ design for integration with any graphical backend
- Customizable and persistent ImGui UI for program execution and debugging
- Breakpoint debugging
- Memory and CPU register inspection
- Processor speed control
- Emulated DE10-Lite development board I/O
- Mapping of peripherals like controllers to GPIO
- Machine code disassembler
- Double buffered 160 by 128 pixel display output
- [Web Demo](https://thelogicmaster.github.io/lm8/)

## Usage
### Starting the emulator
- Either build the emulator from source or download a compiled binary from the 
  [Releases](https://github.com/TheLogicMaster/lm8/releases) page.
- The emulator can be run simply be opening the executable or by starting it from a terminal and specifying
  a program ROM file as a parameter.

## Quirks
- Instructions all take one cycle, so clock speed and instruction timing works differently.
- I/O works slightly differently than on the dev board. Each pin has a single boolean representing
  its state whether it is in input or output mode. This means that in input mode, setting a pin
  from the emulator sets the pin's value register. On actual hardware, the pin state is preserved
  regardless of output mode and is only controlled from the program. 

## Building
The repository has to be cloned with Git to set up the ImGui submodule:
```bash
git clone "https://github.com/TheLogicMaster/lm8.git" --recursive
```
### Linux
Requires 'libsdl2-dev' and 'libglew-dev'
```bash
# Ubuntu/Debian install dependencies
sudo apt install libsdl2-dev libglew-dev

# Run in emulator project directory to build
mkdir build
cd build
cmake ..
make
```
### Windows
- Requires [MinGW](http://mingw-w64.org/) and [CMake](https://cmake.org/) being installed and added to the PATH
- GLEW, SDL2, and Dirent are all included in the repo and automatically used by CMake
```
# Run in CMD in emulator directory to build executable
mkdir build
cd build
cmake -G "CodeBlocks - MinGW Makefiles" ..
mingw32-make
```
### Web Build
Requires the [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html) and Linux
```bash
# Run from project's Emscripten directory
source <Emscripten_SDK_dir>/emsdk_env.sh # Load Emscripten ENV variables
make # Compile for web

# Compile and serve from a local web server
make serve
```
The Web Demo has a few hardcoded ROMs specified in `main.cpp` which can be run. The ROMs get served
from the same directory as the produced web files.