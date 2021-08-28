#!/bin/python3

# This script will assemble a program into the build folder in the current directory and optionally run it with the emulator or flash an FPGA

import argparse
import os
import re
import subprocess
import shlex

# Constants to be substituted during assembly
constants = {
    "serial":            0,
    "serial_available":  1,
    "graphics_x":        30,
    "graphics_y":        31,
    "draw_pixel":        32,
    "draw_sprite":       33,
    "clear_screen":      34,
    "controller_up":     35,  # GPIO 0
    "controller_down":   36,  # GPIO 1
    "controller_left":   37,  # GPIO 2
    "controller_right":  38,  # GPIO 3
    "rand":              93,
    "swap_display":      94,
    "gpio_output":       95,
    "gpio_input":        96,
    "arduino_output":    97,
    "arduino_input":     98,
    "pwm_enable":        99,
    "pwm_disable":       100,
    "serial_enable":     107,
    "microseconds":      0,
    "centimilliseconds": 1,
    "decimilliseconds":  2,
    "milliseconds":      3,
    "centiseconds":      4,
    "deciseconds":       5,
    "seconds":           6,
    "decaseconds":       7
}
constants.update({"seven_segment_" + str(i): i + 2 for i in range(6)})
constants.update({"button_" + str(i): i + 8 for i in range(2)})
constants.update({"led_" + str(i): i + 10 for i in range(10)})
constants.update({"switch_" + str(i): i + 20 for i in range(10)})
constants.update({"gpio_" + str(i): i + 35 for i in range(36)})
constants.update({"arduino_" + str(i): i + 71 for i in range(16)})
constants.update({"adc_" + str(i): i + 87 for i in range(6)})
constants.update({"pwm_" + str([3, 5, 6, 9, 10, 11][i]): i + 101 for i in range(6)})
constants.update({"timer_unit_" + str(i): i + 108 for i in range(2)})
constants.update({"timer_count_" + str(i): i + 110 for i in range(2)})
constants.update({"timer_" + str(i): i + 112 for i in range(2)})

line_number = 0
file = ""
memory = False
output = bytearray()
address = 0
data_address = 0x8000
labels = {}
label_addresses = {}
label_jumps = {}
label_imm_addresses = {}


# Print error and current line number before exiting
def error(cause, line=None):
    print("Error: " + cause)
    if line is None or line >= 0:
        print(f"{file}: Line {line_number if line is None else line}")
    exit(-1)


# Error if the wrong number of parameters was provided
def ensure_params(params, num):
    if len(params) != num:
        error("Wrong number of parameters")


# Increase the size of the output array if less than the supplied size
def ensure_output_size(size):
    while len(output) < size:
        output.append(0)


# Append a single byte to the output from an integer value
def output_byte(byte):
    global address
    ensure_output_size(address + 1)
    output[address] = byte
    address += 1


# Append a two byte address to the output from an integer value
def output_address(addr):
    global address
    temp = addr.to_bytes(2, 'big')
    ensure_output_size(address + 2)
    output[address] = temp[0]
    output[address + 1] = temp[1]
    address += 2


# Convert register letter IDs to numeric ones
def parse_reg(param):
    if param == "a":
        return 0b00
    elif param == "b":
        return 0b01
    elif param == "h":
        return 0b10
    elif param == "l":
        return 0b11
    else:
        error("Invalid register")


# Convert condition flags to numeric form
def parse_condition(param):
    if param == "z":
        return 0b00
    elif param == "c":
        return 0b01
    elif param == "n":
        return 0b10
    elif param == "v":
        return 0b11
    else:
        error("Invalid condition")


# Attempt to parse an address, returning None on failure
def parse_address(param):
    match = re.search(r"^\$([0-9a-f]+)$", param)
    if not match:
        return None
    if len(match[1]) > 4:
        error("Address too large")
    return int(match[1], 16)


# Parse either a label or an immediate address and append it to the output, error on failure
def output_location(param):
    global address
    addr = parse_address(param)
    if addr is not None:
        output_address(addr)
        return
    match = re.search(r"^(\w+)$", param)
    if not match:
        error("Invalid label/address")
    label_addresses[address] = match[1]
    address += 2


# Normalize a byte if it is negative and error if value is invalid
def constrain_byte(byte):
    if byte < 0:
        byte += 255
    if byte > 255 or byte < 0:
        error("Number out of range")
    return byte


