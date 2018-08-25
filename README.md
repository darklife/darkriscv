# DarkRISCV
Open source RISC-V implemented from scratch in one night!

## Introduction

Developed in a magic night of 19 Aug, 2018 (between 2am and 8am) the *darkriscv* 
is a very, very experimental implementation of the risc-v instruction set. 

The general concept is based in my other early RISC processors, composed by a 
simplified two stage pipeline where a instruction is fetch from a instruction memory
in the first clock and decoded/executed in the second clock. The pipeline is
overlaped without interlocks, in a way the *darkriscv* can reach the performance of one 
instruction per clock most of time (the exception is after a branch, where
the pipeline is flushed). As adition, the code is very compact, with around two 
hundred lines of verilog code.

Although the code is small and crude when compared with other RISC-V implementations, 
the *darkriscv* has lots of impressive features:

- implements most of the RISC-V RV32I instruction set
- works up to 80MHz and can peaks 1 instruction/clock most of time
- uses only 2 blockRAMs: one for instruction and another one for data
- uses only around 1000 LUTs in the core
- working fine in a real spartan-6 lx9 after one week of development
- working fine with gcc 9.0.0 for riscv (no patches required!)

Feel free to make suggestions and good hacking! o/

## Implementation Notes

Since my target is the ultra-low-cost Xilinx Spartan-6 family of FPGAs, the project 
is currently based in the Xilinx ISE 14.4 for Linux. However, no explicit references for 
Xilinx elements are done and all logic is inferred directly from Verilog, which means
that the project is easily portable to any other FPGA families.

About the compiler, I am working with the experimental gcc 9.0.0 for riscv (no patches or
updates are required for the *darkriscv*, as long the gcc appears to no use some missing
features). Although is possible use the compiler set available in the oficial risc-v site, 
our colleagues from lowRISC pointed a more clever way to build the toolchain:

https://www.lowrisc.org/blog/2017/09/building-upstream-risc-v-gccbinutilsnewlib-the-quick-and-dirty-way/

Finally, as long the *darkriscv* is not yet fully tested, sometimes is a
very good idea compare the code execution with another stable reference and
I am working with the excelent project *picorv32*:

https://github.com/cliffordwolf/picorv32

One interesting fact is that although the *darkriscv* is 3x more efficient when compared
with *picorv32*, the last one is more heavly pipelined and can reach a clock
2x faster. This means that the *darkriscv* is 1.5x faster than the *picorv32*, but 
in limited conditions (use of a small LUT-ram instead of blockRAM, see ahead).

As long the motivation around the *darkriscv* is replace some 680x0 and coldfire 
processors, my target is try keep the performance of ~80MIPS in a spartan-6 lx4.

Unfortunately, after some fixes, I found that a dual-stage pipeline prevents
that the RAM memmory can be handled correctly the load instruction. This
means that the RAM memory must be fully combinational (a small LUT-ram, in this case the 
clock can reach up to 80MHz) or synchronous to the  negative edge (blockRAM, in this case
the clock can reach only 50MHz). 

In order to bypass this problem, the pipeline must be updated from 2 stages
to at least 3 states, with an additional stage between the pre-fetch and
execute stages, in order to stop the pipeline when a load/store instruction
is found and enable a variable access length between 2 and n cycles, according
to the cache state (hit/miss) and according to the external memory speed.

For my surprise, after lots of years working only with big-endian architectures, I found 
that the risc-v is a little-endian architecture! I am not sure the implementation is correct, 
but it appears to be working without problems!

## Directory Description

- ise: the ISE project files (xise and ucf)
- rtl: the source for the core and soc
- sim: the simulation to test the soc
- src: the source code for the test firmware (hello.c)
- tmp: the ISE working directory (you need to create it!)

The *ise* directory contains the xise project file to be open in the Xilinx ISE 14.x 
and  the project is assembled in a way that all files are loaded. The ISE will ask about
a missing *tmp* directory, just click in *Create* and the directory will be created. 
Although a *ucf* file is provided, the the FPGA is not wired in any particular configuration. 
Anyway, as long the project is open, is possible build the FPGA or simulate. The simulation
will show some waveforms and is possible check the XFIFO port in the top level for
debug information (the hello.c code prints the string "hello world!" in the XFIFO).

## Future Work

At the moment, the *darksoc* is not so relevant and the only function is
provide support for the instruction and data memories, as well some related
glue-logic. the proposal in the future is implement in the soc the cache feature
in order to make possible connect the *darkriscv* to external memories, as well
make possible connect multiple *darkriscv* cores in a SMP configuration.
