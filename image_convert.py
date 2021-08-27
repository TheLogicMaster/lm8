#!/bin/python

# Converts images into lm-8 compatible binary formats

import sys
import os
from PIL import Image
import argparse

parser = argparse.ArgumentParser(description='Convert an image to a binary')
parser.add_argument('image', help='The image to convert')
parser.add_argument('-t', '--type', default='sprite', choices=['sprite', 'oled'], type=str.lower, help="The type of image to convert")
args = parser.parse_args()

img = Image.open(args.image)

output = bytearray()

if args.type == 'sprite':
    if img.size[0] != 8 or img.size[1] != 8:
        print("Image must be 8x8 pixels")
        exit(-1)

    pixels = img.convert('RGB').load()

    for y in range(img.size[1]):
        for x in range(img.size[0]):
            output.append(int(pixels[x, y][0] * 0x7 / 0xFF) << 5 | int(pixels[x, y][1] * 0x7 / 0xFF) << 2 | int(pixels[x, y][2] * 0x3 / 0xFF))
elif args.type == 'oled':

    if img.size[0] != 128 or img.size[1] != 64:
        print("Image must be 128x64 pixels")
        exit(-1)

    pixels = img.convert('L').load()

    for page in range(8):
        for x in range(128):
            column = 0
            for i in range(8):
                if pixels[x, page * 8 + i] > 0:
                    column |= 1 << i
            output.append(column)

with open(os.path.splitext(sys.argv[1])[0] + ".bin", "wb") as f:
    f.write(output)
