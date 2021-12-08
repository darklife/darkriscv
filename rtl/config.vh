/*
 * Copyright (c) 2018, Marcelo Samsoniuk
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

`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// darkriscv configuration
////////////////////////////////////////////////////////////////////////////////
 
// pipeline stages:
// 
// 2-stage version: core and memory in different clock edges result in less
// clock performance, but less losses when the program counter changes
// (pipeline flush = 1 clock).  Works like a 4-stage pipeline and remember
// the 68040 clock scheme, with instruction per clock = 1.  alternatively,
// it is possible work w/ 1 wait-state and 1 clock edge, but with a penalty
// in performance (instruction per clock = 0.5).
// 
// 3-stage version: core and memory in the same clock edge require one extra
// stage in the pipeline, but keep a good performance most of time
// (instruction per clock = 1).  of course, read operations require 1
// wait-state, which means sometimes the read performance is reduced.
`define __3STAGE__

// RV32I vs RV32E:
//
// The difference between the RV32I and RV32E regarding the logic space is 
// minimal in typical applications with modern 5 or 6 input LUT based FPGAs, 
// but the RV32E is better with old 4 input LUT based FPGAs.
`define __RV32E__

// muti-threading support:
//
// Decreases clock performance by 20% (80MHz), but enables two or more 
// contexts (threads) in the core. The threads work in symmetrical way, 
// which means that they will start with the same exactly core parameters 
// (same initial PC, same initial SP, etc). The boot.s code is designed 
// to handle this difference and set each thread to different 
// applications.
// Notes: 
// a) threading is currently supported only in the 3-stage pipeline version.
// b) the old experimental "interrupt mode" was removed, which means that
//    the multi-thread mode does not make anything "visible" other than
//    increment the gpio register.
// c) the threading in the non-interrupt mode switches when the program flow
//    changes, i.e. every jal instruction. When the core is idle, it is 
//    probably in a jal loop.
// The number of threads must be 2**n (i.e. THREADS = 3 means 8 threads)
//`define __THREADS__ 3
//
// mac instruction: 
// 
// The mac instruction is similar to other register to register
// instructions, but with a different opcode 7'h1111111.  the format is mac
// rd,r1,r2, but is not currently possible encode in asm, by this way it is
// available in licb as int mac(int rd, short r1, short r2).  Although it
// can be used to accelerate the mul/div operations, the mac operation is
// designed for DSP applications.  with some effort (low level machine
// code), it is possible peak 100MMAC/s @100MHz.
//`define __MAC16X16__

// flexbuzz interface (experimental):
//
// A new data bus interface similar to a well known c*ldfire bus interface, in 
// a way that part of the bus routing is moved to the core, in a way that 
// is possible support different bus widths (8, 16 or 32 bit) and endians more 
// easily (the new interface is natively big-endian, but the endian can be adjusted
// in the bus interface dinamically). Similarly to the standard 32-bit interface, 
// the external logic must detect the RD/WR operation quick enough and assert HLT 
// in order to insert wait-states and perform the required multiplexing to fit 
// the DLEN operand size in the data bus width available.
//`define __FLEXBUZZ__

// interrupt support
// 
// The interrupt support in the core uses the machine registers mtvec and 
// mepc, which means support the control special register instruction csrrw,
// in a way that is possible read/write the mtvec and mepc.
// the interrupt itself works like the thread switch, with the difference
// that:
// a) the PC will be saved in the mepc register
// b)the PC will receive the mtvec value
// c) single interrupt, which means that the mtvec offset is always zero
// The interrupt support cannot be used with threading (because makes no 
// much sense?)... also, it requires the 3 stage pipeline (again, makes no
// much sense use it with the 2-stage pipeline).
`define __INTERRUPT__

// initial PC and SP
//
// it is possible program the initial PC and SP.  Typically, the PC is set
// to address 0, representing the start of ROM memory and the SP is set to
// the final of RAM memory.  In the linker, the start of ROM memory matches
// with the .text area, which is defined in the boot.c code and the start of
// RAM memory matches with the .data and other volatile data, in a way that
// the stack can be positioned in the top of RAM and does not match with the
// .data.
`define __RESETPC__ 32'd0
`define __RESETSP__ 32'd8192

////////////////////////////////////////////////////////////////////////////////
// darksocv configuration:
////////////////////////////////////////////////////////////////////////////////

// interactive simulation:
// 
// When enabled, will trick the simulator in order to enable interactive
// access via the stdin, in a way that is possible type interactive commands,
// which will make your simulator crazy! unfortunately, it works only with
// iverilog... at least, Xilinx ISIM does not liket the $fgetc()
//`define __INTERACTIVE__

// performance measurement:
//
// The performance measurement can be done in the simulation level by
// eabling the __PERFMETER__ define, in order to check how the clock cycles
// are used in the core. The report is displayed when the FINISH_REQ signal
// is actived by the UART.
`define __PERFMETER__

// full harvard architecture:
// 
// When defined, enforses that the instruction and data buses are connected
// to fully separate memory banks.  Although the darkriscv always use
// harvard architecture in the core, with separate instruction and data
// buses, the logic levels outside the core can use different architectures
// and concepts, including von neumann, wich a single bus shared by
// instruction and data access, as well a mix between harvard and von
// neumann, which is possible in the case of dual-port blockrams, where is
// possible connect two separate buses in a single memory bank.  the main
// advantage of a single memory bank is that the .text and .data areas can
// be better allocated, but in this case is not possible protect the .text
// area as in the case of separate memory banks.
//`define __HARVARD__

// read-modify-write cycle:
//
// Generate RMW cycles when writing in the memory. This option basically 
// makes the read and write cycle symmetric and may work better in the cases
// when the 32-bit memory does not support separate write enables for 
// separate 16-bit and 8-bit words. Typically, the RMW cycle results in a
// decrease of 5% in the performance (not the clock, but the instruction
// pipeline eficiency) due to memory wait-states.
//`define __RMW_CYCLE__

// instruction wait-states:
// 
// option to add wait-states in order to use the 2-stage pipeline AND a 
// single phase clock... decrease the IPC, but increases the clock from 50 to 80MHz! 
// maybe, in the future, can use associated to a large 64 or 128 bit burst based 
// bus in order to get a quick 2-stage pipeline w/ an efficient instruction bus.
// do not forget to see the cache options below!
//`define __WAITSTATES__

// instruction and data caches:
// 
// the option for instruction and data caches were developed for 2-stage 
// version and, of course, is part of the original effort to make the core
// more efficient when the wait-states are enabled.
//`define __ICACHE__ // not working, must debug it! :(
//`define __DCACHE__ // not working, must debug it! :(

// UART speed is set in bits per second, typically 115200 bps:
//`define __UARTSPEED__ 115200

// UART queue: 
// 
// Optional RX/TX queue for communication oriented applications. The concept
// foreseen 256 bytes for TX and RX, in a way that frames up to 128 bytes can
// be easily exchanged via UART.
//`define __UARTQUEUE__

////////////////////////////////////////////////////////////////////////////////
// board definition:
////////////////////////////////////////////////////////////////////////////////
 
// The board is automatically defined in the xst/xise files via Makefile or
// ISE. Case it is not the case, please define you board name here:
//`define AVNET_MICROBOARD_LX9
//`define XILINX_AC701_A200
//`define QMTECH_SDRAM_LX16

// the following defines are automatically defined:

`ifdef __ICARUS__
    `define SIMULATION 1
`endif

`ifdef XILINX_ISIM
    `define SIMULATION 2
`endif

`ifdef MODEL_TECH
    `define SIMULATION 3
`endif

`ifdef XILINX_SIMULATOR
    `define SIMULATION 4
`endif

`ifdef AVNET_MICROBOARD_LX9
    `define BOARD_ID 1
    //`define BOARD_CK 100000000
    //`define BOARD_CK 66666666
    //`define BOARD_CK 40000000
    // example of DCM logic:
    `define BOARD_CK_REF 100000000
    `define BOARD_CK_MUL 2
    `ifdef __3STAGE__
        `define BOARD_CK_DIV 2 // 3-stage, 0-ws, 100MHz
    `elsif __WAITSTATES__
        `define BOARD_CK_DIV 2 // 2-stage, 1-ws, 100MHz
    `else
        `define BOARD_CK_DIV 4 // 2-stage, 0-ws, 50MHz
    `endif
`endif

`ifdef XILINX_AC701_A200
    `define BOARD_ID 2
    //`define BOARD_CK 90000000
    `define BOARD_CK_REF 90000000 
    `define BOARD_CK_MUL 4
    `define BOARD_CK_DIV 2
`endif

`ifdef QMTECH_SDRAM_LX16
    `define BOARD_ID 3
    `define BOARD_CK_REF 50000000
    `define BOARD_CK_MUL 4
    `define BOARD_CK_DIV 2
    `define INVRES 1
`endif

`ifdef QMTECH_SPARTAN7_S15
    `define BOARD_ID 4
    `define BOARD_CK_REF 50000000 
    `define BOARD_CK_MUL 20
    `define BOARD_CK_DIV 10
    `define XILINX7CLK 1
    `define VIVADO 1 
    `define INVRES 1
`endif

`ifdef LATTICE_BREVIA2_XP2
    `define BOARD_ID 5
    `define BOARD_CK 50000000
    `define INVRES 1
`endif

`ifdef PISWORDS_RS485_LX9
    `define BOARD_ID 6
    `define BOARD_CK_REF 50000000
    `define BOARD_CK_MUL 4
    `define BOARD_CK_DIV 2
    `define INVRES 1
`endif

`ifdef DIGILENT_SPARTAN3_S200
    `define BOARD_ID 7
    `define BOARD_CK 50000000
    `define __RMW_CYCLE__
`endif

`ifdef ALIEXPRESS_HPC40GBE_K420
    `define BOARD_ID 8
    //`define BOARD_CK 200000000
    `define BOARD_CK_REF 100000000
    `define BOARD_CK_MUL 12
    `define BOARD_CK_DIV 5
    `define XILINX7CLK 1
    `define INVRES 1    
`endif

`ifdef QMTECH_ARTIX7_A35
    `define BOARD_ID 9
    `define BOARD_CK_REF 50000000 
    `define BOARD_CK_MUL 20
    `define BOARD_CK_DIV 10
    `define XILINX7CLK 1
    `define VIVADO 1 
    `define INVRES 1
`endif

`ifdef ALIEXPRESS_HPC40GBE_XKCU040
    `define BOARD_ID 10
    //`define BOARD_CK 200000000
    `define BOARD_CK_REF 100000000
    `define BOARD_CK_MUL 8  // x8/2 = 400MHZ (overclock!)
    `define BOARD_CK_DIV 2  // vivado reco. = 250MHz
    `define XILINX7CLK 1
    `define INVRES 1
`endif

`ifdef PAPILIO_DUO_LOGICSTART
    `define BOARD_ID 11
    `define BOARD_CK_REF 32000000
    `define BOARD_CK_MUL 2
    `define BOARD_CK_DIV 2
`endif

`ifndef BOARD_ID
    `define BOARD_ID 0    
    `define BOARD_CK 100000000
`endif
    
`ifdef BOARD_CK_REF
    `define BOARD_CK (`BOARD_CK_REF * `BOARD_CK_MUL / `BOARD_CK_DIV)
`endif

// darkuart baudrate automtically calculated according to board clock:

`ifndef __UARTSPEED__ 
  `define __UARTSPEED__ 115200
`endif

`define  __BAUD__ ((`BOARD_CK/`__UARTSPEED__))
