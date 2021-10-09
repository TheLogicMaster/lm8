# LM-8 Logisim-evolution and Digital Simulations
The simulation part of the project is used for developing and debugging the CPU circuit design. 
Logisim was used for the initial CPU design then it was later ported to VHDL directly and a Digital
simulation. The Digital simulation only supports basic I/O functionality but the main CPU is functional.

## Issues
- Logisim-evolution can be buggy when it comes to messing around too much with splitters, leading
to unexpected behavior, especially in the generated VHDL code. 
- The `Port I/O` components get reset upon opening the project, so they need to be manually
  re-configured every time according to the labels beneath them. They are also broken
  completely if you try to use them in output-only or input-only modes.
- The simulation errors if VHDL components are present in the circuit when trying to simulate
  without the VHDL simulator installed, so it necessitates temporarily deleting said components to
  test in the simulator.
  The text editor for editing VHDL components is terrible and deletes all of your code if you use
  the undo/redo features, so just use an external editor.
- Programs that read from GPIO won't work at all since the `Port I/O` components read an undefined
  state, so it results in errors propagating throughout the circuit.
- Outputs from VHDL components will be undefined, causing any components connected to error, 
  quickly contaminating the entire simulation. To get around this, connect an OR gate directly
  to the VHDL component to prevent leaving any dangling wires and "or" it with a zero constant.
  
## Simulation-only Features
- TTY Output: The Logisim `TTY` component can be added where labeled to enable displaying
  any characters output to the Serial port.
- Video Output: The Logisim `RGB Video` component allows for basic output of program graphics,
  though the color palette is completely wrong since it doesn't support RGB332, so it's only
  suitable for debugging. The Simulation is also just far too slow to render more than a few
  sprites in a reasonable amount of time. 

## Updating Microcode and ROM
- The microcode and program ROM can easily be updated in Logisim by right-clicking on the respective
component and loading the generated binary files.
- In Digital, the `microcode-LE.bin` file is required so the data is little-endian formatted.