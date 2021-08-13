#!/bin/bash

# Converts a compiled .SOF file to a .POF file and persistently flashes the dev board

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

# Convert programming file
"${QUARTUS_DIR}/quartus_cpf" -c "${SCRIPT_DIR}/fpga/LogisimToplevelShell.sof" "${SCRIPT_DIR}/fpga/LogisimToplevelShell.pof"

(
    cd "${PROJECT}"

    # Flash dev board
    CABLE=$([[ $("${QUARTUS_DIR}/quartus_pgm" --list) =~ ^([0-9]\)\ )(.+\]) ]] && echo ${BASH_REMATCH[2]})
    "${QUARTUS_DIR}/quartus_pgm" -c \"${CABLE}\" -m jtag -o "P;LogisimToplevelShell.pof@1"
)
