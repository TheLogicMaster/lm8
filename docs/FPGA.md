# LM-8 FPGA Implementation
The FPGA implementation is primarily based around Logisim-evolution generated VHDL code. To add
additional functionality and automation, various scripts in the `simulation` directory were 
written. The project was developed specifically for the DE10-Lite FPGA development board since
it's what I had lying around. Since the whole deployment process is built around Bash scripts, only
Linux is supported for deploying with ADC and UART support.

## VHDL Port
The direct VHDL port of the Logisim schematic makes most of the Logisim deployment process obsolete.
This is a full port that supports all LM-8 functionality and doesn't require the use of most of the
bash scripts. 

## Build Process
The build process to go from writing an assembly program to deploying was originally quite involved
and tedious, but the newly automated process greatly simplified everything. To summarize
the process, you need to generate the VHDL code from the Logisim circuit, inject the assembled
program binary, compile the code, then finally deploy to the dev board. As mentioned, this was
originally all done manually using the program GUIs, but now deploying can be done with a single
click from the IDE.

## Direct Logisim Deployment
This method of deploying to the dev board is the simplest, but doesn't allow for using Intel FPGA
IPs, so it isn't posible to use the ADC and UART components.
1. Ensure Logisim-evolution, Quartus Prime, Python 3.8, and Perl are installed.
2. Set the `Altera\Intel Quartus toolpath` setting in Logisim to the Quartus `bin` dir.
3. Under `FPGA Commander Settings` in Logisim, add the `DE10-LITE.xml` board descriptor file and
   set the `Hardware description language` to `VHDL`.
4. Open the `simulation.circ` project file in Logisim.
5. There will be `Incompatible Widths` errors initially, since the `Port I/O` components 
   currently loose their state upon reloading the project. Simply reconfigure each component
   with the pin number and port type specified by the label below each. 
6. If the VHDL components are missing from the circuit, just place them in where they go.
7. Right-click on the `Program` ROM component and select `Load Image...`. Select the program ROM
   that you want to deploy.
8. Under `FPGA` in Logisim, select `Synthesize and Download`.
9. From the new window, set the frequency to the highest one available for around 2 MHz. It's
   possible to further increase this by changing the divider value to as low as 2, but it's not
   necessary. This can also be lowered substantially for debugging. On Windows there seems to be an
   issue if you don't manually specify the divider value as 2 where the clock doesn't work.
10. Select `Annotate` to ensure that all components have labels.
11. Ensure `Toplevel` is `main` and select `Synthesize and Download`.
12. Press `Execute` to start deploying to the board, which should be connected.
13. Press `done` in the component mapping window that pops up to proceed with the deployment.

## Patched Deployment
This method picks up right after the previous method, except you select `Generate HDL only` to
only generate the Quartus project files without compiling and deploying to the board. At this
point, the project isn't usable and scripts are necessary to fully set it up and patch the
files to add the ADC and UART features. Set the `QUARTUS_DIR` variable in `env.sh` to the 
Quartus Prime `bin` directory path to set up your local environment. To set up the Quartus 
project and patch the files, run the `synthesize.sh` script. At this point, you could just 
open the project in Quartus and deploy like normal. If you want to deploy without opening 
Quartus, run the `compile_and_flash.sh`script. To update the program without re-generating 
the whole project, run the `patch_rom.sh` script to update the VHDL code with the new program ROM.
Typically, you should just use the `incremental_flash.sh` script to compile and flash with a ROM
because it only compiles the project if it hasn't yet been compiled. This drastically cuts down
on build times when testing programs and not changing the circuit.

## Debugging
It's possible to debug programs on the FPGA using the normal Quartus tools. The `debug.sh` script
enables signal tap debugging, loads the signal tap assignment file in Quartus, then opens Quartus
itself. Stepping through the CPU with one of the buttons is doable by connecting the `clk_btn`
button in Logisim to the `clk` tunnel and updating the hardware mapping to connect that button
to one of the physical buttons. For it to be usable, the Schmitt trigger should be enabled for the
button in Quartus. Then just use the signal tap window in Quartus to view the computer registers
while stepping through the program cycle by cycle. The extra hardware components in Logisim are
also for debugging. The seven segment displays and LEDs can be re-mapped to physical ones to
display their respective values for debugging the computer's state.

## Windows Subsystem for Linux
- Install [Ubuntu WSL](https://ubuntu.com/wsl) to get the ability the batch scripts from Windows.
- Set the path to the Quartus bin directory in the Windows section of the `env.sh` file.
- Navigate to the project simulation directory in a WSL terminal(If in Windows Documents directory: 
  `cd /mnt/c/Users/<User>/Documents/<project>/simulation`).
- Run the scripts normally but with `sudo` to prevent Windows permission issues(To compile:
  `sudo ./compile.sh`).

## Scripts
- `env.sh`: Used to configure the environment variables for all the other scripts.
- `synthesize.sh`: Sets up and patches the Quartus project with generated IP components.
- `synthesize_and_flash.sh`: Synthesizes and compiles the project, then flashes the board.
- `compile.sh`: Compiles the synthesized project to generate the SOF file.
- `compile_and_flash.sh`: Compiles the synthesized project then flashes the board.
- `debug.sh`: Sets up the project for debugging and opens Quartus.
- `flash.sh`: Flashes the compiled SOF file to the dev board.
- `incremental_flash.sh`: Patches the project with the ROM and flashes without a full project compile.
- `persisten_flash.sh`: Converts the compiled SOF file to a POF file and flashes it.
- `patch_rom.sh`: Patches the program VHDL ROM with the specified ROM file.
- `patch_microcode.sh`: Patches the microcode VHDL ROM with `microcode.bin`.
