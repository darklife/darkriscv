# DarkRISCV
Opensource RISC-V implemented from scratch in one night!

## Introduction

Developed in a magic night of 19 Aug, 2018 between 2am and 8am, the
*darkriscv* is a very experimental implementation of the opensource RISC-V
instruction set. Nowadays, after one week of exciting sleepless nights of 
work (which explains the lots of typos you will found ahead), the *darkriscv* 
reached a very good quality result, in a way that the "hello world" compiled 
by the standard riscv-elf-gcc is working fine! :)

The general concept is based in my other early RISC processors and composed 
by a simplified two stage pipeline where a instruction is fetch from a
instruction memory in the first clock and then decoded/executed in the second
clock. The pipeline is overlapped without interlocks, in a way the
*darkriscv* can reach the performance of one clock per instruction most 
of time (the exception is after a branch, where the pipeline is flushed and 
one clock is lost).  As addition, the code is very compact, with around two 
hundred lines of obfuscated but beautiful Verilog code.

Although the code is small and crude when compared with other RISC-V implementations, 
the *darkriscv* has lots of impressive features:

- implements most of the RISC-V RV32I instruction set
- works up to 75MHz and sustain 1 clock per instruction most of time
- flexible harvard architecture (easy to integrate a cache controller)
- works fine in a real spartan-6 lx9 after one week of development
- works fine with gcc 9.0.0 for RISC-V (no patches required!)
- uses only around 1000 LUTs (spartan-6, core only)
- and the best feature: BSD license

Feel free to make suggestions and good hacking! o/

## Implementation Notes

Since my target is the ultra-low-cost Xilinx Spartan-6 family of FPGAs, the
project is currently based in the Xilinx ISE 14.4 for Linux.  However, no
explicit references for Xilinx elements are done and all logic is inferred
directly from Verilog, which means that the project is easily portable to
other FPGA families and easily portable to other environments.

The main motivation for the *darkriscv* is create a migration path for 
some projects around the 680x0/coldfire family. My first approach was check
around for some softcores and, after lots of tests, I found the *picorv32* 
and the all the ecosystem around the RISC-V. Although a very good option 
to directly replace the 680x0 family, the *picorv32* may be not powerful
enough to replace some coldfire processors.

The main problem around the *picorv32* is that most instructions requires 
3 or 4 clocks per instruction, which resembles the 68020 in some ways, but 
running at 150MHz. Anyway, with 3 clocks per instruction, the peak 
performance is around 50MIPS only. As long I had some good experience with
experimental RISC cores, I started code the *darkriscv* only to check the
level of complexity. For my surprise, in the first night I mapped almost all
instructions of the RV32I specification and the *darkriscv* started to 
execute the first instructions correctly at 75MHz and with one clock 
per instruction, which resembles a fast and nice 68040! wow! :)

The RV32I specification itself is really impressive and easy 
to implement (see [1], page 16). Of course, there are some drawbacks, such 
as the funny little-endian bus (opposed to the network oriented big-endian 
bus found  in the 680x0 family), but after some empirical tests it is easy 
to make work.

The initial design was very simple, with a 2-stage pipeline composed by 
the instruction pre-fetch and the instruction execution. In the pre-fetch
side, there is program counter always working one clock ahead. In the 
execution side we found all decoding, register bank read, arithmetic and
logic operations, register bank write and IO operations. As long the 2 stages 
overlap, the result is a continuous flow of instructions at the 
rate of 1 clock per instruction and around 75MIPS.

This means that when comparing with the *picorv32* running at 150MHz and
with 3 clocks per instruction, the *darkriscv* at 75MHz and 1 clock per
instruction is 50% faster.

Unfortunately, I had a small problem with the load instruction: the 1 stage
execution needs faster external memory! This is not a problem for my early RISC
processors, which used small and faster LUT-based memories, but in the case
of *darkriscv* the proposal was a more flexible design, in a way is possible
use blockRAM-based caches and slow external memories. The problem with the 
blockRAM is that two clocks are required to readback the memory: one clock 
to register the address and another to register the data. External memories
requires lots of clocks.

My first solution was use two different clock edges: one edge for the *darkriscv* 
and another edge for the memory/bus interface.

In this case the processor with a 2-stage pipeline works like a 2\*0.5+1-stage pipeline:

- 1/2 stage for instruction pre-fetch
- 1/2 stage for static instruction decode
- 1 stage for instruction execution

In the special case of load/store instructions, the last stage is divided in 
two different stages, working as a 4\*0.5-stage pipeline:

- 1/2 stage for instruction pre-fetch
- 1/2 stage for static instruction decode
- 1/2 stage for execution and address generation
- 1/2 stage for data read/write

In normal conditions, this is not recommended because decreases the performance
by a 2x factor, but in the case of *darkriscv* the performance is always limited
by the combinational logic regarding the instruction execution. 

As reference, here some additional performance results (synthesis only) for 
other Xilinx devices available in the ISE:

- Spartan-3e:	47MHz
- Spartan-6: 	75MHz
- Artix-7: 	133MHz
- Virtex-6: 	137MHz
- Kintex-7: 	167MHz

