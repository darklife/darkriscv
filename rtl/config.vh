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

// memory architecture
//
// TODO: fix the different memory architecture concepts:
// status:
// ICACHE: works without interrupt
// DCACHE: does not work!
// WAITSTATE: works
// 
//`define __ICACHE__              // instruction cache
//`define __DCACHE__              // data cache (bug: simulation only)
//`define __WAITSTATES__          // wait-state tests, no cache

// peripheral configuration
//
// UART speed is set in bits per second, typically 115200 bps:

`define __UARTSPEED__ 115200

// darkriscv/darksocv configuration
// 
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

// muti-threading support:
//
// Decreases clock performance by 10% (90MHz), but enables two contexts
// (threads) in the core.  They start in the same code, but the "interrupt"
// handling is locked in a separate loop and the conext switch is always
// delayed until the next pipeline flush, in order to decrease the
// performance impact.  Note: threading is currently supported only in the
// 3-stage pipeline version.

`define __THREADING__

// performance measurement:
//
// The performance measurement can be done in the simulation level by
// eabling the __PERFMETER__ define, in order to check how the clock cycles
// are used in the core.  The value defines how many clocks are computed
// before print the result.

//`define __PERFMETER__ 70000

// mac instruction: 
// 
// The mac instruction is similar to other register to register
// instructions, but with a different opcode 7'h1111111.  the format is mac
// rd,r1,r2, but is not currently possible encode in asm, by this way it is
// available in licb as int mac(int rd, short r1, short r2).  Although it
// can be used to accelerate the mul/div operations, the mac operation is
// designed for DSP applications.  with some effort (low level machine
// code), it is possible peak 100MMAC/s @100MHz.

`define __MAC16X16__

// RV32I vs RV32E:
//
// The difference between the RV32I and RV32E regarding the logic space is 
// minimal in typical applications with modern 5 or 6 input LUT based FPGAs, 
// but the RV32E is better with old 4 input LUT based FPGAs.

`define __RV32E__

// initial PC and SP
//
// it is possible program the initial PC and SP.  Typically, the PC is set
// to address 0, representing the start of ROM memory and the SP is set to
// the final of RAM memory.  In the linker, the start of ROM memory matches
// with the .text area, which is defined in the boot.c code and the start of
// RAM memory matches with the .data and other volatile data, in a way that
// the stack can be positioned in the top of RAM and does not match with the
// .data.

`define __HARVARD__

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
//
// for spartan-7 devices, always use full harvard architecture!

`define __RESETPC__ 32'd0
`define __RESETSP__ 32'd8192

// board definition:
// 
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
        `define BOARD_CK_DIV 2 // 100MHz 
    `else
        `define BOARD_CK_DIV 4 // 50MHz
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
    `define BOARD_CK 50000000
    `define INVRES 1
`endif

`ifdef QMTECH_SPARTAN7_S15
    `define BOARD_ID 4
    `define BOARD_CK_REF 50000000 
    `define BOARD_CK_MUL 20
    `define BOARD_CK_DIV 10
    `define VIVADO 1 
    `define INVRES 1
`endif

`ifdef LATTICE_BREVIA2_XP2
    `define BOARD_ID 5
    `define BOARD_CK 50000000
    `define INVRES 1
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
