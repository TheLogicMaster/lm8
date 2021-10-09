#pragma ide diagnostic ignored "cert-err34-c" // Ignore sscanf warnings
#include <iostream>
#include <functional>
#include <set>

#include <SDL.h>
#include "imgui/imgui.h"
#include "imgui/backends/imgui_impl_sdl.h"
#include "imgui/backends/imgui_impl_opengl3.h"
#include <GL/glew.h>
#include <imgui_internal.h>
#ifdef __EMSCRIPTEN__
#include <emscripten.h>
#include <emscripten/fetch.h>
#else
#include "ImGuiFileDialog.h"
#endif

#include "imgui_memory_editor.h"
#include "imgui_toggle_button.h"
#include "Disassembler.h"
#include "Emulator.h"

// Macros from: https://github.com/drhelius/Gearboy/blob/master/platforms/desktop-shared/gui_debug.h
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

static SDL_Window *window;
static SDL_GLContext glContext;
static ImGuiIO *imguiIO;
static GLuint displayTexture;
static bool exited = false;

static bool showDisplay = true;
static int displayScale = 3;
static bool showProcessor = false;
static bool showPrintLog = true;
static bool showIO = true;
static bool showGPIO = true;
static bool showDisassembly = false;
static bool showBreakpoints = false;
static bool showTimers = false;
static bool showPWM = false;
static bool controllerPeripheral = false;
static int processorSpeeds[8]{0, 1, 2, 3, 4, 5, 9, 14};
static int processorSpeed = 0;

static Emulator *emulator;
static Disassembler* disassembler;
static MemoryEditor *ramEditor;
static MemoryEditor *romViewer;
static uint8_t *rom;
static bool halted = false;
static bool paused = false;
static bool disassemblerJumpToPC = true;
static bool stepBreakpoint = false;
static bool enableBreakpoints = false;
static std::set<uint16_t> breakpoints{};
static char breakpointText[5]{};
char uartText[255]{};

// Todo: Give colors better names
static ImFont *font7Segment;
static ImVec4 *windowColor;
static ImVec4 *flagColor;
static ImVec4 *registerColor;
static ImVec4 *breakpointColor;
static ImVec4 *outputColor;
static ImVec4 *disabledColor;

static void setupPersistenceHandler(ImGuiContext *context) {
    // Todo: Load and store 'show' variables and peripherals dynamically
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
        if (sscanf(line, "ProcessorSpeed=%d%n", &value, &n) == 1)
            processorSpeed = value;
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
        else if (sscanf(line, "ShowDisassembly=%d%n", &value, &n) == 1)
            showDisassembly = value;
        else if (sscanf(line, "ShowBreakpoints=%d%n", &value, &n) == 1)
            showBreakpoints = value;
        else if (sscanf(line, "ShowTimers=%d%n", &value, &n) == 1)
            showTimers= value;
        else if (sscanf(line, "ShowPWM=%d%n", &value, &n) == 1)
            showPWM = value;
        else if (sscanf(line, "WindowSize=%d,%d%n", &value, &value2, &n) == 2)
            SDL_SetWindowSize(window, value, value2);
        else if (sscanf(line, "Controller=%d%n", &value, &n) == 1)
            controllerPeripheral = value;
    };
    ini_handler.ApplyAllFn = nullCallback;
    ini_handler.WriteAllFn = [](ImGuiContext* ctx, ImGuiSettingsHandler* handler, ImGuiTextBuffer* buf) {
        buf->append("[Emulator][Data]\n");
        buf->appendf("DisplayScale=%d\n", displayScale);
        buf->appendf("ProcessorSpeed=%d\n", processorSpeed);
        buf->appendf("ShowDisplay=%d\n", showDisplay);
        buf->appendf("ShowProcessor=%d\n", showProcessor);
        buf->appendf("ShowRAM=%d\n", ramEditor->Open);
        buf->appendf("ShowROM=%d\n", romViewer->Open);
        buf->appendf("ShowPrintLog=%d\n", showPrintLog);
        buf->appendf("ShowIO=%d\n", showIO);
        buf->appendf("ShowGPIO=%d\n", showGPIO);
        buf->appendf("ShowDisassembly=%d\n", showDisassembly);
        buf->appendf("ShowBreakpoints=%d\n", showBreakpoints);
        buf->appendf("ShowTimers=%d\n", showTimers);
        buf->appendf("ShowPWM=%d\n", showPWM);
        int w, h;
        SDL_GetWindowSize(window, &w, &h);
        buf->appendf("WindowSize=%d,%d\n", w, h);
        buf->appendf("Controller=%d\n", controllerPeripheral);
    };
    g.SettingsHandlers.push_back(ini_handler);
}

