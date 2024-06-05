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

    input           RW,     // read/write
    input   [2:0]   DLEN,   // data length in bytes

    input   [31:0]  ADDR,   // address
    input   [31:0]  DATA,   // data input  on RW=0
    output  [31:0]  DATO,   // data output on RW=1
    
    output          HIT,    // cache hit
    output          DTREQ,  // cache miss, data transfer req
    input           DTACK,  // cache miss, data transfer ack
    
    output  [3:0]   DEBUG   // osciloscope
);

    reg  [31:0] CDATA [0:63];
    reg  [31:8] CTAG  [0:63];
    
    reg  [63:0] CVALID = 0;

    wire [5:0]  CINDEX = ADDR[7:2];

    assign HIT = DLEN && RW && CVALID[CINDEX] && CTAG[CINDEX]==ADDR[31:8];

    assign DTREQ = DLEN && (!HIT||!RW); // valid data, but not hit -> dtreq

    always@(posedge CLK)
    begin
        if(RES)
        begin
            CVALID <= 0;
            $display("cache flush");
        end
        else
        if(DTREQ&&DTACK)
        begin        
            CDATA [CINDEX]  <= DATA;
            CTAG  [CINDEX]  <= ADDR[31:8];
            CVALID[CINDEX]  <= 1;
        end
        
        if(!RES) $display("access %d: HIT=%d DTREQ=%d DTACK=%d DATA=%d DATO=%d",ADDR,HIT,DTREQ,DTACK,DATA,DATO); 
    end

    assign DATO  = CDATA[CINDEX];

    assign DEBUG = { |DLEN, HIT, DTREQ, DTACK };

endmodule

module darkcache_sim;

    // clock

    reg CLK = 0;
    
    integer i;
    
    initial for(i=0;i!=100;i=i+1) #10 CLK = !CLK;

    // reset

    reg [2:0] RES = -1;
    
    always@(posedge CLK) RES <= RES ? RES-1 : 0;

    // logic

    wire  HLT,HIT,DTREQ;

    reg  [2:0]      DLEN=0;
    reg             RW=1;
    reg  [1:0]      DTACK=0;
    reg  [31:0]     ADDR=0,DATA=0;
    wire [31:0]     DATO;
    
    assign HLT = !HIT;
    
    always@(posedge CLK)
    begin
        if(!RES)
        begin
            DLEN <= 1; // 1 byte
            ADDR <= ADDR==7 ? 0 : ADDR+HIT;
        end
        
        DTACK <= DTACK ? DTACK-1 : DTREQ ? 3 : 0;
        if(DTACK==2) DATA  <= ~ADDR;
    end

    wire [3:0] DEBUG;

    darkcache icache(CLK,RES?1'b1:1'b0,RW,DLEN,ADDR,DATA,DATO,HIT,DTREQ,DTREQ?DTACK==1:1'b0,DEBUG);

endmodule
