#!/bin/bash

# Compiles the project and flashes the dev board

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"

"${SCRIPT_DIR}/compile.sh"

"${SCRIPT_DIR}/flash.sh"
