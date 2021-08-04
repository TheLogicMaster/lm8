#!/bin/bash

# Patches the project microcode

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
PROJECT=${SCRIPT_DIR}/fpga

SWITCH=$(python3 "${SCRIPT_DIR}/rom_to_vhdl.py" "${SCRIPT_DIR}/../microcode.bin" 9 3)

perl -0777 -i -pe "s/CASE(.|\R)*END CASE/CASE (Address) IS\n${SWITCH}\n         END CASE/g" "${PROJECT}/vhdl/memory/ROMCONTENTS_Microcode_behavior.vhd"
