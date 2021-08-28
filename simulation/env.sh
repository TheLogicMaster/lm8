#!/bin/bash

# Source this file to load project environment variables

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

PROJECT="${SCRIPT_DIR}/fpga"

if grep -q Microsoft /proc/version; then
  # WSL variables
  QUARTUS_DIR_EXT='C:\intelFPGA_lite\20.1\quartus\bin64'

  QUARTUS_DIR="$(wslpath "${QUARTUS_DIR_EXT}")"
  WORKSPACE_EXT="$(wslpath -m "$(wslpath "$(wslvar USERPROFILE)")")"/logisim_evolution_workspace/simulation/main
  WORKSPACE="$(wslpath "${WORKSPACE_EXT}")"
  EXT=".exe"
  PROJECT_EXT="$(wslpath -m "${PROJECT}")"
else
  # Linux variables
  QUARTUS_DIR=/mnt/Storage/Syncronized/Programs/Linux/Quartus-Prime/quartus/bin

  WORKSPACE="$(realpath ~/logisim_evolution_workspace/simulation/main)"
  EXT=""
  QUARTUS_DIR_EXT="${QUARTUS_DIR}"
  PROJECT_EXT="${PROJECT}"
  WORKSPACE_EXT="${WORKSPACE}"
fi
