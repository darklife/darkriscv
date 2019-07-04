# DarkRISCV
Opensource RISC-V implemented from scratch in one night!


## Introduction

Developed in a magic night of 19 Aug, 2018 between 2am and 8am, the
*DarkRISCV* softcore started as an proof of concept for the opensource
RISC-V instruction set.  The general concept was based in my other early
16-bit RISC processors and composed by a simplified two stage pipeline
working with a two phase clock, where a instruction is fetch from a
instruction memory in the first clock and then the instruction is
decoded/executed in the second clock.  The pipeline is overlapped without
interlocks, in a way that the *DarkRISCV* can reach the performance of one
clock per instruction most of time, except by a taken branch, where one
clock is lost in the pipeline flush.  Of course, in order to perform read
operations in blockrams in a single clock, a two-phase clock is required, in
a way that no wait states are required.  As result, the code is very
compact, with around three hundred lines of obfuscated but beautiful Verilog
code.  After lots of exciting sleepless nights of work and the help of lots
of colleagues, the *DarkRISCV* reached a very good quality result, in a way
that the code compiled by the standard GCC for RV32I worked fine.

Nowadays, a three stage pipeline working with a single clock phase is also
available, resulting in a better distribution between the decode and execute
stages.  In this case the instruction is fetch in the first clock from a
blockram, decoded in the second clock and executed in the third clock.  As
long the load instruction cannot load the data from a blockram in a single
clock, the external logic inserts one extra clock in this case.  Also, there
are two extra clocks in order to flush the pipeline in the case of taken
branches.  The impcat of the pipeline flush depends of the compiler
optimizations, but according to the lastest measurements, the 3-stage
pipeline version can reach a instruction per clock (IPC) of 0.7, smaller
than the measured IPC of 0.85 in the case of the 2-stage pipeline version. 
Anyway, with the 3-stage pipeline and some other expensive optimizations,
the *DarkRISCV* can reach 100MHz in a low-cost Spartan-6, which results in
more performance when compared with the 2-stage pipeline version, which is
supported as reference and with smaller clocks (typically 50MHz).

Although the code is small and crude when compared with other RISC-V
implementations, the *DarkRISCV* has lots of impressive features:

- implements most of the RISC-V RV32I instruction set
- works up to 100MHz (Spartan-6) with 1 clock per instruction most of time
- flexible harvard architecture (easy to integrate a cache controller)
- works fine in a real spartan-6 (lx9/lx16/lx45 up to 100MHz)
- works fine with gcc 9.0.0 for RISC-V (no patches required!)
- uses only around 1000-1500 LUTs (depending of enabled features)
- BSD license: can be used anywhere with no restrictions!

And much other features! Feel free to make suggestions and good hacking! o/

The project documentation is available in the [doc](doc) directory, but 
there are also extra README.md files available in other directory in order to better explain how that different parts of the project works.

## Index

- [Introduction](doc/README.md#Introduction)
- [Project Background](doc/README.md#project_background)
- [Directory Description](doc/README.md#directory_description)
- [Development Tools](doc/README.md#development_tools)
- [Implementation Notes](doc/README.md#implementation_notes)
- [Simulation](doc/README.md#simulation)
- [Acknowledgments](doc/README.md#acknowledgments)
- [References](doc/README.md#references)