static bool loadRom(const std::string &path) {
#ifndef __EMSCRIPTEN__
    std::ifstream input(path, std::ios::binary);
    if (!input.good()) {
        std::cout << "Failed to open ROM: '" << path << "'" << std::endl;
        return false;
    }
    input.seekg(0, std::ios::end);
    long len = input.tellg();
    rom = new uint8_t[len];
    input.seekg(0, std::ios::beg);
    input.read(reinterpret_cast<char *>(rom), len);
    input.close();
    emulator->load(rom, len);
    delete disassembler;
    disassembler = new Disassembler(emulator->getMemory());
#else
    emscripten_fetch_attr_t attr;
    emscripten_fetch_attr_init(&attr);
    strcpy(attr.requestMethod, "GET");
    attr.attributes = EMSCRIPTEN_FETCH_LOAD_TO_MEMORY;
    attr.onsuccess = [](auto fetch) {
        auto len = fetch->numBytes;
        memory = new uint8_t[len];
        memcpy(memory, fetch->data, len);
        emscripten_fetch_close(fetch);
        emulator->load(memory, len);
        delete disassembler;
        disassembler = new Disassembler(memory, len);
        halted = false;
        breakpoints.clear();
        enableBreakpoints = false;
        emulator->reset();
    };
    emscripten_fetch(&attr, path.c_str());
#endif
    return true;
}

static void displayMainMenuBar() {
    if (ImGui::BeginMainMenuBar()) {
        if (ImGui::BeginMenu("File")) {
#ifndef __EMSCRIPTEN__
            if (ImGui::MenuItem("Open ROM", "ctrl+O"))
                ImGuiFileDialog::Instance()->OpenDialog("ChooseROM", "Choose ROM", ".bin", ".");
            if (ImGui::MenuItem("Exit"))
                exited = true;
#else
            static const char *roms[] {"Hello World", "Hello World 2", "Snake", "IO Panel"};
            for (auto &memory: roms)
                if (ImGui::MenuItem(memory))
                    loadRom(memory + std::string(".bin"));
#endif
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("Emulation")) {
            if (ImGui::MenuItem("Reset", "ctrl+R")) {
                halted = false;
                emulator->reset();
            }
            ImGui::MenuItem("Pause", "ctrl+P", &paused);
            ImGui::MenuItem("Enable Breakpoints", "ctrl+B", &enableBreakpoints);
            if (ImGui::MenuItem("Step CPU", "ctrl+Z") and !halted and paused)
                stepBreakpoint = true;
            ImGui::Combo("Processor Speed", &processorSpeed, " 1 MHz\0 512 KHz\0 256 KHz\0 128 KHz\0 64 KHz\0 32 KHz\0 2 Khz\0 64 Hz\0", 8);
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("Peripherals")) {
            ImGui::MenuItem("Controller", nullptr, &controllerPeripheral);
            ImGui::EndMenu();
        }
        if (ImGui::BeginMenu("View")) {
            ImGui::MenuItem("Show Display", nullptr, &showDisplay);
            ImGui::MenuItem("Show Print Log", nullptr, &showPrintLog);
            ImGui::MenuItem("Show I/O Panel", nullptr, &showIO);
            ImGui::MenuItem("Show GPIO", nullptr, &showGPIO);
            ImGui::Separator();
            ImGui::MenuItem("Show ROM Viewer", nullptr, &romViewer->Open);
            ImGui::MenuItem("Show RAM Editor", nullptr, &ramEditor->Open);
            ImGui::MenuItem("Show Processor", nullptr, &showProcessor);
            ImGui::MenuItem("Show Disassembly", nullptr, &showDisassembly);
            ImGui::MenuItem("Show Breakpoints", nullptr, &showBreakpoints);
            ImGui::MenuItem("Show Timers", nullptr, &showTimers);
            ImGui::MenuItem("Show PWM", nullptr, &showPWM);
            ImGui::EndMenu();
        }
        ImGui::EndMainMenuBar();
    }
}