# Parse an immediate byte and append it to the output, error on failure
def output_immediate(param):
    global address
    match = re.search(r"^'(.+)'$", param)
    if match:
        char = match[1].encode().decode("unicode-escape").encode()
        if len(char) != 1:
            error("Invalid char")
        output_byte(char[0])
        return
    match = re.search(r"^%([01]+)$", param)
    if match:
        if len(match[1]) > 8:
            error("Invalid byte")
        output_byte(int(match[1], 2))
        return
    match = re.search(r"^\$([0-9a-f]+)$", param)
    if match:
        if len(match[1]) > 2:
            error("Invalid byte")
        output_byte(int(match[1], 16))
        return
    match = re.search(r"^#-*([0-9]+)$", param)
    if match:
        output_byte(constrain_byte(int(match[1])))
        return
    match = re.search(r"^=(\w+)$", param)
    if not match:
        error("Invalid immediate")
    label_imm_addresses[address] = match[1]
    address += 1


# Outputs an instruction that takes a register and an immediate
def output_imm_reg_instr(params, instr):
    ensure_params(params, 2)
    output_byte(instr | parse_reg(params[1]))
    output_immediate(params[0])


# Output an instruction that takes a register
def output_reg_instr(params, instr):
    ensure_params(params, 1)
    output_byte(instr | parse_reg(params[0]))


# Output an instruction that takes an immediate
def output_imm_instr(params, instr):
    ensure_params(params, 1)
    output_byte(instr)
    output_immediate(params[0])


# Output an implicit instruction
def output_implicit_instr(params, instr):
    ensure_params(params, 0)
    output_byte(instr)


# Output an instruction that takes either an immediate or a register
def output_imm_or_reg_instr(params, instr_imm, instr_reg):
    ensure_params(params, 1)
    if re.search(r"^[abhl]$", params[0]):
        output_reg_instr(params, instr_reg)
    else:
        output_imm_instr(params, instr_imm)


# Output a relative jump byte given a label or immediate
def output_relative_jump(param):
    global address
    match = re.search(r"^(\w+)$", param)
    if match:
        label_jumps[address] = param
        address += 1
    else:
        output_immediate(param)


