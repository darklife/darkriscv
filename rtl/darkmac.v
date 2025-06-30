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

// proprietary extension (custom-0)
//`define CUS     7'b00010_11      // cus   rd,rs1,rs2,fc3,fct5

// configuration file

`include "../rtl/config.vh"

module darkmac
(
    input             CLK,   // clock
    input             RES,   // reset
    input             HLT,   // halt

    input             CPR_REQ,      // CPR instr request
    input      [ 2:0] CPR_FCT3,     // fct3 field
    input      [ 6:0] CPR_FCT7,     // fct7 field
    input      [31:0] CPR_RS1,      // operand RS1
    input      [31:0] CPR_RS2,      // operand RS2
    input      [31:0] CPR_RDR,      // operand RD (read)
    output     [31:0] CPR_RDW,      // operand RD (write)
    output            CPR_ACK,      // CPR instr ack (unused)

    output [3:0]  DEBUG       // old-school osciloscope based debug! :)
);

    // MAC instruction template w/ RV32 ABI
    // 
    // based on xor and add:
    // 
    // 0000000 01100 01011 100 01100 0110011 xor a2,a1,a2
    // 0000000 01010 01100 000 01010 0110011 add a0,a2,a0
    // 0000000 01100 01011 000 01010 0001011 mac a0,a1,a2 
    // 
    // aka: int mac(int a0,int a1, int a2);
    //
    // to hex code:
    // 
    // 0000 0000 1100 0101 1000 0101 0000 1011 => 0x00c5850b

    wire signed [15:0] K1TMP = CPR_RS1[15:0];

    wire signed [15:0] K2TMP = CPR_RS2[15:0];

    wire signed [31:0] KDATA = K1TMP*K2TMP;

    assign CPR_RDW = CPR_RDR + KDATA;

    assign CPR_ACK = CPR_REQ; // fully combinational

    assign DEBUG = 0;

endmodule
