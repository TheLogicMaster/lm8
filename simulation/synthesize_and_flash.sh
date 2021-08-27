#!/bin/bash

# synthesizes, compiles, and flashes the project to the dev board using the specified ROM file

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

if [ -z "$1" ]
then
    echo "Usage: synthesize_and_flash.sh <program_binary>"
    exit -1
fi

"${SCRIPT_DIR}/synthesize.sh"

"${SCRIPT_DIR}/patch_rom.sh" "$1"

"${SCRIPT_DIR}/compile.sh"

"${SCRIPT_DIR}/flash.sh"
