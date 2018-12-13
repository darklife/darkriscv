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

`define CACHE_CONTROLLER 1
`define STAGE3           1

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

`ifndef CACHE_CONTROLLER
    reg [31:0] ROM [0:511]; 
    reg [31:0] ROMFF;
`endif

    reg [31:0] RAM [0:511];  // global memory
    reg [31:0] RAMFF;

    // memory initialization

    integer i;
    initial
    begin
        for(i=0;i!=512;i=i+1)
        begin        
            RAM[i] = 32'dz;
        end
        
        $readmemh("../src/darksocv.hex",RAM);
`ifndef CACHE_CONTROLLER
        for(i=0;i!=512;i=i+1)
        begin        
            ROM[i] = 32'dz;
        end
        
        $readmemh("../src/darksocv.hex",ROM);
`endif        
    end
    
    reg [1:0] RESFF;

    // host memory interface
    
    always@(posedge CLK)
    begin
        RESFF <= RESFF<<1 | RES;
        
        if(^RESFF)
        begin
`ifdef CACHE_CONTROLLER        
            $display("cache controller active");
`endif
`ifdef STAGE3
            $display("3-stage pipeline active");
`endif        
        end
        
        if(HWR)
        begin
            RAM[HDADDR[10:2]] <= HDATAO;
        end
        
        RAMFF <= RAM[HDADDR[10:2]];
    end

    assign HDATAO = !HRD ? 32'hzzzzzzzz : RAMFF;

    // darkriscv cache interface

    wire [31:0] IADDR;
    wire [31:0] DADDR;
    wire [31:0] IDATA;    
    wire [31:0] DATAO;        
    wire [31:0] DATAI;
    wire WR,RD;
    
`ifdef CACHE_CONTROLLER
    // instruction cache

    reg  [55:0] ICACHE [0:63]; // instruction cache
    reg  [63:0] ITAG = 0;      // instruction cache tag
    
    wire [5:0]  IPTR    = IADDR[7:2];
    wire [55:0] ICACHEO = ICACHE[IPTR];
    wire [31:0] ICACHED = ICACHEO[31: 0]; // data
    wire [31:8] ICACHEA = ICACHEO[55:32]; // address
    
    wire IHIT = ITAG[IPTR] && ICACHEA==IADDR[31:8];

    // data cache

    reg  [55:0] DCACHE [0:63]; // data cache
    reg  [63:0] DTAG = 0;      // data cache tag

    wire [5:0]  DPTR    = DADDR[7:2];
    wire [55:0] DCACHEO = DCACHE[DPTR];
    wire [31:0] DCACHED = DCACHEO[31: 0]; // data
    wire [31:8] DCACHEA = DCACHEO[55:32]; // address

    wire DHIT = RD ? DTAG[DPTR] && DCACHEA==DADDR[31:8] : 1;

    // cache fill

    reg [31:0] RAMFF2;
    reg        WTAG    = 0;
    reg [31:0] WCACHEA = 0;
    
    reg  FFX = 0;
    reg FFX2 = 0;

    wire [31:0] AFILL = (!DHIT||!WHIT) ? DADDR : IADDR;

    wire WHIT = WR&&!DADDR[31] ? WTAG&&WCACHEA==DADDR : 1;

    always@(posedge CLK)
    begin
        RAMFF2 <= RAM[AFILL[10:2]];

        if(FFX2)
        begin
            FFX2 <= 0;
            FFX  <= 0;
        end
        else
        if(!DHIT)
        begin
            DCACHE[DPTR] <= { DADDR[31:8], RAMFF2 };
            FFX          <= 1;
            DTAG[DPTR]   <= FFX; // cached!
            FFX2         <= FFX;
        end        
        else
        if(!WHIT)
        begin
            RAM [AFILL[10:2]] <= DATAO; // write-through
            
            FFX          <= 1;
            WCACHEA      <= DADDR;
            DCACHE[DPTR] <= { DADDR[31:8], DATAO };
            DTAG[DPTR]   <= FFX; // cached!
            WTAG         <= FFX;
            FFX2         <= FFX;
        end
        else
        if(!IHIT)
        begin
            ICACHE[IPTR] <= { IADDR[31:8], RAMFF2 };
            FFX          <= 1;
            ITAG[IPTR]   <= FFX; // cached!
            FFX2         <= FFX;
        end
    end
    
    assign DATAI = DADDR[31] ? 0 : DCACHED;
    assign IDATA = ICACHED;
`else
    reg [31:0] ROMFF2;
    reg [31:0] RAMFF2;
    
    wire IHIT=1;
    wire DHIT=1;
    wire WHIT=1;
    
    //always@(negedge CLK) ROMFF2 <= ROM[IADDR[10:2]];
    
    always@(posedge CLK)
    begin
        ROMFF2 <= ROM[IADDR[10:2]];
        RAMFF2 <= RAM[DADDR[10:2]];
   
        if(WR&&!DADDR[31])
        begin
            RAM[DADDR[10:2]] <= DATAO;
        end
    end    
    
    assign DATAI = DADDR[31] ? 0 : RAMFF2;
    assign IDATA = ROMFF2;
`endif


    // io for debug
        
    reg [31:0] XFIFO = 0; // UART TX FIFO

    wire [7:0] UART = XFIFO[7:0];

    reg WRX = 0;

    always@(posedge CLK)
    begin        
        if(WR&&DADDR[31])
        begin        
            XFIFO <= DATAO[31:0];
            
            // print the UART output to console! :)
            if(DATAI[7:0]!=13)
            begin
                $write("%c",DATAO[7:0]);
            end
        end
    end

    // darkriscv

    // TODO: replace the HLT by DTACK-like signals separated for 
    // instruction and data, and make the bus interface more 68k-like.
    // add support for multiple cores! \o/

    darkriscv
    #(
        .RESET_PC(0),
        .RESET_SP(2048)
    ) 
    core0 
    (
`ifdef STAGE3   
        .CLK(CLK),
`else
        .CLK(!CLK),
`endif         
        .RES(RESFF[1]),        
        .HLT(!IHIT||!DHIT||!WHIT),
        .IDATA(IDATA),
        .IADDR(IADDR),
        .DATAI(DATAI), // UART vs. RAM        
        .DATAO(DATAO),
        .DADDR(DADDR),        
        .WR(WR),
        .RD(RD),
        .DEBUG(DEBUG)
    );


`ifdef __ICARUS__

  initial
  begin
    $dumpfile("darkriscv.vcd");
    $dumpvars(0, core0);
  end

`endif

endmodule
