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

// pseudo-soc for testing purposes

module darksocv
(
    input        CLK,   // host clock
    input        RES,   // host reset

    inout [31:0] HDATAO, // host data input/output 
    input [31:0] HDADDR, // host addr input
    input        HWR,    // host wr enalbe
    input        HRD,    // host rd enable

    output [3:0]  DEBUG  // old-school oscilloscope debug
);

    reg [31:0] IDATA [0:511];  // instruction memory
    reg [31:0] IDATAFF;

    reg [31:0] DDATA [0:511];  // data memory
    reg [31:0] DDATAFF;

    // memory initialization

    // TODO: add control register in order to the external
    // host can control the darkriscv as a slave processor.

    integer i;
    
    initial
    begin
        for(i=0;i!=512;i=i+1)
        begin
            IDATA[i] = 0;
            DDATA[i] = 0;
        end
        
        $readmemh("../src/darksocv.hex",IDATA);
        $readmemh("../src/darksocv.hex",DDATA);
    end
    
    reg [1:0] RESFF;

    // host memory interface
    
    always@(posedge CLK)
    begin
        RESFF <= RESFF<<1 | RES;
    
        if(HWR)
        begin
            if(HDADDR[31]) IDATA[HDADDR[8:0]] <= HDATAO;
            else           DDATA[HDADDR[8:0]] <= HDATAO;
        end
        
        IDATAFF <= IDATA[HDADDR[8:0]];
        DDATAFF <= DDATA[HDADDR[8:0]];       
    end

    assign HDATAO =       !HRD ? 32'hzzzzzzzz : 
                    HDADDR[31] ? IDATAFF : 
                                 DDATAFF;

    // darkriscv memory interface

    wire [31:0] IADDR;
    wire [31:0] DADDR;    
    wire [31:0] DATAO;        
    wire WR,RD;

    reg [31:0] IDATAFF2 = 0;
    reg [31:0] DATAIFF2 = 0;
        
    reg [31:0] XFIFO = 0; // UART TX FIFO

    wire [7:0] UART = XFIFO[7:0];
    
    // as long blockRAM read is delayed, *both* RAM and ROM must work in negative edge!
    
    reg [3:0] IWAIT = 0;
    reg [3:0] DWAIT = 0;

    // example: variable 16-byte aligned cache miss/hit w/ 3 wait-states
    // the wait-state for instruction and data can be actived in any random order.

    always@(negedge CLK) 
    begin
        //IWAIT <= RESFF[1] ? -1 : IWAIT ? IWAIT-1 :     IWAIT==0&&IADDR[3:0]==0 ? 2 : 0; // i-cache wait-state
        //DWAIT <= RESFF[1] ? -1 : DWAIT ? DWAIT-1 : RD&&DWAIT==0&&DADDR[3:0]==0 ? 2 : 0; // d-cache wait-state    
    end

    always@(negedge CLK)
    begin
        IDATAFF2 <= IDATA[IADDR[10:2]];   
        DATAIFF2 <= DDATA[DADDR[10:2]];
        
        if(WR)
        begin
            if(DADDR[31]==0)
            begin
                DDATA[DADDR[10:2]] <= DATAO;
            end
            else
            begin
                XFIFO <= DATAO[31:0]; // dummy UART            
            end
        
            //$display("WR: %c at %x",DATAO,DADDR);
        end
    end

    // darkriscv

    // TODO: replace the HLT by DTACK-like signals separated for 
    // instruction and data, and make the bus interface more 68k-like.
    // add support for multiple cores! \o/

    darkriscv
    #(
        .RESET_PC(0),
        .RESET_SP(4096)        
    ) 
    core0 
    (
        .CLK(CLK),
        .RES(RESFF[1]),        
        .HLT(IWAIT||DWAIT||XFIFO==32'hdeadbeef),
        .IDATA(IDATAFF2),
        .IADDR(IADDR),        
        .DATAI(DADDR[31] ? 0 : DATAIFF2), // UART vs. RAM        
        .DATAO(DATAO),
        .DADDR(DADDR),        
        .WR(WR),
        .RD(RD),
        .DEBUG(DEBUG)
    );

endmodule
