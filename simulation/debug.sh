#!/bin/bash

# Opens the project in Quartus for debugging

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

"${QUARTUS_DIR}/quartus${EXT}" "${PROJECT_EXT}/LogisimToplevelShell.qpf"