static void displayRomBrowser() {
#ifndef __EMSCRIPTEN__
    if (ImGuiFileDialog::Instance()->Display("ChooseROM", ImGuiWindowFlags_NoCollapse, ImVec2(400, 250))) {
        if (ImGuiFileDialog::Instance()->IsOk()) {
            halted = false;
            breakpoints.clear();
            enableBreakpoints = false;
            loadRom(ImGuiFileDialog::Instance()->GetCurrentPath() + "/" +
                    ImGuiFileDialog::Instance()->GetCurrentFileName());
            emulator->reset();
        }
        ImGuiFileDialog::Instance()->Close();
    }
#endif
}

static void displayScreen() {
    if (!showDisplay)
        return;

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

    ImGui::Image((ImTextureID)(intptr_t)displayTexture, ImVec2(DISPLAY_WIDTH * displayScale, DISPLAY_HEIGHT * displayScale));

    // Options button
    if (ImGui::Button("Options"))
        ImGui::OpenPopup("context");

    ImGui::End();
}

static void displayMemoryViewers() {
    if (romViewer->Open) {
        ImGui::SetNextWindowSize(ImVec2(0, 218), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowPos(ImVec2(506, 25), ImGuiCond_FirstUseEver);
        romViewer->DrawWindow("ROM Viewer", emulator->getROM(), 0x8000);
    }
    if (ramEditor->Open) {
        ImGui::SetNextWindowSize(ImVec2(0, 218), ImGuiCond_FirstUseEver);
        ImGui::SetNextWindowPos(ImVec2(506, 248), ImGuiCond_FirstUseEver);
        ramEditor->DrawWindow("RAM Editor", emulator->getRAM(), 0x8000);
    }
}

static void displayPrintLog() {
    if (!showPrintLog)
        return;

    ImGui::SetNextWindowSize(ImVec2(496, 170), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(5, 472), ImGuiCond_FirstUseEver);
    ImGui::Begin("Print Log", &showPrintLog);
    ImGui::BeginChild("PrintLog", ImVec2(ImGui::GetWindowWidth() - 10, ImGui::GetWindowHeight() - 60), true);
    ImGui::TextUnformatted(emulator->getPrintBuffer().data());
    ImGui::EndChild();
    if (ImGui::Button("Clear"))
        emulator->getPrintBuffer().clear();
    ImGui::SameLine();

    ImGui::SetNextItemWidth(ImGui::GetWindowWidth() - 120);
    ImGui::InputText("", uartText, 255);
    ImGui::SameLine();
    if (ImGui::Button("Send")) {
        emulator->uartReceive(uartText, strlen(uartText));
        uartText[0] = 0;
    }
    ImGui::End();
}

static void displayPanelIO() {
    if (!showIO)
        return;

    ImGui::SetNextWindowSize(ImVec2(552, 170));
    ImGui::SetNextWindowPos(ImVec2(506, 472), ImGuiCond_FirstUseEver);
    ImGui::Begin("I/O Panel", &showIO, ImGuiWindowFlags_NoResize);
    ImGui::BeginColumns("I/O Columns", 10, ImGuiOldColumnFlags_NoResize);

    // Switches
    for (int i = 0; i < 10; i++) {
        ImGui::BeginGroup();
        ImGui::Dummy(ImVec2(1, 0));
        ImGui::SameLine();
        ToggleButton(("SW" + std::to_string(i)).c_str(), &emulator->getSwitch(i));
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
        draw_list->AddCircleFilled(ImVec2(p.x + 20, p.y + 15), 8, emulator->getLight(i) ?
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
        emulator->getButton(i) = ImGui::IsItemActive();
        ImGui::NextColumn();
    }

    // Seven segment displays
    for (int i = 5; i >= 0; i--) {
        ImGui::PushFont(font7Segment);
        ImGui::BeginGroup();
        ImGui::Dummy(ImVec2(2, 0));
        ImGui::SameLine();
        ImGui::Text("%x", emulator->getSevenSegmentDisplay(i) & 0xF);
        ImGui::EndGroup();
        ImGui::PopFont();
        ImGui::NextColumn();
    }

    ImGui::End();
}

static void displayPanelGPIO() {
    if (!showGPIO)
        return;

    ImGui::SetNextWindowSize(ImVec2(1268, 75), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(5, 648), ImGuiCond_FirstUseEver);
    ImGui::Begin("GPIO Panel", &showGPIO, ImGuiWindowFlags_NoResize);
    if (ImGui::BeginTable("GPIO Table", 3)) {
        ImGui::TableSetupColumn("GPIO", ImGuiTableColumnFlags_WidthFixed, 725);
        ImGui::TableSetupColumn("Arduino Header I/O", ImGuiTableColumnFlags_WidthFixed, 325);
        ImGui::TableSetupColumn("ADCs", ImGuiTableColumnFlags_WidthFixed, 180);
        ImGui::TableHeadersRow();
        char buf[3];

        ImGuiTextFlags ioFlags = ImGuiInputTextFlags_NoHorizontalScroll | ImGuiInputTextFlags_CharsHexadecimal
                | ImGuiInputTextFlags_AlwaysOverwrite | ImGuiInputTextFlags_AutoSelectAll;

        // GPIO
        ImGui::TableNextColumn();
        for (int i = 0; i < 36; i++) {
            ImGui::PushID(i);
            sprintf(buf, "%d", emulator->getGPIO(i));
            ImGui::SetNextItemWidth(12);
            bool output = emulator->getGpioOutput(i);
            if (output)
                ImGui::PushStyleColor(ImGuiCol_Text, emulator->getGPIO(i) ? *outputColor : *breakpointColor);
            if (ImGui::InputText("##", buf, 2, ioFlags | (output ? ImGuiInputTextFlags_ReadOnly : 0)))
                emulator->getGPIO(i) = buf[0] != '0';
            if (output)
                ImGui::PopStyleColor();
            if (ImGui::IsItemHovered())
                ImGui::SetTooltip("GPIO %d", i);
            ImGui::SameLine();
            ImGui::PopID();
        }

        // Arduino I/O
        ImGui::TableNextColumn();
        for (int i = 0; i < 16; i++) {
            ImGui::PushID(i + 36);
            sprintf(buf, "%d", emulator->getArduinoIO(i));
            ImGui::SetNextItemWidth(12);
            bool output = emulator->getArduinoOutput(i);
            if (output)
                ImGui::PushStyleColor(ImGuiCol_Text, emulator->getArduinoIO(i) ? *outputColor : *breakpointColor);
            if (ImGui::InputText("##", buf, 2, ioFlags | (output ? ImGuiInputTextFlags_ReadOnly : 0)))
                emulator->getArduinoIO(i) = buf[0] != '0';
            if (output)
                ImGui::PopStyleColor();
            if (ImGui::IsItemHovered())
                ImGui::SetTooltip("Arduino I/O %d", i);
            ImGui::SameLine();
            ImGui::PopID();
        }

        // ADCs
        ImGui::TableNextColumn();
        for (int i = 0; i < 6; i++) {
            ImGui::PushID(i + 52);
            sprintf(buf, "%x", emulator->getADC(i));
            ImGui::SetNextItemWidth(24);
            if (ImGui::InputText("##", buf, 3, ImGuiInputTextFlags_NoHorizontalScroll
                                               | ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_AlwaysOverwrite | ImGuiInputTextFlags_AutoSelectAll))
                emulator->getADC(i) = strtol(buf, nullptr, 16);
            if (ImGui::IsItemHovered())
                ImGui::SetTooltip("ADC %d", i);
            ImGui::SameLine();
            ImGui::PopID();
        }
        ImGui::EndTable();
    }
    ImGui::End();
}

// Based on: https://github.com/drhelius/Gearboy
static void displayProcessor() {
    if (!showProcessor)
        return;

    ImGui::SetNextWindowPos(ImVec2(1063, 25), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowSize(ImVec2(159, 218), ImGuiCond_FirstUseEver);
    ImGui::Begin("Processor", &showProcessor, ImGuiWindowFlags_NoResize);

    // CPU Flags
    ImGui::TextColored(*flagColor, "   Z");
    ImGui::SameLine();
    ImGui::Text("= %d", (bool)(emulator->getStatus() & FLAG_Z));
    ImGui::SameLine();
    ImGui::TextColored(*flagColor, "  C");
    ImGui::SameLine();
    ImGui::Text("= %d", (bool)(emulator->getStatus() & FLAG_C));
    ImGui::TextColored(*flagColor, "   N");
    ImGui::SameLine();
    ImGui::Text("= %d", (bool)(emulator->getStatus() & FLAG_N));
    ImGui::SameLine();
    ImGui::TextColored(*flagColor, "  V");
    ImGui::SameLine();
    ImGui::Text("= %d", (bool)(emulator->getStatus() & FLAG_V));

    // CPU Registers
    ImGui::Columns(2, "registers");
    ImGui::Separator();
    ImGui::TextColored(*registerColor, " A");
    ImGui::SameLine();
    ImGui::Text("= $%02X", emulator->getRegA());
    ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator->getRegA()));
    ImGui::NextColumn();
    ImGui::TextColored(*registerColor, " B");
    ImGui::SameLine();
    ImGui::Text("= $%02X", emulator->getRegB());
    ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator->getRegB()));
    ImGui::NextColumn();
    ImGui::Separator();
    ImGui::TextColored(*registerColor, " H");
    ImGui::SameLine();
    ImGui::Text("= $%02X", emulator->getRegH());
    ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator->getRegH()));
    ImGui::NextColumn();
    ImGui::TextColored(*registerColor, " L");
    ImGui::SameLine();
    ImGui::Text("= $%02X", emulator->getRegL());
    ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator->getRegL()));

    // PC
    ImGui::NextColumn();
    ImGui::Columns(1);
    ImGui::Separator();
    ImGui::TextColored(*registerColor, "    PC");
    ImGui::SameLine();
    ImGui::Text("= $%04X", emulator->getPC());
    ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED " " BYTE_TO_BINARY_PATTERN_SPACED,
                BYTE_TO_BINARY((emulator->getPC() & 0xFF00) >> 8),
                BYTE_TO_BINARY(emulator->getPC() & 0xFF));

    // SP
    ImGui::Columns(2);
    ImGui::Separator();
    ImGui::TextColored(*registerColor, "SP");
    ImGui::SameLine();
    ImGui::Text("= $%02X", emulator->getSP());
    ImGui::Text(BYTE_TO_BINARY_PATTERN_SPACED, BYTE_TO_BINARY(emulator->getSP()));

    // Halted or not
    ImGui::NextColumn();
    ImGui::TextColored(*breakpointColor, "HALT");
    ImGui::SameLine();
    ImGui::Text("= %d", halted);

    ImGui::End();
}

