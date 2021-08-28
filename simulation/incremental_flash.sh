#!/bin/bash

# Patches the ROM and flashes the board, only compiling if project has yet to be compiled

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

if [ -z "$1" ]
then
    echo "Usage: incremental_flash.sh <program_binary>"
    exit -1
fi

"${SCRIPT_DIR}/patch_rom.sh" "$1"

if [ ! -f "${PROJECT}/LogisimToplevelShell.sof" ]; then
    "${SCRIPT_DIR}/compile.sh"
else
    (
        cd "${PROJECT}"
        "${QUARTUS_DIR}/quartus_cdb${EXT}" LogisimToplevelShell -c LogisimToplevelShell --update_mif
        "${QUARTUS_DIR}/quartus_asm${EXT}" LogisimToplevelShell
    )
fi

"${SCRIPT_DIR}/flash.sh"
