# DarkRISCV
Opensource RISC-V implemented from scratch in one night!

## Index

TODO: investigate how create an index here! o/

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
of colleagues, the *DarkRRISCV* reached a very good quality result, in a way
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

- implements most of the RISC-V RV32I instruction set (missing csr*, e* and fence*)
- works up to 100MHz (spartan-6) and sustain 1 clock per instruction most of time
- flexible harvard architecture (easy to integrate a cache controller)
- works fine in a real spartan-6 (lx9/lx16/lx45 up to 100MHz)
- works fine with gcc 9.0.0 for RISC-V (no patches required!)
- uses only around 1000-1500 LUTs (depending of enabled features)
- BSD license: can be used anywhere with no restrictions!

Some extra features are planned for the furure or under development:

- interrupt controller (under tests)
- cache controller (under tests)
- gpio and timer (under tests)
- sdram controller
- branch predictor 
- ethernet controller (GbE)
- multi-threading (SMT)
- multi-processing (SMP)
- network on chip (NoC)
- rv32e support (less registers, more threads)
- rv64i support
- 16x16-bit MAC instruction (under tests!)
- big-endian support
- user/supervisor modes
- debug support

And much other features! Feel free to make suggestions and good hacking! o/

## Project Background

The main motivation for the *DarkRISCV* was create a migration path for some
projects around the 680x0/Coldfire family.  

Although there are lots of 680x0 cores available, they are designed around
different concepts and requirements, in a way that I found no much options
regarding my requirements (more than 50MIPS with around 1000LUTs).  The best
option at this moment, the TG68, requires at least 2400LUTs (by removing the
MUL/DIV instructions), and works up to 40MHz in a Spartan-6.  As addition,
the TG68 core requires at least 2 clock per instruction, which means a peak
performance of 20MIPS.  As long the 680x0 instruction is too complex, this
result is really not bad at all and, at this moment, probably the best
opensource option to replace the 68000.

Anyway, it does not match with the my requirements regarding space and
performance.  As part of the investigation, I tested other cores, but I
found no much options as good as the TG68 and I even started design a
risclized-68000 core, in order to try find a solution.  Unfortunately, I
found no much ways to reduce the space and increase the performance, in a
way that I started investigate about non-680x0 cores.  After lots of tests
with different cores, I found the *picorv32* core and the all the ecosystem
around the RISC-V.  The *picorv32* is a very nice project and can peak up to
150MHz in a low-cost Spartan-6.  Although most instructions requires 3 or 4
clocks per instruction, the *picorv32* resembles the 68020 in some ways, but
running at 150MHz and providing a peak performance of 50MIPS, which is very
impressive.

Although the *picorv32* is a very good option to directly replace the 680x0
family, it is not powerful enough to replace some Coldfire processors (more
than 75MIPS).  As long I had some good experience with experimental 16-bit
RISC cores for DSP-like applications, I started code the *DarkRISCV* only to
check the level of complexity and compare with my risclized-68000.  For my
surprise, in the first night I mapped almost all instructions of the rv32i
specification and the *DarkRISCV* started to execute the first instructions
correctly at 75MHz and with one clock per instruction, which not only
resembles a fast and nice 68040 and can beat some Coldfires!  wow!  :)

After the success of the first nigth, I started to work in order to fix
small details in the hardware and software implementation. 

## Implementation Notes

Since my target is the ultra-low-cost Xilinx Spartan-6 family of FPGAs, the
project is currently based in the Xilinx ISE 14.7 for Linux, which is the
latest available ISE.  However, there is no explicit reference for Xilinx
elements and all logic is inferred directly from Verilog, which means that
the project is easily portable to other FPGA families and easily portable to
other environments (I will try add support for other FPGAs and tools in the
future).

In the last update I included a way to test the firmware in the x86 host,
which helps as lot, since is possible interact with the firmware and fix
quickly some obvious bugs.

Anyway, as main recomendation when working with softcores try never work in
the hardware and in the software at the same time!  Start with the minimum
software configuration possible and freeze the software.  When implementing
new software updates, use the minium hardware configuration possible and
freeze the hardware.

The RV32I specification itself is really impressive and easy to implement
(see [1], page 16).  Of course, there are some drawbacks, such as the funny
little-endian bus (opposed to the network oriented big-endian bus found in
the 680x0 family), but after some empirical tests it is easy to make work.

