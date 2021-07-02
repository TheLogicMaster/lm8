# Custom Computer Emulator and Debugger
The emulator for custom computer architecture project

## Features
- Breakpoint/step-through debugging
- Memory/register inspection
- Emulated De10-Lite I/O
- Mapping of peripherals like controllers to GPIO
- 160 by 128 pixel display with Sprite rendering capabilities

## Running
The Windows and Linux executables can be directly run or passed a ROM file as a parameter
to load said ROM on start.

## Building
CMake is used on both Windows and Linux for compilation. A GitHub Actions Workflow builds
the Windows executable for every commit and temporarily just uploads it as an artifact.

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
``` bash
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