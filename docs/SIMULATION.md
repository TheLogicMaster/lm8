# LM-8 Logisim-evolution Simulation
The simulation part of the project is used for developing and debugging the CPU circuit design. 

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
  
## Updating Microcode and ROM
- The microcode and program ROM can easily be updated by right-clicking on the respective
component and loading the generated binary files.
