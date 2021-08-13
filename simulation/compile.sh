 #!/bin/bash

# Compiles the project

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

(
    cd "${PROJECT}"

    "${QUARTUS_DIR}/quartus_map" LogisimToplevelShell --optimize=area
    "${QUARTUS_DIR}/quartus_sh" --flow compile LogisimToplevelShell
)