In the future I will probably release a way to make the *DarkRISCV* work in
big-endian and probably support both endians in a statically way.

Another drawback in the specification is the lacking of delayed branches.
Although i understand that they are bad from the conceptual point of view,
they are good trick in order to extract more performance. As reference, the
lack of delayed branches or branch predictor in the *DarkRISCV* may reduce
between 20 and 30% the performance, in a way that the real measured
performance may be between 1.25 and 1.66 clocks per instruction.

The original 2-stage pipeline design has a small problem concerning the ROM
and RAM timing, in a way that, in order to pre-fetch and execute the
instruction in two clocks and keep the pre-fetch continously working at the
rate of 1 instruction per clock (and the same in the execution), the ROM and
RAM must respond before the next clock. This means that the memories must be
combinational or, at least, use a 2-phase clock.

The first solution for the 2-stage pipeline version with a 2-phase clock is
the default solution and makes the *DarkRISCV* work as a pseudo 4-stage
pipeline:

- 1/2 stage for instruction pre-fetch (rom)
- 1/2 stage for static instruction decode (core)
- 1/2 stage for address generation, register read and data read/write (ram) 
- 1/2 stage for data write (register write)

From the processor point of view, there are only 2 stages and from the
memory point of view, there are also 2 stages. But they are in different
clock phases. In normal conditions, this is not recommended because decreases the
performance by a 2x factor, but in the case of *DarkRISCV* the performance
is always limited by the combinational logic regarding the instruction
execution.

The second solution with a 2-stage pipeline is use combinational logic in
order to provide the needed results before the next clock edge, in a way
that is possible use a single phase clock.  This solution is composed by a
instruction and data caches, in a way that when the operand is stored in a
small LUT-based combinational cache, the processor can perform the memory
operation with no extra wait states.  However, when the operand is not
stored in the cache, extra wait-states are inserted in order to fetch the
operand from a blockram or extenal memory.  According to some preliminary
tests, the instruction cache w/ 64 direct mapped instructions can reach a
hit ratio of 91%.  The data cache performance, although is not so good (with
a hit ratio of only 68%), will be a requirement in order to access external
memory and reduce the impact of slow SDRAMs and FLASHes.

Unfortunately, the instruction and data caches are not working anymore for
the 2-stage pipeline version and only the instruction cache is working in
the 3-stage pipeline.  The problem is probably regarding the HLT signal
and/or a problem regarding the write byte enable in the cache memory.

Both the use of the cache and a 2-phase clock does not perform well.  By
this way, a 3-stage pipeline version is provided, in order to use a single
clock phase with blockrams.

The concept in this case is separate the pre-fetch and decode, in a way that
the pre-fetch can be done entirely in the blockram side for the instruction
bus. The decode, in a different stage, provides extra performance and the 
execute stage works with one clock almost all the time, except when the load
instruction is executed. In this case, the external memory logic inserts one
wait-state. The write operation, however, is executed in a single clock.

The solution with wait-states can be used in the 2-stage pipeline version,
but decreases the performance too much. Case is possible run all versions
with the same, clock, the theorical performance in clocks per instruction
CPI), number of clocks to flush the pipeline in the taken branch (FLUSH) and
memory wait-states (WSMEM) will be:

- 2-stage pipe w/ 2-phase clock: CPI=1, FLUSH=1, WSMEM=0: real CPI=~1.25
- 3-stage pipe w/ 1-phase clock: CPI=1, FLUSH=2, WSMEM=1: real CPI=˜1.66
- 2-stage pipe w/ 1-phase clock: CPI=2, FLUSH=1, WSMEM=1, real CPI=~2.00

Empiracally, the impact of the FLUSH in the 2-stage pipeline is around 20%
and in the 3-stage pipeline is 30%. The real impact depends of the code
itself, of course... In the case of the impact of the wait-states in the
memory access regarding the load instruction, the impact ranges between 5
and 10%, again, depending of the code.

However, the clock in the case of the 3-stage pipeline is far better than the
2-stage pipeline, in special because the better distribuition of the logic
between the decode and execute stages.

Currently, the most expensive path in the Spartan-6 is the address bus
for the data side of the core (connected to RAM and peripherals). The
problem regards to the fact that the following acions must be done in a
single clock:

