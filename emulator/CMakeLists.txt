cmake_minimum_required(VERSION 3.19)
project(emulator)

set(CMAKE_CXX_STANDARD 14)

add_executable(emulator main.cpp Emulator.cpp Emulator.h imgui_memory_editor.h imgui_toggle_button.h ImGuiFileDialog.cpp ImGuiFileDialog.h)

set(IMGUI_PATH  "./imgui")
file(GLOB IMGUI_SOURCES ${IMGUI_PATH}/*.cpp ${IMGUI_PATH}/backends/imgui_impl_sdl.cpp ${IMGUI_PATH}/backends/imgui_impl_opengl3.cpp)
add_library("imgui" STATIC ${IMGUI_SOURCES})
add_definitions(-DIMGUI_IMPL_OPENGL_ES2)
target_include_directories("imgui" PUBLIC ${IMGUI_PATH})

find_package(SDL2 REQUIRED)
include_directories(emulator ${SDL2_INCLUDE_DIRS})

find_package(OpenGL REQUIRED)
target_link_libraries(emulator SDL2::SDL2 SDL2::SDL2main ${OPENGL_LIBRARIES} imgui)