def parse_file():
    global line_number
    global address
    global data_address
    global file
    global constants

    data_section = False

    f = open(file)
    lines = f.readlines()
    f.close()

    for line in lines:
        line_number += 1

        # Remove comments
        line = line.split(";")[0]

        # Get label
        match = re.search(r"^\s*(\w+):", line.lower())
        if match:
            if match[1] in labels:
                error("Duplicate label: " + match[1])
            labels[match[1]] = data_address if data_section else address
            line = line[len(match[0]):]

        # Get instruction
        match = re.search(r"^\s*(\w+)", line.lower())
        if not match:
            continue
        instr = match[1]
        line = line[len(match[0]):]

        # Get parameters
        params = line.split(",")
        if re.sub(r"\s+", "", params[0]) == "":
            params = []

        # Make everything except strings lowercase, remove surrounding whitespace, and substitute constants
        for i in range(len(params)):
            if "\"" not in params[i] and "'" not in params[i]:
                params[i] = params[i].lower()
                for constant in constants:
                    params[i] = params[i].replace("{" + constant + "}", ("" if type(constants[constant]) is str else "#") + str(constants[constant]))
            params[i] = re.sub(r"^\s+|\s+$", "", params[i])

        if data_section and instr != "var" and instr != "org":
            error("Only VAR and ORG are permitted in the data section")

        if instr == "org":
            ensure_params(params, 1)
            parsed = parse_address(params[0])
            if parsed is None:
                error("Failed to parse origin address")
            if data_section:
                if parsed < 0x8000:
                    error("Only addresses at or above 0x8000 are allowed in the data section")
                data_address = parsed
            else:
                address = parsed

        elif instr == "def":
            ensure_params(params, 1)
            match = re.search(r"^(\w+)=(.+)$", params[0])
            if not match:
                error("Invalid definition")
            constants[match[1]] = match[2]

        elif instr == "include":
            current_line = line_number
            current_file = file
            ensure_params(params, 1)
            match = re.search(r"^\"(.+)\"$", params[0])
            if not match:
                error("Invalid include file")
            file = os.path.join(os.path.dirname(file), match[1])
            try:
                parse_file()
            except RecursionError:
                error("Recursive dependencies")
            file = current_file
            line_number = current_line

        elif instr == "data":
            ensure_params(params, 0)
            data_section = True

        elif instr == "var":
            if not data_section:
                error("The VAR instruction can only be used in the data section")
            if len(params) == 0:
                data_address += 1
            elif len(params) == 1:
                match = re.search(r"^\[([0-9]+)]$", params[0])
                if not match:
                    error("Invalid var array")
                data_address += int(match[1])
            else:
                error("Invalid parameters")

        elif instr == "db":
            if len(params) == 0:
                error("Parameters are required")
            for param in params:
                if param.startswith("#"):
                    output_byte(constrain_byte(int(param[1:])))
                elif param.startswith("$"):
                    if len(param) > 3 or len(param) < 2:
                        error("Invalid byte")
                    output_byte(int(param[1:], 16))
                elif param.startswith("\""):
                    for byte in param[1:-1].encode().decode("unicode-escape").encode():
                        output_byte(byte)
                else:
                    error("Invalid byte data")

        elif instr == "bin":
            ensure_params(params, 1)
            match = re.search(r"^\"(.+)\"$", params[0])
            if not match:
                error("Invalid binary file")
            with open(os.path.join(os.path.dirname(file), match[1]), "rb") as f:
                while byte := f.read(1):
                    output_byte(ord(byte))

        elif instr == "nop":
            output_implicit_instr(params, 0b00000000)

        elif instr == "ldr":
            ensure_params(params, 2)
            if params[0] == "[hl]":
                output_byte(0b00001100 | parse_reg(params[1]))
            elif params[0].startswith("["):
                output_byte(0b00001000 | parse_reg(params[1]))
                output_location(params[0][1:-1])
            else:
                output_byte(0b00000100 | parse_reg(params[1]))
                output_immediate(params[0])

        elif instr == "str":
            ensure_params(params, 2)
            if params[0] == "[hl]":
                output_byte(0b00010100 | parse_reg(params[1]))
            elif params[0].startswith("["):
                output_byte(0b00010000 | parse_reg(params[1]))
                output_location(params[0][1:-1])
            else:
                error("Invalid addressing mode")

        elif instr == "lda":
            ensure_params(params, 1)
            output_byte(0b00011000)
            output_location(params[0])

        elif instr == "in":
            if len(params) == 1:
                output_reg_instr(params, 0b10001000)
            else:
                output_imm_reg_instr(params, 0b00011100)

        elif instr == "out":
            if len(params) == 1:
                output_reg_instr(params, 0b10001100)
            else:
                output_imm_reg_instr(params, 0b00100000)

        elif instr == "inc":
            output_reg_instr(params, 0b00100100)

        elif instr == "dec":
            output_reg_instr(params, 0b00101000)

        elif instr == "ina":
            output_implicit_instr(params, 0b00101100)

        elif instr == "dea":
            output_implicit_instr(params, 0b00110000)

        elif instr == "add":
            output_imm_or_reg_instr(params, 0b00110100, 0b00111000)

        elif instr == "adc":
            output_imm_or_reg_instr(params, 0b00111100, 0b01000000)

        elif instr == "sub":
            output_imm_or_reg_instr(params, 0b01000100, 0b01001000)

        elif instr == "sbc":
            output_imm_or_reg_instr(params, 0b01001100, 0b01010000)

        elif instr == "and":
            output_imm_or_reg_instr(params, 0b01010100, 0b01011000)

        elif instr == "or":
            output_imm_or_reg_instr(params, 0b01011100, 0b01100000)

        elif instr == "xor":
            output_imm_or_reg_instr(params, 0b01100100, 0b01101000)

        elif instr == "cmp":
            output_imm_or_reg_instr(params, 0b01101100, 0b01110000)

        elif instr == "jmp":
            ensure_params(params, 1)
            if params[0] == "hl":
                output_byte(0b01111000)
            else:
                output_byte(0b01110100)
                output_location(params[0])

        elif instr == "jr":
            if len(params) == 1:
                output_byte(0b01111100)
            else:
                ensure_params(params, 2)
                code = 0b10000100 if re.search(r"^n[zcnv]$", params[1]) else 0b10000000
                output_byte(code | parse_condition(params[1][-1:]))
            output_relative_jump(params[0])

        elif instr == "push":
            output_reg_instr(params, 0b10010000)

        elif instr == "pop":
            output_reg_instr(params, 0b10010100)

        elif instr == "jsr":
            ensure_params(params, 1)
            output_byte(0b10011000)
            output_location(params[0])

        elif instr == "ret":
            output_byte(0b10011100)

        elif instr == "halt":
            output_implicit_instr(params, 0b10100000)

        elif instr == "lsl":
            output_implicit_instr(params, 0b10100100)

        elif instr == "lsr":
            output_implicit_instr(params, 0b10101000)

        elif instr == "asr":
            output_implicit_instr(params, 0b10101100)

        else:
            error("Unknown instruction: " + instr)


