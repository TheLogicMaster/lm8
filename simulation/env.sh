#!/bin/bash

# Source this file to load project environment variables

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

QUARTUS_DIR=/mnt/Storage/Syncronized/Programs/Linux/Quartus-Prime/quartus/bin
QSYS_GENERATE=${QUARTUS_DIR}/../sopc_builder/bin/qsys-generate
PROJECT=${SCRIPT_DIR}/fpga
WORKSPACE=$(realpath ~/logisim_evolution_workspace/simulation/main)
