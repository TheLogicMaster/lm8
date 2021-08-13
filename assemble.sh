#!/bin/bash

# Assemble all programs in programs directory

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

for f in "${SCRIPT_DIR}/programs/"*.asm
do
    echo "Assembling: $f"
    python assembler.py "$f"
done