def main():
    global file
    global memory

    parser = argparse.ArgumentParser(description='Assemble a program. Assumed to be in the <project>/programs directory by default')
    parser.add_argument('program', help='The program file to assemble')
    parser.add_argument('-r', '--run', action='store_true', help="Whether to run the emulator after assembly")
    parser.add_argument('-f', '--fpga', default='none', choices=['none', 'patch', 'flash'], type=str.lower, help="Whether to patch or run for FPGA (Linux only)")
    parser.add_argument('-e', '--emulator', help='The path to the emulator if not "../emulator/build/Emulator"')
    parser.add_argument('-s', '--simulator', help='The path to the simulator if not "../simulator"')
    parser.add_argument('-m', '--memory', action='store_true', help='Assemble for being run by bootloader')
    args = parser.parse_args()

    memory = args.memory
    file = args.program

    parse_file()

    # Substitute labels for addresses
    for addr in label_addresses:
        label = label_addresses[addr]
        if label not in labels:
            error("No such label: " + label, -1)
        offset = 0
        if memory:
            if labels[label] < 0x8000:
                offset = 0x8000
            else:
                offset = 0x4000
        temp = (labels[label] + offset).to_bytes(2, 'big')
        ensure_output_size(addr + 2)
        output[addr] = temp[0]
        output[addr + 1] = temp[1]

    # Substitute labels for relative jumps
    for addr in label_jumps:
        label = label_jumps[addr]
        if label not in labels:
            error("No such label: " + label, -1)
        offset = labels[label] - (addr + 1)  # Relative to address of next instruction
        if offset < -128 or offset > 127:
            error("Too far relative jump: " + label, -1)
        if offset < 0:  # Convert to signed byte
            offset += 256
        ensure_output_size(addr + 1)
        output[addr] = offset

    # Substitute labels for immediate values
    for addr in label_imm_addresses:
        if memory:
            error("Immediate labels aren't available in memory mode", -1)
        label = label_imm_addresses[addr]
        if label not in labels:
            error("No such label: " + label, -1)
        if labels[label] > 255:
            error("Label address too high for immediate", -1)
        ensure_output_size(addr + 1)
        output[addr] = labels[label]

    # Ensure ROM size
    if memory:
        ensure_output_size(0x4000)
        if address > 0x4000:
            error("In-memory program size exceeded", -1)
    else:
        if address > 0x8000:
            error("Program size exceeded", -1)

    # Save machine code results
    rom_name = os.path.splitext(os.path.basename(args.program))[0] + (".img" if memory else ".bin")
    rom_path = os.path.join("./build", rom_name)
    os.makedirs("./build", exist_ok=True)
    f = open(rom_path, "wb")
    f.write(output)
    f.close()

    simulation_dir = args.simulator if args.simulator else os.path.join(os.pardir, 'simulation')
    if args.fpga == "patch":
        os.system(f'/bin/bash "{os.path.join(simulation_dir, "patch_rom.sh")}" "{os.path.abspath(rom_path)}"')
    elif args.fpga == "flash":
        os.system(f'/bin/bash "{os.path.join(simulation_dir, "incremental_flash.sh")}" "{os.path.abspath(rom_path)}"')

    if args.run:
        os.chdir('./build')
        cmd = f"\"{args.emulator if args.emulator else os.path.join(os.pardir, os.pardir, 'emulator/build/Emulator')}\" \"{rom_name}\""
        subprocess.run(shlex.split(cmd))


if __name__ == "__main__":
    main()
