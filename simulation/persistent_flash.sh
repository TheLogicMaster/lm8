#!/bin/bash

# Converts a compiled .SOF file to a .POF file and persistently flashes the dev board

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

# Convert programming file
"${QUARTUS_DIR}/quartus_cpf${EXT}" -c "${PROJECT_EXT}/LogisimToplevelShell.sof" "${PROJECT_EXT}/LogisimToplevelShell.pof"

(
    cd "${PROJECT}"

    # Flash dev board
    CABLE="$([[ $("${QUARTUS_DIR}/quartus_pgm${EXT}" --list) =~ ^([0-9]\)\ )(.+\]) ]] && echo ${BASH_REMATCH[2]})"
    "${QUARTUS_DIR}/quartus_pgm${EXT}" -c "${CABLE}" -m jtag -o "P;LogisimToplevelShell.pof@1"
)
