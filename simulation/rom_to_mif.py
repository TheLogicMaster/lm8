#!/bin/python3

# This script takes a ROM binary and outputs an Intel Memory Initialization Format file

import sys


def main():
    if len(sys.argv) != 3:
        print('Usage: python3 rom_to_vhdl_switch.py <binary_file> <output file>')
        exit(-1)

    f = open(sys.argv[1], 'rb')
    binary = f.read()
    f.close()

    f = open(sys.argv[2], 'w')
    f.writelines([
        f"DEPTH = {0x8000};\n",
        "WIDTH = 8;\n",
        "ADDRESS_RADIX = HEX;\n",
        "DATA_RADIX = HEX;\n"
        "CONTENT\n",
        "BEGIN\n"
    ])
    for address in range(len(binary)):
        f.write(f'{format(address, "02x")}: {format(binary[address], "02x")};\n')
    f.write("END\n")
    f.close()


if __name__ == '__main__':
    main()
