 #!/bin/bash

# Compiles the project

set -e

QUARTUS_DIR=/mnt/Storage/Syncronized/Programs/Linux/Quartus-Prime/quartus/bin
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
PROJECT=${SCRIPT_DIR}/fpga

(
    cd "${PROJECT}"

    "${QUARTUS_DIR}/quartus_map" LogisimToplevelShell --optimize=area
    "${QUARTUS_DIR}/quartus_sh" --flow compile LogisimToplevelShell
)