Although is possible use the *darkriscv* directly connected to at least two
blockRAM memories (one for instruction and another for data) working in the opposite
clock edge and and deterministically keep a very good performance of 1 clock per
instruction most of time at 75MHz, the most useful configuration is use a cache 
controller. In this case, is possible use large multi-megabyte memories with lots 
of wait-states and, at same time, reach a peak performance of 1 clock per instruction 
when the instructions and data are already cached. Of course, the cache controller 
impact the performance, reducing the clock from 75MHz to 50MHz and inserting lots of
wait-states in the cache filling cycles.

Well, in order to bypass this performance limitation, the most logic step is 
increase the number of states. In this case, the *darkriscv* have the option to 
work with a real 3-stage pipeline:

- 1st stage: instruction pre-fetch (no operation other than cache)
- 2nd stage: instruction decode (no register or memory read here!)
- 3rd stage: instruction execution (register/memory read/write)

Of course, this is not solution for the load/store problem... the probably solution
is increase the pipeline to 4-stages, spliting the 3rd. stage in a read/write
stage. Although possible, this step adds some confusion, as long requires 
additional logic in order to interlock the pipeline when one instruction in the
3.rd stage uses a result from another instruction in the 4.th stage. However, with 
the cache controller, the 3-stage pipeline works pretty well and I guess is
possible add some fixes in the future in order to make it more flexible.

In fact, when running the "hello world" code we have the following results:

- darkriscv@75MHz -cache -wait-states 2-stage pipeline 2-phase clock:  6.40us
- darkriscv@75MHz +cache +wait-states 3-stage pipeline 1-phase clock:  9.37us
- darkriscv@50MHz +cache +wait-states 2-stage pipeline 2-phase clock: 13.84us

Although the first configuration reaches the best performance, the second 
configuration is probably the most realistic at this time!

## Development Tools (gcc)

About the gcc compiler, I am working with the experimental gcc 9.0.0 for 
RISC-V. No patches or updates are required for the *darkriscv* other than the 
-march=rv32i. Although the fence* and crg* instructions are not implemented, the gcc
appears to not use of that instructions and they are not available in the core.  

Although is possible use the compiler set available in the oficial RISC-V site, 
our colleagues from *lowRISC* project pointed a more clever way to build the toolchain:

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

Finally, as long the *darkriscv* is not yet fully tested, sometimes is a
very good idea compare the code execution with another stable reference!

In this case, I am working with the project *picorv32*:

https://github.com/cliffordwolf/picorv32

When I have some time, I will try create a more well organized support in order 
to easily test both the *darkriscv* and *picorv32* in the same cache, memory
and IO sub-systems, in order to make possible select the core according to the
desired features, for example, use the *darkriscv* for more performance or *picorv32* 
for more features.

About the software, the most complex issue is make the memory design match 
with the linker layout. Of course, it is a gcc issue and it is not even a problem, 
in fact, is the way that the software guys works when linking the code and data! 

In the most simplified version, directly connected to blockRAMs, the 
*darkriscv* is a pure harvard architecture processor and will requires the 
separation between the instruction and data blocks!

When the cache controller is activated, the cache controller provides separate
memories for instruction and data, but provides a interface for a more 
conventional von neumann memory architecture.

In both cases, a proper designed linker script probably solves the problem!

## Directory Description

- ise: the ISE project and configuration files (xise, ucf, etc)
- rtl: the source for the core and the test SoC
- sim: the simulation to test the core and the SoC
- src: the source code for the test firmware (hello.c, boot.c, etc)
- tmp: empty, but the ISE will create lots of files here)

The *ise* directory contains the *xise* project file to be open in the Xilinx
ISE 14.x and the project is assembled in a way that all files are readily loaded. 

Although a *ucf* file is provided in order to generate a complete build, the 
FPGA is NOT wired in any particular configuration and you must add the pins
regarding your FPGA board! Anyway, although not wired, the build always gives 
you a good  estimation about the FPGA utilization and about the timing.

The simulation, in the other hand will show some waveforms and is possible 
check the *darkriscv* operation when running the example code. The hello.c code 
prints the string "hello world!" in console and also in the UART register 
located in the SoC. In the future I will provide a real UART logic in order
to test the *darkriscv* in a real FPGA.

## DarkSoC and Future Work

At the moment, the *darksocv* is not so relevant and the only function is
provide support for the cache controller as well some basic glue-logic. The proposal 
in the future is make possible connect the *darkriscv* to large external
memories, as well make possible connect multiple *darkriscv* cores in a 
SMP configuration and maybe provide Ethernet communication.

Another possible update for the future is integrate the cache controller in 
the core, in a way is possible a better flow control. Currently, the only
interface between the core and the cache controller is the sinal HLT, which
is the same signal for instruction and data. I guess the update from a 2/3-stage 
pipeline to a 4-stage pipeline without interlock of the pipeline is possible with a
forward scheme, but I am not sure yet how implement this.

A good update, for sure, can be replace the current LUT-based cache by a 
blockRAM-based cache, but I am not sure is so easy (I will investigate it!).

Again: feel free to make suggestions and good hacking! o/

References:

[1] https://www.amazon.com/RISC-V-Reader-Open-Architecture-Atlas/dp/099924910X
