#!/bin/python3

# This script takes a RAW binary file, converts it to VHDL switch when statements and spits it out to STDOUT

import sys


def main():
    if len(sys.argv) != 4:
        print('Usage: python3 binary_to_vhdl_switch.py <binary_file> <address_bits> <data_bytes>')
        exit(-1)
    address_size = int(sys.argv[2])
    data_size = int(sys.argv[3])
    if data_size == 0:
        print('Invalid data size')
        exit(-1)

    f = open(sys.argv[1], 'rb')
    binary = f.read()
    f.close()

    i = 0
    while i < len(binary):
        data = ""
        for j in range(data_size):
            data += format(binary[i], "02x")
            i += 1
        if int(data, 16) > 0:
            print(f'            WHEN "{format(int((i - data_size) / data_size), "0" + str(address_size) + "b")}" => Data <= x"{data}";')
    print('            WHEN OTHERS => Data <= (OTHERS => \'0\');')


if __name__ == '__main__':
    main()
