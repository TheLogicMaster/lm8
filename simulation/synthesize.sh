#!/bin/bash

# Synthesizes VHDL, generates Quartus II project, and injects ADC code. Requires Quartus project to be closed.

set -e

QUARTUS_DIR=/mnt/Storage/Syncronized/Programs/Linux/Quartus-Prime/quartus/bin
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
PROJECT=${SCRIPT_DIR}/fpga
WORKSPACE=$(realpath ~/logisim_evolution_workspace/simulation/main)

# Copy generated Logisim files
rm -rf "${PROJECT}"
cp -r "${WORKSPACE}" "${PROJECT}"

# Copy additional Quartus files
cp -r "${SCRIPT_DIR}"/ip/* "${PROJECT}"
cp "${SCRIPT_DIR}/debug.stp" "${PROJECT}"
cp "${SCRIPT_DIR}/adc_controller.vhd" "${PROJECT}/vhdl/circuit/adc_dummy_behavior.vhd"

# Patch project assignments script for debugging and ADCs
adc_assignments="    set_global_assignment -name QIP_FILE \"${PROJECT}/adc/synthesis/adc.qip\""
adc_assignments="${adc_assignments}\n    set_global_assignment -name VHDL_FILE \"${PROJECT}/adc/synthesis/adc.vhd\""
adc_assignments="${adc_assignments}\n    set_global_assignment -name ENABLE_SIGNALTAP ON"
adc_assignments="${adc_assignments}\n    set_global_assignment -name USE_SIGNALTAP_FILE \"${PROJECT}/debug.stp\""
adc_assignments="${adc_assignments}\n    set_global_assignment -name SIGNALTAP_FILE \"${PROJECT}/debug.stp\""
sed -i "s@# Include all entities and gates@# Include all entities and gates\n${adc_assignments}@" "${PROJECT}/scripts/AlteraDownload.tcl"
sed -i "s@${WORKSPACE}@${PROJECT}@" "${PROJECT}/scripts/AlteraDownload.tcl"

# Patch main_behavior to fix ADC clock
sed -ri "s/adc_clk\ *=>\ *\w+/adc_clk=>LOGISIM_CLOCK_TREE_0(4)/" "${PROJECT}/vhdl/circuit/main_behavior.vhd"

(
    cd "${PROJECT}"

    # Setup project with board assignments
    "${QUARTUS_DIR}/quartus_sh" -t ./scripts/AlteraDownload.tcl

    # Generate debugging info
    "${QUARTUS_DIR}/quartus_stp" LogisimToplevelShell --stp_file ./debug.stp
)
