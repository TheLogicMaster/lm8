#!/bin/python

import sys
import os
from PIL import Image

img = Image.open(sys.argv[1])
pixels = img.load()

output = bytearray()

if img.size[0] != 8 or img.size[1] != 8:
    print("Warning: Image should be 8x8 pixels")

for y in range(img.size[1]):
    for x in range(img.size[0]):
        output.append(int(pixels[x, y][0] * 0x7 / 0xFF) << 5 | int(pixels[x, y][1] * 0x7 / 0xFF) << 2 | int(pixels[x, y][2] * 0x3 / 0xFF))

with open(os.path.splitext(sys.argv[1])[0] + ".bin", "wb") as f:
    f.write(output)