static void displayDisassembly() {
    if (!showDisassembly)
        return;

    ImGui::SetNextWindowSize(ImVec2(276, 394), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(1063, 248), ImGuiCond_FirstUseEver);
    ImGui::Begin("Disassembly", &showDisassembly);
    ImGui::BeginChild("DisassemblyView", ImVec2(ImGui::GetWindowWidth() - 10, ImGui::GetWindowHeight() - 60), true);
    if (disassembler) {
        int previousEnd = -1;
        for (const auto &instruction: disassembler->getDisassembled()) {
            if (previousEnd != -1 and previousEnd < instruction.address)
                ImGui::TextUnformatted("----------------------------------");
            ImGui::PushStyleColor(ImGuiCol_Text, emulator->getPC() == instruction.address ? *flagColor : *windowColor);
            ImGui::TextUnformatted(instruction.text.c_str());
            ImGui::PopStyleColor();
            if (emulator->getPC() == instruction.address and disassemblerJumpToPC)
                ImGui::SetScrollHereY();
            previousEnd = instruction.address + instruction.size;
        }
    }
    ImGui::EndChild();
    ImGui::Checkbox("Follow PC", &disassemblerJumpToPC);
    ImGui::End();
}

static void displayBreakpoints() {
    if (!showBreakpoints)
        return;

    ImGui::SetNextWindowSize(ImVec2(145, 218), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(1227, 25), ImGuiCond_FirstUseEver);
    ImGui::Begin("Breakpoints", &showBreakpoints);
    ImGui::BeginChild("BreakpointList", ImVec2(ImGui::GetWindowWidth() - 10, ImGui::GetWindowHeight() - 60), true);
    for (auto breakpoint: breakpoints) {
        ImGui::PushID(breakpoint);
        if (ImGui::Button("X")) {
            breakpoints.erase(breakpoint);
            ImGui::PopID();
            break;
        }
        ImGui::PopID();
        ImGui::SameLine();
        ImGui::TextColored(*breakpointColor, "$%04x", breakpoint);
    }
    ImGui::EndChild();
    ImGui::SetNextItemWidth(40);
    ImGui::InputText("##", breakpointText, 5, ImGuiInputTextFlags_NoHorizontalScroll
                                              | ImGuiInputTextFlags_CharsHexadecimal | ImGuiInputTextFlags_AlwaysOverwrite | ImGuiInputTextFlags_AutoSelectAll);
    ImGui::SameLine();
    if (ImGui::Button("Add") and breakpointText[0] != 0) {
        breakpoints.insert(strtol(breakpointText, nullptr, 16));
        breakpointText[0] = 0; // Set first character to null to clear string
    }
    ImGui::SameLine();
    if (ImGui::Button("Clear"))
        breakpoints.clear();
    ImGui::End();
}

