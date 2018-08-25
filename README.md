# DarkRISCV
Open source RISC-V implemented from scratch in one night!

## Introduction

Developed in a magic night of 19 Aug, 2018 (between 2am and 8am) the
*darkriscv* is a very, very experimental implementation of the risc-v
instruction set. Nowaways, after one week, the *darkriscv* reached a high
quality result, in a way that the "hello world" compiled by the gcc is 
working fine!

The general concept is based in my other early RISC processors and composed 
by a simplified two stage pipeline where a instruction is fetch from a
instruction memory in the first clock and decoded/executed in the second
clock. The pipeline is overlaped without interlocks, in a way the
*darkriscv* can reach the performance of one instruction per clock most of
time (the exception is after a branch, where the pipeline is flushed).  As
adition, the code is very compact, with around two hundred lines of verilog
code.

Although the code is small and crude when compared with other RISC-V
implementations, the *darkriscv* has lots of impressive features:

- implements most of the RISC-V RV32I instruction set
- works up to 75MHz and reach 1 instruction/clock most of time
- uses only 2 blockRAMs: one for instruction and another one for data
- uses only around 1000 LUTs (spartan-6)
- working fine in a real spartan-6 lx9 after one week of development
- working fine with gcc 9.0.0 for riscv (no patches required!)

Feel free to make suggestions and good hacking! o/

## Implementation Notes

Since my target is the ultra-low-cost Xilinx Spartan-6 family of FPGAs, the
project is currently based in the Xilinx ISE 14.4 for Linux.  However, no
explicit references for Xilinx elements are done and all logic is inferred
directly from Verilog, which means that the project is easily portable to
any other FPGA families.

One interesting fact is that although the *darkriscv* is 3x more efficient
when compared with *picorv32* (1 vs 3 clocks per instruction), the last one
is more heavly pipelined and can reach a clock 2x faster (75MHz vs 150MHz). 
Anyway, this means that the *darkriscv* is 1.5x faster than the *picorv32*
(75MIPS vs 50MIPS).  As long the motivation around the *darkriscv* is
replace some 680x0 and coldfire processors, the performance of 75MIPS is
good enough for me. Due to the way that the bus is designed, the *picorv32*
works in a simila way to a 68020 or 68030 with an asynchronous bus and the
*darkriscv* works like a 68040 with a synchronous bus. 

Sometimes this is good, sometimes not so good...  Unfortunately, the problem
regarding the bus is that the blockRAM requires two cycles in order to dump
the data, one clock to register the address and another clock to register de
data. In the case of *darkriscv* this is a problem and the current
workaround is set the blockRAMs to work in the opposite edge clock, which is
not so good, but works. In some sense, it is equivalent to say that the 
*darkriscv* have a pipeline with 1 + 2x1/2 stages:

- 1/2 stage for instruction pre-fetch
- 1/2 stage for static instruction decodification
- 1 stage for decodification and execution

Except in the case of load/store, which uses 2x1/2 stages:

- 1/2 stage for instruction pre-fetch
- 1/2 stage for static instruction decodification
- 1/2 stage for decodification and execution
- 1/2 state for data read

When working only with positive edge of clock, the performance increases 
from 75 to 100MHz, but one wait-state will be required for the bus, which means
that the final performance decreases from 75MIPS to 50MIPS.

For my surprise, after lots of years working only with big-endian
architectures, I found that the risc-v is a little-endian architecture!  I
am not sure the implementation is correct, but it appears to be working
without problems!

Additional performance results (synthesis estimatives onlly) for other xilinx
devices available in the ISE:

- spartan-3e:	47MHz
- spartan-6: 	75MHz
- artix-7: 	133MHz
- virtex-6: 	137MHz
- kintex-7: 	167MHz

Just for curiosity, the spartan-3e model 100 costs 12 usd (octopart) and the
*darkriscv* uses 86% of the FPGA capacity.

## Development Tools (gcc)

About the compiler, I am working with the experimental gcc 9.0.0 for riscv
(no patches or updates are required for the *darkriscv*, as long the gcc
appears to no use some missing features).  Although is possible use the
compiler set available in the oficial risc-v site, our colleagues from
lowRISC pointed a more clever way to build the toolchain:

https://www.lowrisc.org/blog/2017/09/building-upstream-risc-v-gccbinutilsnewlib-the-quick-and-dirty-way/

Finally, as long the *darkriscv* is not yet fully tested, sometimes is a
very good idea compare the code execution with another stable reference and
I am working with the excelent project *picorv32*:

https://github.com/cliffordwolf/picorv32

Maybe the most complex issue is the memmory design. Of course, it is a gcc
issue and it is not even a problem, in fact, is the way that the software
guyz works when linking the code and data! As long the early version of
*darkriscv* does not include support for a unified code and data memmory,
the ROM and RAM must be loaded with the same code generated by the gcc,
which is sometimes confusing to make work.

## Directory Description

- ise: the ISE project files (xise and ucf)
- rtl: the source for the core and soc
- sim: the simulation to test the soc
- src: the source code for the test firmware (hello.c)
- tmp: the ISE working directory (you need to create it!)

The *ise* directory contains the xise project file to be open in the Xilinx
ISE 14.x and the project is assembled in a way that all files are loaded. 
The ISE will ask about a missing *tmp* directory, just click in *Create* and
the directory will be created.  Although a *ucf* file is provided, the the
FPGA is not wired in any particular configuration.  Anyway, as long the
project is open, is possible build the FPGA or simulate.  The simulation
will show some waveforms and is possible check the XFIFO port in the top
level for debug information (the hello.c code prints the string "hello
world!" in the XFIFO).

## Future Work

At the moment, the *darksoc* is not so relevant and the only function is
provide support for the instruction and data memories, as well some related
glue-logic.  the proposal in the future is implement in the soc the cache
feature in order to make possible connect the *darkriscv* to external
memories, as well make possible connect multiple *darkriscv* cores in a SMP
configuration.
