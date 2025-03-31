# Simulation

This directory provides support for simulation tools.

## Icarus Verilog / GTKWave
The main simulation tool is the opensource tools `Icarus Verilog` and `GTKWave`.\
Alternatively, it is possible to use proprietary simulation tools, as
the Xilinx ISIM and ModelSIM.

TODO: simulation models for external peripherals, such as the DarkUART.

## Verilator / Cosimulation
As an alternative to Icarus Verilog, `Verilator` + `ImGui` (and/or gtkwave) can be used,
offering some kind of cosimulation with C/C++ modules, than can be useful
eg: for interactive simulations.\
Also it is sometimes beneficial to be able to compile RTL with different (open-source) simulators.

Prerequisites: Install verilator, sdl2, glew, glfw and imgui (built with sdl2 & opengl3 backends).

The `spidemo` has some preliminary Verilator support:
```shell
make clean all APPLICATION=spidemo NOBANNER=1 SPIBB=1 COSIM=1
```
This runs the spidemo with both HW and Bit-banging SPI master, with Verilator + ImGui.\
The banner is removed here because serial accesses are really slow in such cosimulation.\
Note that the overall performance in cosimulation is not as good as expected, for now.
