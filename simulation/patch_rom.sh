#!/bin/bash

# Patches the project ROM with the specified program binary file

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

if [ -z "$1" ]
then
    echo "Usage: patch_rom.sh <program_binary>"
    exit -1
fi

python3 "${SCRIPT_DIR}/rom_to_mif.py" "$1" "${PROJECT}/rom.mif"
