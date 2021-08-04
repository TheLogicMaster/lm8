#!/bin/bash

# Patches the project ROM with the specified program binary file

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
PROJECT=${SCRIPT_DIR}/fpga

if [ -z "$1" ]
then
    echo "Usage: patch_rom.sh <program_binary>"
    exit -1
fi

SWITCH=$(python3 "${SCRIPT_DIR}/rom_to_vhdl.py" "$1" 15 1)

perl -0777 -i -pe "s/CASE(.|\R)*END CASE/CASE (Address) IS\n${SWITCH}\n         END CASE/g" "${PROJECT}/vhdl/memory/ROMCONTENTS_Program_behavior.vhd"
