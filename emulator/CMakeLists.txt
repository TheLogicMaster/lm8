cmake_minimum_required(VERSION 3.18) # Use current Ubuntu CMake version
project(Emulator)

set(CMAKE_CXX_STANDARD 14)

# Append CMake modules directory for finding libraries
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake/)

# Set SDL2 and GLEW search path for Windows
if (WIN32)
    set(SDL2_PATH ${CMAKE_SOURCE_DIR}/Windows/SDL2/x86_64-w64-mingw32)
    set(GLEW_PATH ${CMAKE_SOURCE_DIR}/Windows/GLEW)
    list(APPEND CMAKE_PREFIX_PATH ${GLEW_PATH} ${SDL2_PATH})
endif()

# Locate packages
find_package(GLEW REQUIRED)
find_package(SDL2 REQUIRED)
find_package(OpenGL REQUIRED)

# Include library headers
include_directories(${SDL2_INCLUDE_DIRS} ${GLEW_INCLUDE_DIRS} ${CMAKE_SOURCE_DIR}/Windows ${OPENGL_INCLUDE_DIR})

# Use GLEW OpenGL loader
add_definitions(-DIMGUI_IMPL_OPENGL_LOADER_GLEW)

# Fix SDL main() linking error on Windows
if (WIN32)
    add_definitions(-DSDL_MAIN_HANDLED)
endif()

# ImGui sources
set(IMGUI_PATH imgui)
file(GLOB IMGUI_SOURCES ${IMGUI_PATH}/*.cpp ${IMGUI_PATH}/backends/imgui_impl_sdl.cpp ${IMGUI_PATH}/backends/imgui_impl_opengl3.cpp)
add_library(imgui STATIC ${IMGUI_SOURCES})
target_include_directories(imgui PUBLIC ${IMGUI_PATH})

# Compile sources into executable
add_executable(Emulator main.cpp Emulator.cpp Emulator.h imgui_memory_editor.h imgui_toggle_button.h ImGuiFileDialog.cpp ImGuiFileDialog.h Disassembler.cpp Disassembler.h StringFormat.h)

# Link Windows specific libraries
if (WIN32)
    set(WIN32_LIBS imm32.lib -static-libgcc -static-libstdc++)
endif()

# Link libraries
target_link_libraries(Emulator imgui ${OPENGL_LIBRARIES} ${GLEW_LIBRARIES} ${SDL2_LIBRARIES} ${WIN32_LIBS})

# Copy DLLs to build directory if not present
if (WIN32)
    add_custom_command(TARGET Emulator POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different ${SDL2_PATH}/bin/SDL2.dll ${CMAKE_BINARY_DIR}/SDL2.dll)
    add_custom_command(TARGET Emulator POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_if_different ${GLEW_PATH}/bin/Release/x64/glew32.dll ${CMAKE_BINARY_DIR}/glew32.dll)
endif()