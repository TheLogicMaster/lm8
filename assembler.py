#!/bin/python3

import sys
import os
import re

# Constants to be substituted during assembly
constants = {
    "print_char": 0,
    "print_string": 1,
    "button_0": 8,
    "button_1": 9,
    "graphics_x": 30,
    "graphics_y": 31,
    "draw_pixel": 32,
    "draw_sprite": 33,
    "clear_screen": 34
}
constants.update({"seven_segment_" + str(i): i + 2 for i in range(6)})
constants.update({"led_" + str(i): i + 10 for i in range(10)})
constants.update({"switch_" + str(i): i + 20 for i in range(10)})

line_number = 0
output = bytearray()
address = 0
data_section = False
labels = {}
label_addresses = {}
label_jumps = {}
label_imm_addresses = {}


# Print error and current line number before exiting
def error(cause, line=None):
    print("Error: " + cause)
    if line is None or line >= 0:
        print("Line: " + str(line_number if line is None else line))
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


def main():
    if len(sys.argv) != 2:
        print("Usage: 'assembler.py <program>.asm'")
        exit(-1)

    # Read assembly file
    f = open(sys.argv[1], "r")
    lines = f.readlines()
    f.close()

    global line_number
    global address
    global data_section

    for line in lines:
        line_number += 1

        # Remove comments
        line = line.split(";")[0]

        # Get label
        match = re.search(r"^\s*(\w+):", line.lower())
        if match:
            if match[1] in labels:
                error("Duplicate label: " + match[1])
            labels[match[1]] = address
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
                    params[i] = params[i].replace("{" + constant + "}", "#" + str(constants[constant]))
            params[i] = re.sub(r"^\s+|\s+$", "", params[i])

        if data_section and instr != "var" and instr != "org":
            error("Only VAR and ORG are permitted in the data section")

        if instr == "org":
            ensure_params(params, 1)
            address = parse_address(params[0])
            if address is None:
                error("Failed to parse origin address")
            if data_section and address < 0x8000:
                error("Only addresses at or above 0x8000 are allowed in the data section")

        elif instr == "data":
            data_section = True
            address = 0x8000

        elif instr == "var":
            address += 1

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

        elif instr == "incbin":
            ensure_params(params, 1)
            match = re.search(r"^\"(.+)\"$", params[0])
            if not match:
                error("Invalid binary file")
            with open(match[1], "rb") as f:
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

        elif instr == "halt":
            output_implicit_instr(params, 0b11111100)

        else:
            error("Unknown instruction: " + instr)

    # Substitute labels for addresses
    for addr in label_addresses:
        label = label_addresses[addr]
        if label not in labels:
            error("No such label: " + label, -1)
        temp = labels[label].to_bytes(2, 'big')
        ensure_output_size(addr + 2)
        output[addr] = temp[0]
        output[addr + 1] = temp[1]

    # Substitute labels for relative jumps
    for addr in label_jumps:
        label = label_jumps[addr]
        if label not in labels:
            error("No such label: " + label, -1)
        offset = labels[label] - (addr + 1)  # Relative to address of next instruction
        if offset < 0:  # Convert to signed byte
            offset += 256
        if offset < 0 or offset > 255:
            error("Too far relative jump", -1)
        ensure_output_size(addr + 1)
        output[addr] = offset

    # Substitute labels for immediate values
    for addr in label_imm_addresses:
        label = label_imm_addresses[addr]
        if label not in labels:
            error("No such label: " + label, -1)
        if labels[label] > 255:
            error("Label address too high for immediate", -1)
        ensure_output_size(addr + 1)
        output[addr] = labels[label]

    # Save machine code results
    f = open(os.path.splitext(sys.argv[1])[0] + ".bin", "wb")
    f.write(output)
    f.close()


if __name__ == "__main__":
    main()