- generate the DADDR[31:0] = REG[SPTR][31:0]+EXTSIG(IMM[11:0])
- generate the BE[3:0] according to the operand size and DADDR[1:0]

In the case of read operation, the DATAI path includes also a small mux
in order to separate RAM and peripheral buses, as well separate the
diferent peripherals, which means that the path increases as long the
number of peripherals and the complexity increases.

Of course, the best performance setup uses a 3-state pipeline and a
single-clock phase (posedge) in the entire logic, in a way that the 2-stage
pipeline and dual-clock phase will be kept only for reference.  

The only disadvantage of the 3-state pipeline is one extra wait-state in the
load operation and the longer pipeline flush of two clocks in the taken
branches.

Just for reference, I registered some details regarding the performance
measurements:

The current firmware example runs in the 3-stage
pipeline version clocked at 100MHz runs at a verified performance of 62
MIPS.  The theorical 100MIPS performance is not reached 5% due to the extra
wait-state in the load instruction and 32% due to pipeline flushes after
taken branches.  The 2-stage pipeline version, in the other side, runs at a
verified performance of 79MIPS with the same clock.  The only loss regards
to 20% due to pipeline flushes after a taken branch.

Of course, the impact of the pipeline flush depends also from the software
and, as long the software is currently optimized for size. When compiled
with the -O2 instead of -Os, the performance increase to 68MIPS in the
3-state pipeline and the loss changed to 6% for load and 25% for the
pipeline flush. The -O3 option resulted in 67MIPS and the best result was
the -O1 option, which produced 70MIPS in the 3-stage version and 85MIPS in
the 2-stage version.

By this way, case the performance is a requirement, the src/Makefile must be
changed in order to use the -O1 optimization instead of the -Os default. 

And although the 2-stage version is 15% faster than the 3-stage version, the
3-stage version can reach better clocks and, by this way, will provide
better performance.

Regarding the flush, it is required after a taken branch, as long the RISCV
does not supports delayed branches. The solution for this problem is
implement a branch cache (branch predictor), in a way that the core
populates a cache with the last branches and can predict the future
branches. In some inicial tests, the branch prediction with a 4 elements
entry appers to reach a hit ratio of 60%.

Another possibility is use the flush time to other tasks, for example handle
interrupts.  As long the interrupt handling and, in a general way, threading
requires flush the current pipelines in order to change context, by this
way, match the interrupt/threading with the pipeline flush makes some sense!

With the option __INTERRUPT__ is possible test this feature. 

The implementation is in very early stages of development and does not
handle correctly the initial SP and PC.  Anyway, it works and enables the
main() code stop in a gets() while the interrupt handling changes the GPIO
at a rate of more than 1 million interrupts per second without affecting the
execution and with little impact in the performance!  :)

The interrupt support can be expanded to a more complete threading support,
but requires some tricks in the hardware and in the software, in order to 
populate the different threads with the correct SP and PC.

The interrupt handling use a concept around threading and, with some extra
effort, it is probably possible support 4, 8 or event 16 threads.  The
drawback in this case is that the register bank increses in size, which
explain why the rv32e is an interesting option for threading: with half the
number of registers is possible store two more threads in the core.

Currently, the time to switch the context in the *darkricv* is two clocks in
the 3-stage pipeline, which match with the pipeline flush itself. At 100MHz,
the maximum empirical number of context switches per second is around 2.94
million.

NOTE: the interrupt controller is currently working only with the -Os
flag in the gcc!

About the new MAC instruction, it is implemented in a very preliminary way
with the OPCDE 7'b1111111.  I am checking about the possibility to use the
p.mac instruction, but at this time the instruction is hand encoded in the
mac() function available in the stdio.c (i.e.  the darkriscv libc). The
details about include new instructions and make it work with GCC can be
found in the reference [5].

The preliminary tests pointed, as expected, that the performance decreases
to 90MHz and although it was possible run at 100MHz with a non-zero timing
score and reach a peak performance of 100MMAC/s, the small 32-bit
accumulator saturates too fast and requries extra tricks in order to avoid
overflows.

The mul operation uses two 16-bit integers and the result is added with a
separate 32-bit register, which works as accumulator.  As long the operation
is always signed and the signal always use the MSB bit, this means that the
15x15 mul produces a 30 bit result which is added to a 31-bit value, which
means that the overflow is reached after only two MAC operations.

