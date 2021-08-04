#!/bin/bash

# Converts a compiled .SOF file to a .POF file and persistently flashed the dev board

set -e

QUARTUS_DIR=/mnt/Storage/Syncronized/Programs/Linux/Quartus-Prime/quartus/bin
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
PROJECT=${SCRIPT_DIR}/fpga

# Convert programming file
"${QUARTUS_DIR}/quartus_cpf" -c "${SCRIPT_DIR}/fpga/LogisimToplevelShell.sof" "${SCRIPT_DIR}/fpga/LogisimToplevelShell.pof"

(
    cd "${PROJECT}"

    # Flash dev board
    CABLE=$([[ $("${QUARTUS_DIR}/quartus_pgm" --list) =~ ^([0-9]\)\ )(.+\]) ]] && echo ${BASH_REMATCH[2]})
    "${QUARTUS_DIR}/quartus_pgm" -c \"${CABLE}\" -m jtag -o "P;LogisimToplevelShell.pof@1"
)