static void displayTimers() {
    if (!showTimers)
        return;

    ImGui::SetNextWindowSize(ImVec2(196, 74), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(1279, 648), ImGuiCond_FirstUseEver);
    ImGui::Begin("Timers", &showTimers);
    for (int i = 0; i < TIMER_COUNT; i++) {
        ImGui::TextColored(emulator->getTimerValue(i) ? *outputColor : *breakpointColor, "%i:", i);
        ImGui::SameLine();
        ImGui::Text("% 3i", emulator->getTimerCount(i));
        ImGui::SameLine();
        ImGui::Text("%sseconds", TIMER_MODES[emulator->getTimerMode(i)]);
    }
    ImGui::End();
}

static void displayPWM() {
    if (!showPWM)
        return;

    ImGui::SetNextWindowSize(ImVec2(95, 155), ImGuiCond_FirstUseEver);
    ImGui::SetNextWindowPos(ImVec2(1377, 25), ImGuiCond_FirstUseEver);
    ImGui::Begin("PWM", &showPWM);
    ImGui::TextColored(*registerColor, "Count");
    ImGui::SameLine();
    ImGui::Text("= $%02x", emulator->getPwmCount());
    ImGui::Separator();
    for (int i = 0; i < 6; i++) {
        ImGui::TextColored(emulator->getPwmEnable(i) ? *flagColor : *disabledColor, i > 3 ? "A%i:" : "A%i: ", PWM_PINS[i]);
        ImGui::SameLine();
        ImGui::Text("$%02x", emulator->getPwmDutyCycle(i));
    }
    ImGui::End();
}

