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

module darkbridge
(
    input         CLK,      // clock
    input         RES,      // reset

    output        XWR,
    output        XRD,
    output [3:0]  XBE,
    output [3:0]  XCS,   
    output [31:0] XADDR,
    output [31:0] XATAO,
    input  [31:0] XATAI,
    input         XDACK,
    input         XIRQ,

`ifdef SIMULATION
    input       ESIMREQ,
    output      ESIMACK,
`endif
    output [3:0] DEBUG      // osciloscope
);

    // darkriscv bus interface

    wire        HLT;
    
    wire [31:0] IADDR;
    wire [31:0] IDATA;
    wire        IDACK;
    
    wire [31:0] DADDR;
    wire [31:0] DATAO;
    wire [31:0] DATAI;
    wire [ 2:0] DLEN;
    wire        DRW;
    wire        DDACK;

    // address map
    
    assign XCS[0] = DLEN && DADDR[31:30]==0;
    assign XCS[1] = DLEN && DADDR[31:30]==1;
    assign XCS[2] = DLEN && DADDR[31:30]==2;
    assign XCS[3] = DLEN && DADDR[31:30]==3;
    
    assign HLT = XCS[0] ? XDACK0 : XCS[3:1] ? XDACK : IDACK;

    // darkriscv

    wire [3:0]  KDEBUG;
    
    darkriscv
    #(
        .CPTR(0)
    )
    core0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

`ifdef __INTERRUPT__
        .IRQ    (XIRQ),
`endif

        .IDATA  (IDATA),
        .IADDR  (IADDR),
        .DADDR  (DADDR),

        .DATAI  (DATAI),
        .DATAO  (DATAO),
        .DLEN   (DLEN),
        .DRW    (DRW),

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

        .DEBUG  (KDEBUG)
    );

    // darkriscv to soc

    assign XATAO = DLEN[0] ? ( DADDR[1:0]==3 ? {        DATAO[ 7: 0], 24'd0 } :
                               DADDR[1:0]==2 ? {  8'd0, DATAO[ 7: 0], 16'd0 } :
                               DADDR[1:0]==1 ? { 16'd0, DATAO[ 7: 0],  8'd0 } :
                                               { 24'd0, DATAO[ 7: 0]        } ):
                   DLEN[1] ? ( DADDR[1]==1   ? { DATAO[15: 0], 16'd0 } :
                                               { 16'd0, DATAO[15: 0] } ):
                                                 DATAO;

    assign XRD = DLEN&&DRW==1;
    assign XWR = DLEN&&DRW==0;

    assign XBE =    DLEN[0] ? ( DADDR[1:0]==3 ? 4'b1000 : // 8-bit
                                DADDR[1:0]==2 ? 4'b0100 :
                                DADDR[1:0]==1 ? 4'b0010 :
                                                4'b0001 ) :
                    DLEN[1] ? ( DADDR[1]==1   ? 4'b1100 : // 16-bit
                                                4'b0011 ) :
                                                4'b1111;  // 32-bit

    assign XADDR = DADDR;

    // soc to darkriscv, always 1 clk late

    wire [31:0] XATAI0;
    wire        XDACK0;

    reg [1:0] DADDR2 = 0;
    reg       XCS0FF  = 0;
    
    always@(posedge CLK) DADDR2 <= DADDR[1:0];
    always@(posedge CLK) XCS0FF <= XCS[0];

    wire [31:0] XXATAI = XCS0FF ? XATAI0 : XATAI;

    assign DATAI = DLEN[0] ? ( DADDR2[1:0]==3 ? XXATAI[31:24] :
                               DADDR2[1:0]==2 ? XXATAI[23:16] :
                               DADDR2[1:0]==1 ? XXATAI[15: 8] :
                                                XXATAI[ 7: 0] ):
                   DLEN[1] ? ( DADDR2[1]==1   ? XXATAI[31:16] :
                                                XXATAI[15: 0] ):
                                                XXATAI;
    
    assign DDACK = XCS0FF ? DLEN && XDACK0 : DLEN && XDACK;

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

    wire IHIT = !ITACK;

    always@(posedge CLK)
    begin
        ITACK <= RES ? 0 : ITACK ? ITACK-1 : 0;
        
        if(HLT^HLT2)
        begin
            ROMFF2 <= ROMFF;
        end

        HLT2 <= HLT;

        ROMFF <= MEM[IADDR[`MLEN-1:2]];
        // if(!RES && !HLT) $display("bram: addr=%x inst=%x\n",IADDR,ROMFF);
    end

    assign IDATA = HLT2 ? ROMFF2 : ROMFF;
    assign IDACK = !IHIT;

    // data memory

    reg [1:0] DTACK  = 0;
    reg [31:0] RAMFF = 0; 

    wire DHIT = !((XRD
            `ifdef __RMW_CYCLE__
                    ||XWR		// worst code ever! but it is 3:12am...
            `endif
                    ) && DTACK!=1); // the XWR operatio does not need ws. in this config.

    always@(posedge CLK) // stage #1.0
    begin
        DTACK <= RES ? 0 : DTACK ? DTACK-1 : (XRD
            `ifdef __RMW_CYCLE__
                    ||XWR		// 2nd worst code ever!
            `endif
                    ) ? 1 : 0; // wait-states

        RAMFF <= MEM[XADDR[`MLEN-1:2]];

        //individual byte/word/long selection, thanks to HYF!

`ifdef __RMW_CYCLE__

        // read-modify-write operation w/ 1 wait-state:

        if(!HLT && XWR && XCS[0])
        begin
            MEM[XADDR[`MLEN-1:2]] <=
                                {
                                    XBE[3] ? XATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8],
                                    XBE[2] ? XATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8],
                                    XBE[1] ? XATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8],
                                    XBE[0] ? XATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8]
                                };
        end

`else

    // write-only operation w/ 0 wait-states:

        if(!HLT && XWR && XCS[0] && XBE[3]) MEM[XADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= XATAO[3 * 8 + 7: 3 * 8];
        if(!HLT && XWR && XCS[0] && XBE[2]) MEM[XADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= XATAO[2 * 8 + 7: 2 * 8];
        if(!HLT && XWR && XCS[0] && XBE[1]) MEM[XADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= XATAO[1 * 8 + 7: 1 * 8];
        if(!HLT && XWR && XCS[0] && XBE[0]) MEM[XADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= XATAO[0 * 8 + 7: 0 * 8];
`endif
    end

    assign XATAI0 = RAMFF;
    assign XDACK0 = !DHIT;
	 
    assign DEBUG = { KDEBUG[3:0] };

endmodule
