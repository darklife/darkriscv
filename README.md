# DarkRISCV
Open source RISC-V implemented from scratch in one night!

## Introduction

Developed in a magic night of 19 Aug, 2018 (between 2am and 8am) the
*darkriscv* is a very, very experimental implementation of the RISC-V
instruction set. Nowadays, after one week, the *darkriscv* reached a high
quality result, in a way that the "hello world" compiled by the gcc is 
working fine!

The general concept is based in my other early RISC processors and composed 
by a simplified two stage pipeline where a instruction is fetch from a
instruction memory in the first clock and decoded/executed in the second
clock. The pipeline is overlapped without interlocks, in a way the
*darkriscv* can reach the performance of one instruction per clock most of
time (the exception is after a branch, where the pipeline is flushed).  As
addition, the code is very compact, with around two hundred lines of Verilog
code.

Although the code is small and crude when compared with other RISC-V
implementations, the *darkriscv* has lots of impressive features:

- implements most of the RISC-V RV32I instruction set
- works up to 75MHz and reach 1 instruction/clock most of time
- uses only 2 blockRAMs: one for instruction and another one for data
- uses only around 1000 LUTs (spartan-6)
- working fine in a real spartan-6 lx9 after one week of development
- working fine with gcc 9.0.0 for RISC-V (no patches required!)
- flexible harvard architecture

Feel free to make suggestions and good hacking! o/

## Implementation Notes

Since my target is the ultra-low-cost Xilinx Spartan-6 family of FPGAs, the
project is currently based in the Xilinx ISE 14.4 for Linux.  However, no
explicit references for Xilinx elements are done and all logic is inferred
directly from Verilog, which means that the project is easily portable to
any other FPGA families.

One interesting fact is that although the *darkriscv* is 3x more efficient
when compared with *picorv32* (1 vs 3 clocks per instruction), the last one
is more heavily pipelined and can reach a clock 2x faster (75MHz vs 150MHz). 
Anyway, this means that the *darkriscv* is 1.5x faster than the *picorv32*
(75MIPS vs 50MIPS).  As long the motivation around the *darkriscv* is
replace some 680x0 and Coldfire processors, the performance of 75MIPS is
good enough for me. Due to the way that the bus is designed, the *picorv32*
works in a similar way to a 68020 or 68030 with an asynchronous bus and the
*darkriscv* works like a 68040 with a synchronous bus. 

Sometimes this is good, sometimes not so good...  Unfortunately, the problem
regarding the bus is that the blockRAM requires two cycles in order to dump
the data, one clock to register the address and another clock to register de
data. In the case of *darkriscv* this is a problem and the current
workaround is set the blockRAMs to work in the opposite edge clock, which is
not so good, but works. In some sense, it is equivalent to say that the 
*darkriscv* have a pipeline with 1 + 2x1/2 stages:

- 1/2 stage for instruction pre-fetch
- 1/2 stage for static instruction decode
- 1 stage for decode and execution

Except in the case of load/store, which uses 2x1/2 stages:

- 1/2 stage for instruction pre-fetch
- 1/2 stage for static instruction decode
- 1/2 stage for decode and execution
- 1/2 state for data read

When working only with positive edge of clock, the performance increases 
from 75 to 100MHz, but one wait-state will be required for the bus, which means
that the final performance decreases from 75MIPS to 50MIPS.

After some work, the *darkriscv* supports a variable number of wait-states
between 0 and n. Although is possible work with memories in the positive
edge of clock by inserting one wait-state, the performance in this case
decreases from 1 instruction per clock to 0.5 instructions per clock.

For my surprise, after lots of years working only with big-endian
architectures, I found that the RISC-V is a little-endian architecture!  I
am not sure the implementation is correct, but it appears to be working
without problems!

Additional performance results (synthesis only) for other Xilinx
devices available in the ISE:

- Spartan-3e:	47MHz
- Spartan-6: 	75MHz
- Artix-7: 	133MHz
- Virtex-6: 	137MHz
- Kintex-7: 	167MHz

