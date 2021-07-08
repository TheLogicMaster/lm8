#!/bin/bash

# Assemble all programs in programs directory

for f in ./programs/*.asm
do
    echo "Assembling: $f"
    python assembler.py "$f"
done
