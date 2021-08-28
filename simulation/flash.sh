#!/bin/bash

# Flashes the dev board with the compiled project

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

(
    cd "${PROJECT}"

    # Flash dev board
    CABLE="$([[ $("${QUARTUS_DIR}/quartus_pgm${EXT}" --list) =~ ^([0-9]\)\ )(.+\]) ]] && echo ${BASH_REMATCH[2]})"
    "${QUARTUS_DIR}/quartus_pgm${EXT}" -c "${CABLE}" -m jtag -o "P;LogisimToplevelShell.sof@1"
)
