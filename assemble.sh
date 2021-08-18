#!/bin/bash

# Assemble all programs in programs directory

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

(
    cd "${SCRIPT_DIR}/programs" || exit -1

    for f in ./*.asm
    do
        echo "Assembling: $f"
        python ../assembler.py "$f"
    done
)
