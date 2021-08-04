#!/bin/bash

# Synthesizes and opens the project in Quartus for debugging

set -e

QUARTUS_DIR=/mnt/Storage/Syncronized/Programs/Linux/Quartus-Prime/quartus/bin
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
PROJECT=${SCRIPT_DIR}/fpga

"${SCRIPT_DIR}/synthesize.sh"

"${QUARTUS_DIR}/quartus" "${PROJECT}/LogisimToplevelShell.qpf"