Of course, the above numbers always change according to the logic around the
*darkriscv*, which means that numbers are just an approximation. Just for
curiosity, the spartan-3e model 100 costs 12$ (octopart.com) and the
*darkriscv* uses 86% of the FPGA capacity.

In the first implementation, the cache controller reduces the performance by
around 30%, which means that the 75MHz core will run only with 50MHz with
the cache controller added. Of course, the shared bus and the external
memory will add extra overhead, as well wait-states. In the tests I used
only the blockRAM to simulate a unified memory with 3-wait-states. As long
the instruction and data cache filling must share the same bus, the data
operations are done before the instruction operation and then the next 
instruction is fetched. I am not sure this scheme is fully safe, but the 
"hello world" code is working fine.

In fact, when running the "hello world" code we get the following results:

- darkriscv@75MHz -cache -wait-states: 6.040us
- darkriscv@50MHZ +cache +wait-states: 13.84us

As long the code is very small and fits entirely in the cache: the code is
almost all cached after 3.7us and the data after 3.0us. As long the
*darkriscv* uses a write through scheme, the write operations always
require 3-wait-states. According to the "hello world" test, the version with
cache controller is 50% worst, but it is probably better than always insert
wait states regarding an slow external memory.

In the case, we have 3 wait states at 50MHz, which means a memory working
at around 16MHz. In the case of the *darkriscv* clocked at 75MHz, we need
probably 5 wait states, which results in a theorical performance of around 30us
to run the "hello world" test. This means that the *darkriscv* w/ cache
controller running at 50MHz and 3 wait states is more than 2x faster than a
*darkriscv* w/o cache controller running at 75MHz and with 5 wait states.

## Development Tools (gcc)

About the compiler, I am working with the experimental gcc 9.0.0 for RISC-V
(no patches or updates are required for the *darkriscv*, as long the gcc
appears to no use some missing features).  Although is possible use the
compiler set available in the oficial RISC-V site, our colleagues from
lowRISC pointed a more clever way to build the toolchain:

https://www.lowrisc.org/blog/2017/09/building-upstream-risc-v-gccbinutilsnewlib-the-quick-and-dirty-way/

Finally, as long the *darkriscv* is not yet fully tested, sometimes is a
very good idea compare the code execution with another stable reference and
I am working with the project *picorv32*:

https://github.com/cliffordwolf/picorv32

Maybe the most complex issue is the memory design. Of course, it is a gcc
issue and it is not even a problem, in fact, is the way that the software
guys works when linking the code and data! As long the early version of
*darkriscv* does not include support for a unified code and data memory,
the ROM and RAM must be loaded with the same code generated by the gcc,
which is sometimes confusing to make work.

## Directory Description

- ise: the ISE project files (xise and ucf)
- rtl: the source for the core and soc
- sim: the simulation to test the soc
- src: the source code for the test firmware (hello.c)
- tmp: the ISE working directory (you need to create it!)

The *ise* directory contains the *xise* project file to be open in the Xilinx
ISE 14.x and the project is assembled in a way that all files are loaded. 
The ISE will ask about a missing *tmp* directory, just click in *Create* and
the directory will be created.  Although a *ucf* file is provided, the the
FPGA is not wired in any particular configuration.  Anyway, as long the
project is open, is possible build the FPGA or simulate.  The simulation
will show some waveforms and is possible check the XFIFO port in the top
level for debug information (the hello.c code prints the string "hello
world!" in the XFIFO).

## Future Work

At the moment, the *darksocv* is not so relevant and the only function is
provide support for the instruction and data memories, as well some related
glue-logic. The proposal in the future is implement in the SoC the cache
feature in order to make possible connect the *darkriscv* to large external
memories, as well make possible connect multiple *darkriscv* cores in a SMP
configuration.

One possible update for the future is integrate the cache controller in 
the core, in a way is possible a better flow control. Currently, the only
interface between the core and the cache controller is the sinal HLT, which
is the same signal for instruction and data.
