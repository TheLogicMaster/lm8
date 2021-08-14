# Custom Computer
This project is a custom 8-bit computer architecture comprised of an Assembler, an Emulator,
a Logisim-Evolution simulation, and an FPGA implementation.

<img src="media/snake_title.png?raw=true" width="811" height="648">
<img src="media/snake_game.png?raw=true" width="811" height="648">

## Emulator
- [Online Demo](https://thelogicmaster.github.io/CustomComputer/)
- Breakpoint/step-through debugging
- Memory/register inspection
- Emulated De10-Lite I/O
- Mapping of peripherals like controllers to GPIO
- 160 by 128 pixel display with Sprite rendering capabilities

<img src="media/debugger.png?raw=true" width="688" height="366">

## Program Assembler
To assemble one of the test programs, run:
``` python
python assembler.py programs/<program>.asm
```
The bash script `assemble.sh` exists for assembling all programs at once. To run an assembled ROM, either run 
the emulator with the ROM filename as a parameter or run the emulator and browse and open a ROM.

## Emulator Compilation
For Linux and Windows CMake is used for CLion compatibility. The Emscripten port uses an almost
stock Makefile based on the ImGui examples. GitHub Actions Workflows are set up to automatically
build and release for all three platforms on tagged commits. 

### Windows
- Requires [MinGW](http://mingw-w64.org/) and [CMake](https://cmake.org/) being installed and added to the PATH
- GLEW, SDL2, and Dirent are all included in the repo and automatically used

Build emulator:
```
# Run in CMD in emulator directory to build executable
mkdir build
cd build
cmake -G "CodeBlocks - MinGW Makefiles" ..
mingw32-make
```

### Linux
Requires 'libsdl2-dev' and 'libglew-dev'

Install dependencies:
```bash
# Ubuntu/Debian install
sudo apt install libsdl2-dev libglew-dev
```

Build emulator:
```bash
# Run in emulator project directory
mkdir build
cd build
cmake ..
make
```

### Emscripten
The [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html) is required
for building the Web port of the emulator. Hardcoded ROMs are fetched from the served
web directory.

Linux building:
```bash
# Run from project's Emscripten directory
source {Emscripten SDK dir}/emsdk_env.sh # Set Emscripten environment variables
make # Build web port
```
To build and serve from dev server with built ROMs:
```bash
make serve
```
