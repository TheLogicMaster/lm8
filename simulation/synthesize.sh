#!/bin/bash

# Synthesizes VHDL, generates Quartus II project, and injects ADC code. Requires Quartus project to be closed.

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
source "${SCRIPT_DIR}/env.sh"

# Copy generated Logisim files
rm -rf "${PROJECT}"
cp -r "${WORKSPACE}" "${PROJECT}"

# Copy additional Quartus files
cp -r "${SCRIPT_DIR}"/*.qsys "${PROJECT}"
cp "${SCRIPT_DIR}/debug.stp" "${PROJECT}"
cp "${SCRIPT_DIR}/adc_controller.vhd" "${PROJECT}/vhdl/circuit/adc_dummy_behavior.vhd"
cp "${SCRIPT_DIR}/uart_controller.vhd" "${PROJECT}/vhdl/circuit/uart_dummy_behavior.vhd"

# Generate IP variations
"${QSYS_GENERATE}" --synthesis=VHDL "${PROJECT}/adc.qsys"
"${QSYS_GENERATE}" --synthesis=VHDL "${PROJECT}/uart.qsys"

# Patch project assignments script for debugging and ADCs
assignments="    set_global_assignment -name QIP_FILE \"${PROJECT}/adc/synthesis/adc.qip\""
assignments="${assignments}\n    set_global_assignment -name VHDL_FILE \"${PROJECT}/adc/synthesis/adc.vhd\""
assignments="${assignments}\n    set_global_assignment -name QIP_FILE \"${PROJECT}/uart/synthesis/uart.qip\""
assignments="${assignments}\n    set_global_assignment -name VHDL_FILE \"${PROJECT}/uart/synthesis/uart.vhd\""
assignments="${assignments}\n    set_global_assignment -name ENABLE_SIGNALTAP ON"
assignments="${assignments}\n    set_global_assignment -name USE_SIGNALTAP_FILE \"${PROJECT}/debug.stp\""
assignments="${assignments}\n    set_global_assignment -name SIGNALTAP_FILE \"${PROJECT}/debug.stp\""
sed -i "s@# Include all entities and gates@# Include all entities and gates\n${assignments}@" "${PROJECT}/scripts/AlteraDownload.tcl"
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
