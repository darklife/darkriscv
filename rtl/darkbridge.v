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

/*
    output        HLT,
    output [31:0] IADDR,
    input  [31:0] IDATA,
    input         IDACK,
*/

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

    darkram boot0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),
        
        .IADDR  (IADDR),
        .IDATA  (IDATA),
        .IDACK  (IDACK),
        
        .XCS    (XCS[0]),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XADDR  (XADDR),
        .XATAI  (XATAO),
        .XATAO  (XATAI0),
        .XDACK  (XDACK0)
    );
	 
    assign DEBUG = { KDEBUG[3:0] };

endmodule
