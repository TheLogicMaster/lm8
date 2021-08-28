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
cp "${SCRIPT_DIR}/rom.vhd" "${PROJECT}/rom.vhd"
cp "${SCRIPT_DIR}/adc_controller.vhd" "${PROJECT}/vhdl/circuit/adc_dummy_behavior.vhd"
cp "${SCRIPT_DIR}/uart_controller.vhd" "${PROJECT}/vhdl/circuit/uart_dummy_behavior.vhd"

# Generate IP variations
QSYS_GENERATE="${QUARTUS_DIR}"/../sopc_builder/bin/qsys-generate"${EXT}"
"${QSYS_GENERATE}" --synthesis=VHDL "${PROJECT_EXT}/adc.qsys"
"${QSYS_GENERATE}" --synthesis=VHDL "${PROJECT_EXT}/uart.qsys"

# Patch project assignments script for debugging and ADCs
assignments="    set_global_assignment -name QIP_FILE \"${PROJECT_EXT}/adc/synthesis/adc.qip\""
assignments="${assignments}\n    set_global_assignment -name VHDL_FILE \"${PROJECT_EXT}/adc/synthesis/adc.vhd\""
assignments="${assignments}\n    set_global_assignment -name QIP_FILE \"${PROJECT_EXT}/uart/synthesis/uart.qip\""
assignments="${assignments}\n    set_global_assignment -name VHDL_FILE \"${PROJECT_EXT}/uart/synthesis/uart.vhd\""
assignments="${assignments}\n    set_global_assignment -name VHDL_FILE \"${PROJECT_EXT}/rom.vhd\""
assignments="${assignments}\n    set_global_assignment -name ENABLE_SIGNALTAP ON"
assignments="${assignments}\n    set_global_assignment -name USE_SIGNALTAP_FILE \"${PROJECT_EXT}/debug.stp\""
assignments="${assignments}\n    set_global_assignment -name SIGNALTAP_FILE \"${PROJECT_EXT}/debug.stp\""
assignments="${assignments}\n    set_global_assignment -name INTERNAL_FLASH_UPDATE_MODE \"SINGLE IMAGE WITH ERAM\""
sed -i "s@# Include all entities and gates@# Include all entities and gates\n${assignments}@" "${PROJECT}/scripts/AlteraDownload.tcl"
sed -i "s@${WORKSPACE_EXT}@${PROJECT_EXT}@" "${PROJECT}/scripts/AlteraDownload.tcl"

# Patch main_behavior to use Altera ROM component
perl -0777 -i -pe "s/: ROMCONTENTS_Program[\w\W]*?PORT MAP \(/: ieee.rom\nPORT MAP(Clock=>LOGISIM_CLOCK_TREE_0(4),\n/g" "${PROJECT}/vhdl/circuit/main_behavior.vhd"

# Patch main_behavior to fix ADC clock
sed -ri "s/adc_clk\ *=>\ *\w+/adc_clk=>LOGISIM_CLOCK_TREE_0(4)/" "${PROJECT}/vhdl/circuit/main_behavior.vhd"

(
    cd "${PROJECT}"

    # Setup project with board assignments
    "${QUARTUS_DIR}/quartus_sh${EXT}" -t ./scripts/AlteraDownload.tcl

    # Generate debugging info
    "${QUARTUS_DIR}/quartus_stp${EXT}" LogisimToplevelShell --stp_file ./debug.stp
)
