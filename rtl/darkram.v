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
`include "../rtl/config.vh"

module darkram
(
    input           CLK,    // clock
    input           RES,    // reset
    input           HLT,    // halt
    
    input  [31:0]   IADDR,
    output [31:0]   IDATA,
    output          IDACK,

    input           XCS,
    input           XRD,
    input           XWR,
    input  [3:0]    XBE,
    input  [31:0]   XADDR,
    input  [31:0]   XATAI,
    output [31:0]   XATAO,
    output          XDACK,
    
    output [3:0]    DEBUG
);

    // ro/rw memories

    reg [31:0] MEM [0:2**`MLEN/4-1]; // ro memory

    // memory initialization

    integer i;
    initial
    begin
    `ifdef SIMULATION
        $display("bram: unified BRAM w/ %dx32-bit...",2**`MLEN/4);
        for(i=0;i!=2**`MLEN/4;i=i+1)
        begin
            MEM[i] = 32'd0;
        end
    `endif

     // workaround for vivado: no path in simulation and .mem extension

    `ifdef XILINX_SIMULATOR
        $readmemh("darksocv.mem",MEM);
	`elsif MODEL_TECH
	    $readmemh("../../../../src/darksocv.mem",MEM);
    `else
        $readmemh("../src/darksocv.mem",MEM,0);
    `endif
    end

    // instruction memory

    reg [1:0]  ITACK  = 0;
    reg [31:0] ROMFF  = 0;
    reg [31:0] ROMFF2 = 0;
    reg        HLT2   = 0;

    always@(posedge CLK)
    begin
        ITACK <= RES ? 0 : ITACK ? ITACK-1 : 0; // i-bus wait-state
        
        if(HLT^HLT2)
        begin
            ROMFF2 <= ROMFF;
        end

        HLT2 <= HLT;

        ROMFF <= MEM[IADDR[`MLEN-1:2]];
        // if(!RES && !HLT) $display("bram: addr=%x inst=%x\n",IADDR,ROMFF);
    end

    assign IDATA = HLT2 ? ROMFF2 : ROMFF;
    assign IDACK = 1; // ITACK==1;

    // data memory

    reg [1:0] DTACK  = 0;
    reg [31:0] RAMFF = 0; 

    always@(posedge CLK) // stage #1.0
    begin
        DTACK <= RES ? 0 : DTACK ? DTACK-1 : XCS && (XRD
            `ifdef __RMW_CYCLE__
                    ||XWR		// 2nd worst code ever!
            `endif
                    ) ? 1 : 0; // wait-states

        RAMFF <= MEM[XADDR[`MLEN-1:2]];

        //individual byte/word/long selection, thanks to HYF!

`ifdef __RMW_CYCLE__

        // read-modify-write operation w/ 1 wait-state:

        if(!HLT && XWR && XCS)
        begin
            MEM[XADDR[`MLEN-1:2]] <=
                                {
                                    XBE[3] ? XATAI[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8],
                                    XBE[2] ? XATAI[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8],
                                    XBE[1] ? XATAI[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8],
                                    XBE[0] ? XATAI[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8]
                                };
        end

`else

    // write-only operation w/ 0 wait-states:

        if(!HLT && XWR && XCS && XBE[3]) MEM[XADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= XATAI[3 * 8 + 7: 3 * 8];
        if(!HLT && XWR && XCS && XBE[2]) MEM[XADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= XATAI[2 * 8 + 7: 2 * 8];
        if(!HLT && XWR && XCS && XBE[1]) MEM[XADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= XATAI[1 * 8 + 7: 1 * 8];
        if(!HLT && XWR && XCS && XBE[0]) MEM[XADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= XATAI[0 * 8 + 7: 0 * 8];
`endif
    end

    assign XATAO = RAMFF;
`ifndef __RMW_CYCLE__
    assign XDACK = DTACK==1||(XWR&&XCS);
`else
    assign XDACK = DTACK==1;
`endif
	 
    assign DEBUG = { XCS,XRD,XWR,XDACK };

endmodule