In order to avoid overflows, it is possible shift the input operands.  For
example, in the case of G711 w/ u-law encoding, the effective resolution is
14 bits (13 bits for integer and 1 bit for signal), which means that a 13x13
bit mul will be used and a 26-bit result produced to be added in a 31-bit
integer, enough to run 32xMAC operations before overflow (in this case, when
the ACC reach a negative value):

    # awk 'BEGIN { ACC=2**31-1; A=2**13-1; B=-A; for(i=0;ACC>=0;i++) print i,A,B,A*B,ACC+=A*B }'
    0 8191 -8191 -67092481 2080391166
    1 8191 -8191 -67092481 2013298685
    2 8191 -8191 -67092481 1946206204
    ...
    30 8191 -8191 -67092481 67616736
    31 8191 -8191 -67092481 524255
    32 8191 -8191 -67092481 -66568226

Is this theory correct? I am not sure, but looks good! :)

As complement, I included in the stdio.c the support for the GCC functions
regarding the native *, / and % (mul, div and mod) operations with 32-bit
signed and unsigned integers, which means true 32x32 bit operations
producing 32-bit results.  The code was derived from an old 68000-related
project (as most of code in the stdio.c) and, although is not so faster, I
guess it is working. As long the MAC instruction is better defined in the
syntax and features, I think is possible optimize the mul/div/mod in order
to try use it and increase the performance.

Here some additional performance results (synthesis only, 3-stage 
version) for other Xilinx devices available in the ISE for speed grade 2:

- Spartan-6:	100MHz (measured 70MIPS w/ gcc -O1)
- Artix-7: 	178MHz
- Kintex-7: 	225MHz

For speed grade 3:

- Spartan-6:	117MHz
- Artix-7: 	202MHz
- Kintex-7:	266MHz

The Kintex-7 can reach, theorcally 186MIPS w/ gcc -O1.

For the 2-stage version and speed grade 2, we have less impact from the
pipeline flush (20%), no impact in the load and some impact in the clock due
to the use of a 2-phase clock:

- Spartan-6:    56MHz (measured 47MIPS w/ -O1)

About the compiler performance, from boot until the prompt, tested w/ the
3-stage pipeline core at 100MHz and no interrupts, rom and ram measured in
32-bit words:

- gcc w/ -O3: t=289us rom=876 ram=211
- gcc w/ -O2: t=291us rom=799 ram=211
- gcc w/ -O1: t=324us rom=660 ram=211
- gcc w/ -O0: t=569us rom=886 ram=211
- gcc w/ -Os: t=398us rom=555 ram=211

Due to reduced ROM space in the FPGA, the -Os is the default option.

In another hand, regarding the support for Vivado, it is possible convert
the Artix-7 (Xilinx AC701 available in the ise/boards directory) project to
Vivado and make some interesting tests.  The only problem in the conversion
is that the UCF file is not converted, which means that a new XDC file with
the pin description must be created.

TODO: udpate the performance measurement in the Vivado.

The Vivado is very slow compared to ISE and needs *lots of time* to
synthetize and inform a minimal feedback about the performance...  but after
some weeks waiting, and lots of empirical calculations, I get some numbers
for speed grade 2 devices:

- Artix7: 	147MHz
- Spartan-7:	146MHz

And one number for speed grade 3 devices:

- Kintex-7:	221MHz

Although Vivado is far slow and shows pessimistic numbers for the same FPGAs when 
compared with ISE, I guess Vivado is more realistic and, at least, it supports the
new Spartan-7, which shows very good numbers (almost the same as the Artix-7!).

That values are only for reference.  The real values depends of some options
in the core, such as the number of pipeline stages, who the memories are
connected, etc.  Basically, the best clock is reached by the 3-stage
pipeline version (up to 100MHz in a Spartan-6), but it requires at lease 1
wait state in the load instruction and 2 extra clocks in the taken branches
in order to flush the pipeline.  The 2-state pipeline requires no extra wait
states and only 1 extra clock in the taken branches, but runs with less
performance (56MHz).

## Development Tools (gcc)

About the gcc compiler, I am working with the experimental gcc 9.0.0 for
RISC-V.  No patches or updates are required for the *DarkRISCV* other than
the -march=rv32i.  Although the fence*, e* and crg* instructions are not
implemented, the gcc appears to not use of that instructions and they are
not available in the core.

