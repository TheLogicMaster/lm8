# Custom 8-bit Architecture JetBrains Plugin
This is a plugin for JetBrains IDEs for adding support for the assembly 
language used by my custom 8-bit architecture.

## Features
- Syntax highlighting
- Auto-completion
- Code reformatting
- Automatic run-configuration creation
- Structure view outline
- Instruction and label documentation
- Color customization
- Label navigation

## Usage
- Jetbrains IDE with Python Plugin or Pycharm is required
- Install plugin in IDE settings and select `Install plugin from disk`
- Open project's `programs` directory as a project with the IDE
- Set project SDK to a Python 3.8 interpreter
- The path to the emulator executable and Assembler script need to be specified if not
  using the default project structure on Linux based on the repo structure
- A program can be run simply by pressing the run icon in the sidebar at the top of
  an assembly file

## Development
### Updating Generated Files 
- Update the Parser by selecting `Generate Parser Code` in the context menu 
  for `Assembly.bnf`
- Update the Lexer by selecting `Run JFlex Generator` in the context menu for
  `Assembly.flex`

### Testing
- The gradle `runIde` task will spin up an IntelliJ instance with the plugin loaded