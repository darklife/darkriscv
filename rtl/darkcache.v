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

module darkcache
(
    input           CLK,    // clock
    input           RES,    // reset
    input           HLT,

    // darkriscv

    input           DAS,    // address valid
    input           DRD,    // read/write
    input           DWR,    // read/write
    input   [2:0]   DLEN,   // data length in bytes
    input   [31:0]  DADDR,  // address
    input   [31:0]  DATAI,  // data input
    output  [31:0]  DATAO,  // data output
    output          DDACK,  // data ack

    output  [31:0]  DATAP, // pipelined data output
    
    // memory
    
    output          XDREQ,    // address valid
    output          XRD,    // data read
    output          XWR,    // data write
    output [3:0]    XBE,    // byte enable
    output [31:0]   XADDR,  // address
    output [31:0]   XATAO,  // data output
    input  [31:0]   XATAI,  // data input
    input           XDACK,   // data ack

    output  [3:0]   DEBUG   // osciloscope
);

    // cache

    wire [31:0] CDATO;   

`ifdef __CDEPTH__

    reg  [31:`__CDEPTH__+2] CTAG   [0:2**`__CDEPTH__-1];    
    reg  [31:0]             CDATA  [0:2**`__CDEPTH__-1];
    reg                     CVAL   [0:2**`__CDEPTH__-1];
    
    integer i;
    
    initial
    begin
        $display("cache: %0dx32-bits (%0d bytes)",
            (2**`__CDEPTH__),
            4*(2**`__CDEPTH__));
            
        for(i=0;i!=2**`__CDEPTH__;i=i+1) 
        begin            
            CDATA [i] = 0;
            CTAG  [i] = 0;
            CVAL  [i] = 0;
        end
    end

    wire [`__CDEPTH__-1:0]  CINDEX = DADDR[`__CDEPTH__+1:2];

    wire HIT = RES ? 0 : (DRD && CVAL[CINDEX] && CTAG[CINDEX]==DADDR[31:`__CDEPTH__+2]);
    wire CLR = RES ? 0 : (DWR && CVAL[CINDEX] && CTAG[CINDEX]==DADDR[31:`__CDEPTH__+2]);

    wire DTREQ = RES||HIT ? 0 : DADDR[31:30]==0 && DRD;

    reg [31:0] DATAOFF = 0;

    always@(posedge CLK)
    begin
        if(DTREQ && XDACK)
        begin
            CDATA [CINDEX]  <= XATAI;
            CTAG  [CINDEX]  <= DADDR[31:`__CDEPTH__+2];
            CVAL  [CINDEX]  <= 1;
        end
        else
        if(CLR)
        begin
            CVAL  [CINDEX]  <= 0;        
        end
                                
        if(!HLT) DATAOFF <= CDATO;
    end

    assign CDATO  = HIT ? CDATA[CINDEX] : XATAI;        
    assign DATAP  = DATAOFF;

`else

    assign CDATO = XATAI;
    assign HIT   = 0;

`endif

    // convert darkriscv bus to xbus

    assign XDREQ   = HIT ? 0 : DAS;
    assign XRD   = HIT ? 0 : DRD;
    assign XWR   = HIT ? 0 : DWR;

    assign XADDR = HIT ? 0 : DADDR;

    assign XBE   = HIT ? 0 : DLEN[0] ? ( DADDR[1:0]==3 ? 4'b1000 : // 8-bit
                                         DADDR[1:0]==2 ? 4'b0100 :
                                         DADDR[1:0]==1 ? 4'b0010 :
                                                         4'b0001 ) :
                             DLEN[1] ? ( DADDR[1]==1   ? 4'b1100 : // 16-bit
                                                         4'b0011 ) :
                                                         4'b1111;  // 32-bit
    
    assign XATAO = HIT ? 0 : DLEN[0] ? ( DADDR[1:0]==3 ? {        DATAI[ 7: 0], 24'd0 } :
                                         DADDR[1:0]==2 ? {  8'd0, DATAI[ 7: 0], 16'd0 } :
                                         DADDR[1:0]==1 ? { 16'd0, DATAI[ 7: 0],  8'd0 } :
                                                         { 24'd0, DATAI[ 7: 0]        } ):
                             DLEN[1] ? ( DADDR[1]==1   ? { DATAI[15: 0], 16'd0 } :
                                                         { 16'd0, DATAI[15: 0] } ):
                                                                  DATAI;

    assign DATAO = DLEN[0] ? ( DADDR[1:0]==3 ? CDATO[31:24] :
                               DADDR[1:0]==2 ? CDATO[23:16] :
                               DADDR[1:0]==1 ? CDATO[15: 8] :
                                               CDATO[ 7: 0] ):
                   DLEN[1] ? ( DADDR[1]==1   ? CDATO[31:16] :
                                               CDATO[15: 0] ):
                                               CDATO;

    assign DDACK = HIT ? 1 : XDACK;

    assign DEBUG = { DAS, HIT, XDREQ, XDACK };

endmodule
