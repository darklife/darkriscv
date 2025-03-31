/*
 * Copyright (c) 2025, Nicolas Sauzede <nicolas.sauzede@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <imgui.h>
#include <backends/imgui_impl_sdl2.h>
#include <backends/imgui_impl_opengl3.h>
#include <SDL2/SDL.h>
#include <GL/glew.h> // Use GLEW for OpenGL function loading
#include "Vdarksocv.h"
#include "verilated_vcd_c.h"
Vdarksocv *darksocv = NULL;
VerilatedVcdC* tfp = NULL;
vluint64_t main_time = 0, last_step = 0;
static bool clk, reset = true, autoreset, run = true, autostep = true, quit;
static int step, step_time = 1, inc = 5;
void init_darksocv() {
    if (!darksocv) darksocv = new Vdarksocv;
    if (!tfp) {
        tfp = new VerilatedVcdC;
        Verilated::traceEverOn(true);
        darksocv->trace(tfp, 99);
#ifndef VCD_FILE
#define VCD_FILE "Vdarksocv_gui.vcd"
#endif
        tfp->open(VCD_FILE);
    }
}
void cleanup_darksocv() {
    if (tfp){tfp->close();delete tfp;}
    delete darksocv;
}
void handle_key_event(SDL_Event& event) {
    if (event.type == SDL_KEYDOWN) {
        if (event.key.keysym.sym == SDLK_c) { clk = !clk; }
        else if (event.key.keysym.sym == SDLK_r) { reset = !reset; }
        else if (event.key.keysym.sym == SDLK_s) { step = 2; }
        else if (event.key.keysym.sym == SDLK_a) { autostep = !autostep; }
        else if (event.key.keysym.sym == SDLK_SPACE) { run = !run; }
    }
}
void render_gui() {
    vluint64_t vtime = Verilated::time();
    if (Verilated::gotFinish()) quit = true;
    ImGui::Begin("darksocv");
    ImGui::Checkbox("Run", &run);
    ImGui::SameLine();if (ImGui::Button("Quit")) { quit = true; }
    ImGui::SameLine();ImGui::Checkbox("AutoStep", &autostep);
    ImGui::SameLine();if (ImGui::Button("Step")) { step = 2; }
//    ImGui::SameLine();ImGui::Text("step=%d", step);
    ImGui::SameLine();ImGui::Text("main_time %ld, Vtime=%ld", main_time, vtime);
    ImGui::SliderInt("StepTime", &step_time, 1, 10);
    ImGui::SameLine();ImGui::Text("last_step=%ld", last_step);
    ImGui::Checkbox("clk", &clk);
    ImGui::SameLine();ImGui::Checkbox("AutoReset", &autoreset);
    ImGui::SameLine();if (ImGui::Button("Reset")) { reset = true; }
    //ImGui::SameLine();
    ImGui::Text("LED %08lX", (unsigned long)darksocv->LED);
//    ImGui::Text("DATAI %08lX", (unsigned long)darksocv->DATAI);
//    ImGui::Text("DATAO %08lX", (unsigned long)darksocv->DATAO);
    ImGui::Text("DEBUG %01X", (int)darksocv->DEBUG);
//    ImGui::Text("IRQ %d", (int)darksocv->IRQ);
//    ImGui::Text("WR %d", (int)darksocv->WR);
    if ((main_time++>=(last_step+step_time)) && run) {
        if (step) { clk = !clk; }
        if (vtime <= 200*inc) {
            reset = 1;
        } else {
            reset = 0;
        }
//        darksocv->RXD = 1;
        darksocv->XCLK = clk;
        darksocv->XRES = reset;
        darksocv->eval();
        if(tfp) { tfp->dump(vtime); }
        Verilated::timeInc(inc);
        if (step) { step--; }
        if (autostep && !step) { step = 2; }
        reset = false;
        if (autoreset) reset = true;
        last_step = main_time;
    }
    ImGui::End();
}
////////////////////////////////////////////////////////////////////////////////
int main() {
    init_darksocv();
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0) {
        printf("Error: %s\n", SDL_GetError());
        return -1;
    }
    SDL_Window* window = SDL_CreateWindow("Dear ImGui Example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 800, 600, SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);
    if (!window) {
        printf("Error: %s\n", SDL_GetError());
        return -1;
    }
    SDL_GLContext gl_context = SDL_GL_CreateContext(window);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
    SDL_GL_SetSwapInterval(1); // Enable vsync
    if (glewInit() != GLEW_OK) {
        printf("Failed to initialize GLEW\n");
        return -1;
    }
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    ImGui::StyleColorsDark(); // Use dark style
    ImGui_ImplSDL2_InitForOpenGL(window, gl_context);
    ImGui_ImplOpenGL3_Init("#version 130"); // GLSL version 130
    SDL_Event event;
    while (!quit) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                printf("SDL_QUIT\n");
                quit = true;
            } else
                handle_key_event(event);
            ImGui_ImplSDL2_ProcessEvent(&event); // Pass events to ImGui
        }
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplSDL2_NewFrame(
#if IMGUI_VERSION_NUM == 19010
            window // ImGui 1.90.1 / SDL2 2.30.0 (Ubuntu 24.04.1) have an 'window' argument
#endif
        );
        ImGui::NewFrame();
        render_gui();
        ImGui::Render();
        glViewport(0, 0, 800, 600);
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        SDL_GL_SwapWindow(window);
    }
    printf("Shutting down..\n");
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();
    SDL_GL_DeleteContext(gl_context);
    SDL_DestroyWindow(window);
    SDL_Quit();
    cleanup_darksocv();
    return 0;
}
