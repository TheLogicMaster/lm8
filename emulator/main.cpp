#pragma ide diagnostic ignored "cert-err34-c" // Ignore sscanf warnings
#include <iostream>
#include <functional>

#include <SDL.h>
#include "imgui/imgui.h"
#include "imgui/backends/imgui_impl_sdl.h"
#include "imgui/backends/imgui_impl_opengl3.h"
//#include <GLES2/gl2.h>
#include <GL/glew.h>
#include <SDL_opengl.h>
#include <imgui_internal.h>

#include "imgui_memory_editor.h"
#include "imgui_toggle_button.h"

#include "Emulator.h"
#include "ImGuiFileDialog.h"

// Macros from: https://github.com/drhelius/Gearboy/blob/master/platforms/desktop-shared/gui_debug.h
#define BYTE_TO_BINARY_PATTERN "%c%c%c%c%c%c%c%c"
#define BYTE_TO_BINARY_PATTERN_SPACED "%c%c%c%c %c%c%c%c"
#define BYTE_TO_BINARY(byte)  \
  (byte & 0x80 ? '1' : '0'), \
  (byte & 0x40 ? '1' : '0'), \
  (byte & 0x20 ? '1' : '0'), \
  (byte & 0x10 ? '1' : '0'), \
  (byte & 0x08 ? '1' : '0'), \
  (byte & 0x04 ? '1' : '0'), \
  (byte & 0x02 ? '1' : '0'), \
  (byte & 0x01 ? '1' : '0')

SDL_Window* window;
MemoryEditor *ramEditor;
MemoryEditor *romViewer;
bool showDisplay = true;
int displayScale = 3;
bool showProcessor = false;
bool showPrintLog = true;
bool showIO = true;
bool showGPIO = true;
bool controllerPeripheral = false;

bool loadRom(Emulator &emulator, const std::string &path) {
    std::ifstream input(path, std::ios::binary);
    if (!input.good()) {
        std::cout << "Failed to open ROM: '" << path << "'" << std::endl;
        return false;
    }
    input.seekg(0, std::ios::end);
    std::streamsize len = input.tellg();
    auto *rom = new uint8_t[len];
    input.seekg(0, std::ios::beg);
    input.read(reinterpret_cast<char *>(rom), len);
    input.close();
    emulator.load(rom, len);
    delete[] rom;
    return true;
}

