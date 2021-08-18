# LM-8 Jetbrains Plugin
The Jetbrains plugin adds support for the custom assembly language used by this project.

## Features
- Syntax highlighting
- Run configuration generation
- Auto-complete
- Program Structure View support
- Label Goto and Usages support

## Installation
Either PyCharm or another Jetbrains IDE with the Python plugin is required. To install the plugin,
open the IDE settings and from the Plugins section select `Install Plugin from Disk...`. After
selecting the plugin JAR file, the plugin should be installed and LM-8 assembly files should be
supported.

## Plugin Configuration
Under `Tools` in the IDE settings after the plugin is installed, there should be a section for the
custom assembly language. From there, you can specify the paths to the emulator executable, the 
assembler script, and the path to the project `simulation` directory for FPGA purposes. If these
fields aren't specified, the plugin will assume that the `programs` directory of the repository is 
opened as the project in the IDE and paths will use the assembler defaults. 

## Basic Usage
To get started, it's easiest to simply open the `programs` folder from the repository as a project
from the IDE. Ensure the emulator has been built and is present in `<project>/emulator/build/`.
Upon creating or opening an assembly file, the top line will have a Run button that will generate
a run configuration based on the plugin configuration. The Python environment must be specified
either in the project settings or in each run configuration. 

## Run Configuration Options
The generated run configuration passes parameters directly to the assembler script for program
assembly and execution. See [Assembly](ASSEMBLER.md) to view all of the available options. This
allows customizing the run configurations to allow for directly deploying to the FPGA.