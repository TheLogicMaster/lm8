# LM-8 Bootloader
The bootloader is an assembly program that can load other programs from an SD card when flashed to
the dev board.

## Usage
1. Connect an SD card module to GPIO pins 4-7 for `CLK`, `MISO`, `MOSI`, and `CS`, resepectively.
2. Assemble a program with the `memory` flag to generate a compatible SD card image.
3. Use a program like [Etcher](https://www.balena.io/etcher/) to flash the SD card with the
   resulting image file.
4. Flash the bootloader program to the dev board. (Flash it persistently with the script for the
   best experience)
5. To update or change the program, simply power off the board and flash a new image to the SD
   card.

## Behind the Scenes
Normally, an LM-8 program runs directly in ROM and isn't modifiable at runtime except for the RAM
area of the address space. The bootloader connects to an unformatted SD card over SPI and directly
copies the first 16 KB into memory and executes the program in RAM. Since the space that would
normally be reserved for variables is being used to store the program, as well, the RAM address
space is split into two with half of it being allocated to the program and half to its variables.
A flag is available in the Assembler CLI to enable generating a flashable image. To allow labels
to work normally despite the addresses being shifted by 0x8000 bytes, the Assembler will modify
the variable and program label addresses to accommodate this. This means that any addresses that
aren't specified by labels won't be affected and will still point to their original locations. An
SDHC or SDXC SD card is required due to the block addressing format being simpler to use.