int main(int argc, char* argv[]) {
    // Emulation state
    Emulator emulator;
    bool halted = false;
    bool paused = false;
    bool stepBreakpoint = false;
    bool enableBreakpoints;
    int breakpoints[10];
    memset(&breakpoints, -1, 10);

    // Parse program arguments
    if (argc == 1)
        paused = true;
    else if (argc > 2) {
        std::cout << "Usage: './emulator' or './emulator <program>.bin'" << std::endl;
        return -1;
    } else if (!loadRom(emulator, argv[1]))
        return -1;

    // Initialize SDL and OpenGL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER)) {
        std::cout << "Failed to initialize SDL: " << SDL_GetError() << std::endl;
        return -1;
    }
    const char* glsl_version = "#version 130";
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
    SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);
    auto window_flags = (SDL_WindowFlags)(SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
    window = SDL_CreateWindow("Emulator", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1278, 729, window_flags);
    SDL_GLContext gl_context = SDL_GL_CreateContext(window);
    SDL_GL_MakeCurrent(window, gl_context);
    SDL_GL_SetSwapInterval(1); // Enable vsync
    auto glewState = glewInit();
    if (glewState != GLEW_OK) {
        std::cout << "Failed to initialize OpenGL loader: " << glewState << std::endl;
        return -1;
    }

    // Setup ImGui
    IMGUI_CHECKVERSION();
    auto context = ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    io.WantCaptureKeyboard = true;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;
    ImGui::StyleColorsDark(); // Setup Dear ImGui style
    ImGui_ImplSDL2_InitForOpenGL(window, gl_context);
    ImGui_ImplOpenGL3_Init(glsl_version);
    io.Fonts->AddFontDefault(); // Load default font before others

    // Create display texture
    GLuint display_texture;
    glGenTextures(1, &display_texture);

    // Create ImGui windows
    ramEditor = new MemoryEditor();
    ramEditor->Open = false;
    romViewer = new MemoryEditor();
    romViewer->Open = false;
    romViewer->ReadOnly = true;

    // 7-segment display font
    ImFontConfig config;
    config.SizePixels = 40;
    auto font7Segment = io.Fonts->AddFontDefault(&config);

    // Custom persistent data
    ImGuiContext& g = *context;
    ImGuiSettingsHandler ini_handler;
    ini_handler.TypeName = "Emulator";
    ini_handler.TypeHash = ImHashStr("Emulator");
    auto nullCallback{[](ImGuiContext* ctx, ImGuiSettingsHandler* handler) {}};
    ini_handler.ClearAllFn = nullCallback;
    ini_handler.ReadOpenFn = [](ImGuiContext* ctx, ImGuiSettingsHandler* handler, const char* name) -> void* {
        return (void*)1; // Return anything except nullptr or ReadLineFn won't be called
    };
    ini_handler.ReadLineFn = [](ImGuiContext* ctx, ImGuiSettingsHandler* handler, void* entry, const char* line) {
        int value, value2, n;
        if (sscanf(line, "DisplayScale=%d%n", &value, &n) == 1)
            displayScale = value;
        else if (sscanf(line, "ShowDisplay=%d%n", &value, &n) == 1)
            showDisplay = value;
        else if (sscanf(line, "ShowProcessor=%d%n", &value, &n) == 1)
            showProcessor = value;
        else if (sscanf(line, "ShowRAM=%d%n", &value, &n) == 1)
            ramEditor->Open = value;
        else if (sscanf(line, "ShowROM=%d%n", &value, &n) == 1)
            romViewer->Open = value;
        else if (sscanf(line, "ShowPrintLog=%d%n", &value, &n) == 1)
            showPrintLog = value;
        else if (sscanf(line, "ShowIO=%d%n", &value, &n) == 1)
            showIO = value;
        else if (sscanf(line, "ShowGPIO=%d%n", &value, &n) == 1)
            showGPIO = value;
        else if (sscanf(line, "WindowSize=%d,%d%n", &value, &value2, &n) == 2)
            SDL_SetWindowSize(window, value, value2);
        else if (sscanf(line, "Peripherals=%d%n", &value, &n) == 1)
            controllerPeripheral = value;
    };
    ini_handler.ApplyAllFn = nullCallback;
    ini_handler.WriteAllFn = [](ImGuiContext* ctx, ImGuiSettingsHandler* handler, ImGuiTextBuffer* buf) {
        buf->append("[Emulator][Data]\n");
        buf->appendf("DisplayScale=%d\n", displayScale);
        buf->appendf("ShowDisplay=%d\n", showDisplay);
        buf->appendf("ShowProcessor=%d\n", showProcessor);
        buf->appendf("ShowRAM=%d\n", ramEditor->Open);
        buf->appendf("ShowROM=%d\n", romViewer->Open);
        buf->appendf("ShowPrintLog=%d\n", showPrintLog);
        buf->appendf("ShowIO=%d\n", showIO);
        buf->appendf("ShowGPIO=%d\n", showGPIO);
        int w, h;
        SDL_GetWindowSize(window, &w, &h);
        buf->appendf("WindowSize=%d,%d\n", w, h);
        buf->appendf("Peripherals=%d\n", controllerPeripheral);
    };
    g.SettingsHandlers.push_back(ini_handler);

    const auto windowColor = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
    const auto flagColor = ImVec4(0.0f,1.0f,1.0f,1.0f);
    const auto registerColor = ImVec4(1.0f,1.0f,0.0f,1.0f);

    auto exited = false;
    while (!exited) {
        // Poll events
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            ImGui_ImplSDL2_ProcessEvent(&event);
            if (event.type == SDL_QUIT or (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(window)))
                exited = true;
        }

        // Start frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplSDL2_NewFrame(window);
        ImGui::NewFrame();

        // Check for shortcuts
        if (ImGui::IsKeyDown(SDL_SCANCODE_LCTRL));

        // Run emulator for about a frame
        if ((!halted and !paused) or stepBreakpoint) {
            try {
                for (int i = 0; i < 100; i++) { // Todo: Fix to 1MHz or something rather than ~6KHz
                    if (controllerPeripheral) {
                        emulator.getGPIO(0) = ImGui::IsKeyDown(SDL_SCANCODE_W) or ImGui::IsKeyDown(SDL_SCANCODE_UP);
                        emulator.getGPIO(1) = ImGui::IsKeyDown(SDL_SCANCODE_S) or ImGui::IsKeyDown(SDL_SCANCODE_DOWN);
                        emulator.getGPIO(2) = ImGui::IsKeyDown(SDL_SCANCODE_A) or ImGui::IsKeyDown(SDL_SCANCODE_LEFT);
                        emulator.getGPIO(3) = ImGui::IsKeyDown(SDL_SCANCODE_D) or ImGui::IsKeyDown(SDL_SCANCODE_RIGHT);
                    }

                    emulator.run();

                    bool broken = false;
                    if (enableBreakpoints)
                        for (int j = 0; j < 10; j++)
                            if (emulator.getPC() == breakpoints[i]) {
                                broken = true;
                                break;
                            }
                    if (broken) {
                        paused = true;
                        break;
                    }
                    if (stepBreakpoint)
                        break;
                }
            } catch (HaltException &exception) {
                halted = true;
            }
            stepBreakpoint = false;
        }

        // Update display texture from buffer
        glBindTexture(GL_TEXTURE_2D, display_texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, DISPLAY_WIDTH, DISPLAY_HEIGHT, 0, GL_RGB, GL_UNSIGNED_BYTE, emulator.getDisplayBuffer());
        glBindTexture(GL_TEXTURE_2D, 0);

        // Main menu bar
        if (ImGui::BeginMainMenuBar()) {
            if (ImGui::BeginMenu("File")) {
                if (ImGui::MenuItem("Open ROM"))
                    ImGuiFileDialog::Instance()->OpenDialog("ChooseROM", "Choose ROM", ".bin", ".");
                if (ImGui::MenuItem("Exit"))
                    exited = true;
                ImGui::EndMenu();
            }
            if (ImGui::BeginMenu("Emulation")) {
                if (ImGui::MenuItem("Reset")) {
                    halted = false;
                    emulator.reset();
                }
                if (ImGui::MenuItem("Pause", nullptr, paused))
                    paused ^= 1;
                if (ImGui::MenuItem("Step CPU"))
                    stepBreakpoint = true;
                ImGui::EndMenu();
            }
            if (ImGui::BeginMenu("Peripherals")) {
                if (ImGui::MenuItem("Controller", nullptr, controllerPeripheral))
                    controllerPeripheral ^= 1;
                ImGui::EndMenu();
            }
            if (ImGui::BeginMenu("View")) {
                if (ImGui::MenuItem("Show Display", nullptr, showDisplay))
                    showDisplay ^= 1;
                if (ImGui::MenuItem("Show Print Log", nullptr, showPrintLog))
                    showPrintLog ^= 1;
                if (ImGui::MenuItem("Show I/O Panel", nullptr, showIO))
                    showIO ^= 1;
                if (ImGui::MenuItem("Show GPIO", nullptr, showGPIO))
                    showGPIO ^= 1;
                ImGui::Separator();
                if (ImGui::MenuItem("Show ROM Viewer", nullptr, romViewer->Open))
                    romViewer->Open ^= 1;
                if (ImGui::MenuItem("Show RAM Editor", nullptr, ramEditor->Open))
                    ramEditor->Open ^= 1;
                if (ImGui::MenuItem("Show Processor", nullptr, showProcessor))
                    showProcessor ^= 1;
                ImGui::EndMenu();
            }
            ImGui::EndMainMenuBar();
        }

        // ROM File Browser
        if (ImGuiFileDialog::Instance()->Display("ChooseROM")) {
            if (ImGuiFileDialog::Instance()->IsOk()) {
                halted = false;
                paused = false;
                memset(&breakpoints, -1, 10);
                enableBreakpoints = false;
                loadRom(emulator, ImGuiFileDialog::Instance()->GetCurrentPath() + "/" + ImGuiFileDialog::Instance()->GetCurrentFileName());
                emulator.reset();
            }
            ImGuiFileDialog::Instance()->Close();
        }

        // Display window
        if (showDisplay) {
            ImGui::SetNextWindowPos(ImVec2(5, 25), ImGuiCond_FirstUseEver);
            ImGui::Begin("Display", &showDisplay, ImGuiWindowFlags_AlwaysAutoResize);

            // Right click context menu
            if (ImGui::IsWindowHovered(ImGuiHoveredFlags_RootAndChildWindows) && ImGui::IsMouseReleased(ImGuiMouseButton_Right))
                ImGui::OpenPopup("context");

            // Options menu
            if (ImGui::BeginPopup("context")) {
                ImGui::SetNextItemWidth(100);
                if (ImGui::DragInt("##scale", &displayScale, 0.2f, 1, 6, "Scale: %dx")) {
                    if (displayScale < 1)
                        displayScale = 1;
                }
                ImGui::EndPopup();
            }

            ImGui::Image((void *)(intptr_t)display_texture, ImVec2(DISPLAY_WIDTH * displayScale, DISPLAY_HEIGHT * displayScale));
            //ImGui::Text("Application average %.3f ms/frame (%.1f FPS)", 1000.0f / ImGui::GetIO().Framerate, ImGui::GetIO().Framerate);

            // Options button
            if (ImGui::Button("Options"))
                ImGui::OpenPopup("context");

            ImGui::End();
        }

        // Print log
        if (showPrintLog) {
            ImGui::SetNextWindowSize(ImVec2(496, 170), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowPos(ImVec2(5, 472), ImGuiCond_FirstUseEver);
            ImGui::Begin("Print Log", &showPrintLog);
            ImGui::BeginChild("PrintLog", ImVec2(ImGui::GetWindowWidth(), ImGui::GetWindowHeight() - 60));
            ImGui::TextUnformatted(emulator.getPrintBuffer().data());
            ImGui::EndChild();
            if (ImGui::Button("Clear"))
                emulator.getPrintBuffer().clear();
            ImGui::End();
        }

        // GPIO Panel
        if (showGPIO) {
            ImGui::SetNextWindowSize(ImVec2(1268, 75), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowPos(ImVec2(5, 648), ImGuiCond_FirstUseEver);
            ImGui::Begin("GPIO Panel", &showGPIO, ImGuiWindowFlags_NoResize);
            if (ImGui::BeginTable("GPIO Table", 3)) {
                ImGui::TableSetupColumn("GPIO", ImGuiTableColumnFlags_WidthFixed, 725);
                ImGui::TableSetupColumn("Arduino Header I/O", ImGuiTableColumnFlags_WidthFixed, 325);
                ImGui::TableSetupColumn("ADCs", ImGuiTableColumnFlags_WidthFixed, 180);
                ImGui::TableHeadersRow();
                char buf[3];

                // GPIO
                ImGui::TableNextColumn();
                for (int i = 0; i < 36; i++) {
                    ImGui::PushID(i);
                    sprintf(buf, "%d", emulator.getGPIO(i));
                    ImGui::SetNextItemWidth(12);
                    if (ImGui::InputText("##", buf, 2, ImGuiInputTextFlags_NoHorizontalScroll
                        | ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_AlwaysOverwrite | ImGuiInputTextFlags_AutoSelectAll))
                        emulator.getGPIO(i) = buf[0] != '0';
                    if (ImGui::IsItemHovered())
                        ImGui::SetTooltip("GPIO %d", i);
                    ImGui::SameLine();
                    ImGui::PopID();
                }

                // Arduino I/O
                ImGui::TableNextColumn();
                for (int i = 0; i < 16; i++) {
                    ImGui::PushID(i + 36);
                    sprintf(buf, "%d", emulator.getArduinoIO(i));
                    ImGui::SetNextItemWidth(12);
                    if (ImGui::InputText("##", buf, 2, ImGuiInputTextFlags_NoHorizontalScroll
                                                       | ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_AlwaysOverwrite | ImGuiInputTextFlags_AutoSelectAll))
                        emulator.getArduinoIO(i) = buf[0] != '0';
                    if (ImGui::IsItemHovered())
                        ImGui::SetTooltip("Arduino I/O %d", i);
                    ImGui::SameLine();
                    ImGui::PopID();
                }

                // ADCs
                ImGui::TableNextColumn();
                for (int i = 0; i < 6; i++) {
                    ImGui::PushID(i + 52);
                    sprintf(buf, "%x", emulator.getADC(i));
                    ImGui::SetNextItemWidth(24);
                    if (ImGui::InputText("##", buf, 3, ImGuiInputTextFlags_NoHorizontalScroll
                                                       | ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_AlwaysOverwrite | ImGuiInputTextFlags_AutoSelectAll))
                        emulator.getADC(i) = strtol(buf, nullptr, 16);
                    if (ImGui::IsItemHovered())
                        ImGui::SetTooltip("ADC %d", i);
                    ImGui::SameLine();
                    ImGui::PopID();
                }
                ImGui::EndTable();
            }
            ImGui::End();
        }

        // I/O Panel
        if (showIO) {
            ImGui::SetNextWindowSize(ImVec2(552, 170));
            ImGui::SetNextWindowPos(ImVec2(506, 472), ImGuiCond_FirstUseEver);
            ImGui::Begin("I/O Panel", &showIO, ImGuiWindowFlags_NoResize);
            ImGui::BeginColumns("I/O Columns", 10, ImGuiOldColumnFlags_NoResize);

            // Switches
            for (int i = 0; i < 10; i++) {
                ImGui::BeginGroup();
                ImGui::Dummy(ImVec2(1, 0));
                ImGui::SameLine();
                ToggleButton(("SW" + std::to_string(i)).c_str(), &emulator.getSwitch(i));
                ImGui::EndGroup();
                ImGui::NextColumn();
            }
            for (int i = 0; i < 10; i++) {
                ImGui::Text("  SW%d", i);
                ImGui::NextColumn();
            }
            ImGui::Separator();

            // LEDs
            for (int i = 0; i < 10; i++) {
                ImVec2 p = ImGui::GetCursorScreenPos();
                ImDrawList* draw_list = ImGui::GetWindowDrawList();
                draw_list->AddCircleFilled(ImVec2(p.x + 20, p.y + 15), 8, emulator.getLight(i) ?
                    IM_COL32(255, 50, 50, 255) : IM_COL32(50, 50, 50, 255));
                ImGui::Dummy(ImVec2(20, 22));
                ImGui::NextColumn();
            }
            for (int i = 0; i < 10; i++) {
                ImGui::Text(" LED%d", i);
                ImGui::NextColumn();
            }
            ImGui::Separator();

            // Buttons
            for (int i = 0; i < 2; i++) {
                ImGui::Button(("BTN" + std::to_string(i)).c_str(), ImVec2(42, 42));
                emulator.getButton(i) = ImGui::IsItemActive();
                ImGui::NextColumn();
            }

            // Seven segment displays
            for (int i = 0; i < 6; i++) {
                ImGui::PushFont(font7Segment);
                ImGui::BeginGroup();
                ImGui::Dummy(ImVec2(2, 0));
                ImGui::SameLine();
                ImGui::Text("%d", emulator.getSevenSegmentDisplay(i) & 0xF);
                ImGui::EndGroup();
                ImGui::PopFont();
                ImGui::NextColumn();
            }

            ImGui::End();
        }

        // Processor window --- Based on: https://github.com/drhelius/Gearboy
        if (showProcessor) {
            ImGui::SetNextWindowPos(ImVec2(1063, 25), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowSize(ImVec2(159, 218), ImGuiCond_FirstUseEver);
            ImGui::Begin("Processor", &showProcessor, ImGuiWindowFlags_NoResize);

            // CPU Flags
            ImGui::TextColored(flagColor, "   Z");
            ImGui::SameLine();
            ImGui::Text("= %d", (bool)(emulator.getStatus() & FLAG_Z));
            ImGui::SameLine();
            ImGui::TextColored(flagColor, "  C");
            ImGui::SameLine();
            ImGui::Text("= %d", (bool)(emulator.getStatus() & FLAG_C));
            ImGui::TextColored(flagColor, "   N");
            ImGui::SameLine();
            ImGui::Text("= %d", (bool)(emulator.getStatus() & FLAG_N));
            ImGui::SameLine();
            ImGui::TextColored(flagColor, "  V");
            ImGui::SameLine();
            ImGui::Text("= %d", (bool)(emulator.getStatus() & FLAG_V));

            // CPU Registers
            ImGui::Columns(2, "registers");
            ImGui::Separator();
            ImGui::TextColored(registerColor, " A");
            ImGui::SameLine();
            ImGui::Text("= $%02X", emulator.getRegA());
            ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator.getRegA()));
            ImGui::NextColumn();
            ImGui::TextColored(registerColor, " B");
            ImGui::SameLine();
            ImGui::Text("= $%02X", emulator.getRegB());
            ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator.getRegB()));
            ImGui::NextColumn();
            ImGui::Separator();
            ImGui::TextColored(registerColor, " H");
            ImGui::SameLine();
            ImGui::Text("= $%02X", emulator.getRegH());
            ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator.getRegH()));
            ImGui::NextColumn();
            ImGui::TextColored(registerColor, " L");
            ImGui::SameLine();
            ImGui::Text("= $%02X", emulator.getRegL());
            ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator.getRegL()));

            // PC
            ImGui::NextColumn();
            ImGui::Columns(1);
            ImGui::Separator();
            ImGui::TextColored(registerColor, "    PC");
            ImGui::SameLine();
            ImGui::Text("= $%04X", emulator.getPC());
            ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED " " BYTE_TO_BINARY_PATTERN_SPACED,
                        BYTE_TO_BINARY((emulator.getPC() & 0xFF00) >> 8),
                        BYTE_TO_BINARY(emulator.getPC() & 0xFF));

            // SP
            ImGui::NextColumn();
            ImGui::Columns(2);
            ImGui::Separator();
            ImGui::TextColored(registerColor, "SP");
            ImGui::SameLine();
            ImGui::Text("= $%02X", emulator.getSP());
            ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator.getSP()));

            // Halted or not
            ImGui::NextColumn();
            ImGui::Separator();
            ImGui::TextColored(flagColor, "HALT");
            ImGui::SameLine();
            ImGui::Text("= %d", halted);

            ImGui::End();
        }

        // Memory Editors
        if (romViewer->Open) {
            ImGui::SetNextWindowSize(ImVec2(0, 218), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowPos(ImVec2(506, 25), ImGuiCond_FirstUseEver);
            romViewer->DrawWindow("ROM Viewer", emulator.getROM(), 0x8000);
        }
        if (ramEditor->Open) {
            ImGui::SetNextWindowSize(ImVec2(0, 218), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowPos(ImVec2(506, 248), ImGuiCond_FirstUseEver);
            ramEditor->DrawWindow("RAM Editor", emulator.getMemory(), 0x8000);
        }

        // Render
        ImGui::Render();
        glViewport(0, 0, (int)io.DisplaySize.x, (int)io.DisplaySize.y);
        glClearColor(windowColor.x * windowColor.w, windowColor.y * windowColor.w, windowColor.z * windowColor.w, windowColor.w);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        SDL_GL_SwapWindow(window);
    }

    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();

    // Must be deleted after ImGui shutdown for INI saving
    delete ramEditor;
    delete romViewer;

    return 0;
}