Although is possible use the compiler set available in the oficial RISC-V
site, our colleagues from *lowRISC* project pointed a more clever way to
build the toolchain:

https://www.lowrisc.org/blog/2017/09/building-upstream-risc-v-gccbinutilsnewlib-the-quick-and-dirty-way/

Basically:

	git clone --depth=1 git://gcc.gnu.org/git/gcc.git gcc
	git clone --depth=1 git://sourceware.org/git/binutils-gdb.git
	git clone --depth=1 git://sourceware.org/git/newlib-cygwin.git
	mkdir combined
	cd combined
	ln -s ../newlib-cygwin/* .
	ln -sf ../binutils-gdb/* .
	ln -sf ../gcc/* .
	mkdir build
	cd build	
	../configure --target=riscv32-unknown-elf --enable-languages=c --disable-shared --disable-threads --disable-multilib --disable-gdb --disable-libssp --with-newlib --with-arch=rv32ima --with-abi=ilp32 --prefix=/usr/local/share/gcc-riscv32-unknown-elf
	make -j4
	make
	make install
	export PATH=$PATH:/usr/local/share/gcc-riscv32-unknown-elf/bin/
	riscv32-unknown-elf-gcc -v

and everything will magically work! (:

Case you have no succcess to build the compiler, have no interest to change
the firmware or is just curious about the darkriscv running in a FPGA, the
project includes the compiled ROM and RAM, in a way that is possible examine
all derived objects, sources and correlated files generated by the compiler
without need compile anything.

Finally, as long the *DarkRISCV* is not yet fully tested, sometimes is a
very good idea compare the code execution with another stable reference!

In this case, I am working with the project *picorv32*:

https://github.com/cliffordwolf/picorv32

When I have some time, I will try create a more well organized support in
order to easily test both the *DarkRISCV* and *picorv32* in the same cache,
memory and IO sub-systems, in order to make possible select the core
according to the desired features, for example, use the *DarkRISCV* for more
performance or *picorv32* for more features.

About the software, the most complex issue is make the memory design match
with the linker layout.  Of course, it is a gcc issue and it is not even a
problem, in fact, is the way that the software guys works when linking the
code and data!

In the most simplified version, directly connected to blockRAMs, the
*DarkRISCV* is a pure harvard architecture processor and will requires the
separation between the instruction and data blocks!

When the cache controller is activated, the cache controller provides
separate memories for instruction and data, but provides a interface for a
more conventional von neumann memory architecture.

In both cases, a proper designed linker script (darksocv.ld) probably solves 
the problem! 

The current memory map in the linker script is the follow:

- 0x00000000: 4KB ROM 
- 0x00001000: 4KB RAM

Also, the linker maps the IO in the following positions:

- 0x80000000: UART status
- 0x80000004: UART xmit/recv buffer
- 0x80000008: LED buffer

The RAM memory contains the .data area, the .bss area (after the .data 
and initialized with zero), the .rodada and the stack area at the end of RAM.

Although the RISCV is defined as little-endian, appears to be easy change
the configuration in the GCC.  In this case, it is supposed that the all
variables are stored in the big-endian format.  Of course, the change
requires a similar change in the core itself, which is not so complex, as
long it affects only the load and store instructions.  In the future, I will
try test a big-endian version of GCC and darkriscv, in order to evaluate
possible performance enhancements in the case of network oriented
applications! :)

Finally, the last update regarding the software included  new option to
build a x86 version in order to help the development by testing exactly the
same firmware in the x86.

## Directory Description

- ise: the ISE project and configuration files (xise, ucf, etc)
- rtl: the source for the core and the test SoC
- sim: the simulation to test the core and the SoC
- src: the source code for the test firmware (hello.c, boot.c, etc)
- tmp: empty, but the ISE will create lots of files here)

The *ise* directory contains the *xise* project file to be open in the
Xilinx ISE 14.x and the project is assembled in a way that all files are
readily loaded.

Although a *ucf* file is provided in order to generate a complete build, the
FPGA is NOT wired in any particular configuration and you must add the pins
regarding your FPGA board!  Anyway, although not wired, the build always
gives you a good estimation about the FPGA utilization and about the timing.

The current supported boards are:

- ise/board/avnet_microboard_lx9
- ise/board/qmtech_sdram_lx16
- ise/board/xilinx_ac701_a200

The organization is self-explained, w/ the vender, board and FPGA model
in the name of the directory. In the future I will probably change the
organization in order to be more agnostic regarding to the tool and change
the "ise" directory to something like "prod" or something like.

The simulation, in the other hand will show some waveforms and is possible
check the *DarkRISCV* operation when running the example code.  

The main simulation tool for *DarkRISCV* is the iSIM from Xilinx ISE 14.7,
but the Icarus simulator is also supported via the Makefile in the *sim*
directory (the changes regarding Icarus are active when the symbol
__ICARUS__ is detected). I also included a workaround for ModelSim, as 
pointed by our friend HYF (the changes regarding ModelSim are active when the 
symbol MODEL_TECH is detected).

The simulation runs the same firmware as in the real FPGA, but in order to
improve the simulation performance, the UART code is not simulated, since
the 115200 bps requires lots dead simulation time.

TODO: more details about the rtl and src directories. Maybe split this
section in "build" and "simulation". The rtl and src can be better explained
in the code itself (as long is possible add lots of comments).

## Development Boards

Currently, therea are two supported boards:

- Avnet Microboard LX9: equipped with a Xilinx Spartan-6 LX9 running at 100MHz
- XilinX AC701 A200: equipped with a Xilinx Artix-7 A200 running at 90MHz (?)
- QMTech SDRAM LX16: equipped with a Xilinx Spartan-6 LX16 running at 50MHz (?)

The speeds are related to available clocks in the boards and different
clocks may be generated by programming a DCM.

Both Avnet and Xilinx boards supports a 115200 bps UART for console, 4xLEDs
for debug and on-chip 4KB ROM and 4KB RAM (as well the RESET button to
restart the core and the DEBUG signals for an oscilloscope).  I received two
Spartan-6 LX16 boards from QMTECH and this board does not includes the JTAG
neither the UART/USB port.  Thanks to an external JTAG adapter and an
external USB/UART converter, the board is now working fine and support all
features from the other boards (UART, LEDs, RESET and DEBUG).  

Support for 100Mbps ethernet in the Microboard LX9 board is under
development, but I am not sure about the 1GbE ethernet in the AC701 A200,
since the card is shared with other developers and must be returned 
shortly.

In the software side, a small shell is available with some basic commands:

- clear: clear display
- dump <val>: dumps an area of the RAM
- led <val>: change the LED register (which turns on/off the LEDs)
- timer <val>: change the timer prescaler, which affects the interrupt rate
- gpio <val>: change the GPIO register (which changes the DEBUG lines)

The proposal of the shell is provide some basic test features which can
provide a go/non-go status about the current hardware status.

Useful memory areas: 

- 4096: the start of RAM (data)
- 4608: the start of RAM (data)
- 5120: empty area
- 5632: empty area
- 6144: empty area
- 6656: empty area
- 7168: empty area
- 7680: the end of RAM (stack)

As long the *DarkRISCV* uses separate instruction and data buses, it is not
possible dump the ROM area. It is obviously that a unified ROM/RAM memory
works better, but it requires a intermediary separated cache in order to
avoid concurrency between the instruction and data buses.

## The Friends of DarkRISCV!

Special thanks to: Paulo Matias (jedi master and verilog guru), Paulo
Bernard (co-worker and verilog guru), Evandro Hauenstein (co-worker and git
guru), Lucas Mendes (technology guru), Marcelo Toledo (technology guru),
Fabiano Silos (technology guru and darkriscv beta tester), Guilherme Barile
(technology guru and first guy to post anything about the darkriscv [2]),
Alasdair Allan (technology guru, posted an article about the darkriscv [3])
and Gareth Halfacree (technology guru, posted an article about the darkriscv
[3].  Special thanks to all people who directly and indirectly contributed
to this project, including the company I work for.

## References

[1] https://www.amazon.com/RISC-V-Reader-Open-Architecture-Atlas/dp/099924910X

[2] https://news.ycombinator.com/item?id=17852876

[3] https://blog.hackster.io/the-rise-of-the-dark-risc-v-ddb49764f392

[4] https://abopen.com/news/darkriscv-an-overnight-bsd-licensed-risc-v-implementation/

[5] http://quasilyte.dev/blog/post/riscv32-custom-instruction-and-its-simulation/