static void handleShortcuts() {
    if (ImGui::IsKeyDown(SDL_SCANCODE_LCTRL)) {
        if (ImGui::IsKeyPressed(SDL_SCANCODE_P, false))
            paused ^= 1;
#ifndef __EMSCRIPTEN__
        if (ImGui::IsKeyPressed(SDL_SCANCODE_O, false))
            ImGuiFileDialog::Instance()->OpenDialog("ChooseROM", "Choose ROM", ".bin", ".");
#endif
        if (ImGui::IsKeyPressed(SDL_SCANCODE_B, false))
            enableBreakpoints ^= 1;
        if (ImGui::IsKeyPressed(SDL_SCANCODE_Z, true) and !halted and paused)
            stepBreakpoint = true;
        if (ImGui::IsKeyPressed(SDL_SCANCODE_R, false)) {
            halted = false;
            emulator->reset();
        }
    }
}

static void runEmulator() {
    if (!halted and (!paused or stepBreakpoint)) {
        try {
            // Todo: Configurable clock speed
            for (int i = 0; i < 16667 / (1 << processorSpeeds[processorSpeed]); i++) { // Run at around 1 million instructions per second
                if (controllerPeripheral) {
                    if (!emulator->getGpioOutput(0))
                        emulator->getGPIO(0) = ImGui::IsKeyDown(SDL_SCANCODE_W) or ImGui::IsKeyDown(SDL_SCANCODE_UP);
                    if (!emulator->getGpioOutput(1))
                        emulator->getGPIO(1) = ImGui::IsKeyDown(SDL_SCANCODE_S) or ImGui::IsKeyDown(SDL_SCANCODE_DOWN);
                    if (!emulator->getGpioOutput(2))
                        emulator->getGPIO(2) = ImGui::IsKeyDown(SDL_SCANCODE_A) or ImGui::IsKeyDown(SDL_SCANCODE_LEFT);
                    if (!emulator->getGpioOutput(3))
                        emulator->getGPIO(3) = ImGui::IsKeyDown(SDL_SCANCODE_D) or ImGui::IsKeyDown(SDL_SCANCODE_RIGHT);
                }

                emulator->updateTimers(1 << processorSpeeds[processorSpeed]);

                emulator->run();

                if (disassembler)
                    disassembler->update(emulator->getPC(), emulator->getRegH() << 8 | emulator->getRegL());

                bool broken = false;
                if (enableBreakpoints)
                    for (auto breakpoint: breakpoints)
                        if (emulator->getPC() == breakpoint) {
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
}

static void mainLoop(void *arg) {
    imguiIO = &ImGui::GetIO();
    IM_UNUSED(arg);

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

    handleShortcuts();

    runEmulator();

    // Update display texture from buffer
    glBindTexture(GL_TEXTURE_2D, displayTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, DISPLAY_WIDTH, DISPLAY_HEIGHT, 0, GL_RGB, GL_UNSIGNED_BYTE, emulator->getDisplayBuffer());
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);

    // Draw windows
    displayMainMenuBar();
    displayRomBrowser();
    displayScreen();
    displayMemoryViewers();
    displayPrintLog();
    displayPanelIO();
    displayPanelGPIO();
    displayProcessor();
    displayDisassembly();
    displayBreakpoints();
    displayTimers();
    displayPWM();

    // Render
    ImGui::Render();
    glViewport(0, 0, (int)imguiIO->DisplaySize.x, (int)imguiIO->DisplaySize.y);
    glClearColor(windowColor->x * windowColor->w, windowColor->y * windowColor->w, windowColor->z * windowColor->w, windowColor->w);
    glClear(GL_COLOR_BUFFER_BIT);
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
    SDL_GL_SwapWindow(window);
}

int main(int argc, char* argv[]) {
    emulator = new Emulator();

#ifdef __EMSCRIPTEN__
    showIO = false;
    showGPIO = false;
    displayScale = 5;
    showPrintLog = false;
    controllerPeripheral = true;
    loadRom("Snake.bin");
#else
    // Parse program arguments
    if (argc == 1)
        paused = true;
    else if (argc > 2) {
        std::cout << "Usage: './emulator' or './emulator <program>.bin'" << std::endl;
        return -1;
    } else if (!loadRom(argv[1]))
        return -1;
#endif

    // Initialize SDL and OpenGL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER)) {
        std::cout << "Failed to initialize SDL: " << SDL_GetError() << std::endl;
        return -1;
    }
#ifdef __EMSCRIPTEN__
    const char* glslVersion = "#version 100";
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 2);
#else
    const char* glslVersion = "#version 130";
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
#endif
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
    SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);
    auto window_flags = (SDL_WindowFlags)(SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI);
    window = SDL_CreateWindow("Emulator", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1482, 729, window_flags);
    glContext = SDL_GL_CreateContext(window);
    SDL_GL_MakeCurrent(window, glContext);
    SDL_GL_SetSwapInterval(1); // Enable vsync
#ifndef __EMSCRIPTEN__
    auto glewState = glewInit();
    if (glewState != GLEW_OK) {
        std::cout << "Failed to initialize OpenGL loader: " << glewState << std::endl;
        return -1;
    }
#endif

    // Setup ImGui
    IMGUI_CHECKVERSION();
    auto context = ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
#ifdef __EMSCRIPTEN__
    IM_UNUSED(context);
    io.IniFilename = NULL;
#endif
    io.WantCaptureKeyboard = true;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableGamepad;
    ImGui::StyleColorsDark(); // Setup Dear ImGui style
    ImGui_ImplSDL2_InitForOpenGL(window, glContext);
    ImGui_ImplOpenGL3_Init(glslVersion);
    io.Fonts->AddFontDefault(); // Load default font before others

    // Create display texture
    glGenTextures(1, &displayTexture);

    // Create ImGui windows
    ramEditor = new MemoryEditor();
    ramEditor->Open = false;
    romViewer = new MemoryEditor();
    romViewer->Open = false;
    romViewer->ReadOnly = true;

    // 7-segment display font
    ImFontConfig config;
    config.SizePixels = 40;
    font7Segment = io.Fonts->AddFontDefault(&config);

    // Colors
    windowColor = new ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
    flagColor = new ImVec4(0.0f,1.0f,1.0f,1.0f);
    registerColor = new ImVec4(1.0f,1.0f,0.0f,1.0f);
    breakpointColor = new ImVec4(1.0f,0.1f,0.1f,1.0f);
    outputColor = new ImVec4(0.0f,1.0f,0.0f,1.0f);
    disabledColor = new ImVec4(0.7f,0.7f,0.7f,1.0f);

#ifdef __EMSCRIPTEN__
    processorSpeed = 2;
    emscripten_set_main_loop_arg(mainLoop, nullptr, 0, true);
    IM_UNUSED(setupPersistenceHandler);
#else
    setupPersistenceHandler(context);

    while (true) {
        mainLoop(nullptr);
        if (exited)
            break;
    }

    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
    SDL_GL_DeleteContext(glContext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    // Must be deleted after ImGui shutdown for INI saving
    delete ramEditor;
    delete romViewer;

    delete windowColor;
    delete registerColor;
    delete flagColor;
    delete breakpointColor;
    delete outputColor;
    delete disabledColor;

    delete disassembler;
    delete[] rom;
#endif

    return 0;
}