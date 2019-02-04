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

//`define CACHE_CONTROLLER 1
//`define STAGE3           1

`define AVNET_MICROBOARD_LX9

// weird clock calculations for microboard running at 66MHz:

`ifdef AVNET_MICROBOARD_LX9

    `define UART_BAUD   ((66666666/115200)-1)

`endif

module darksocv
(
`ifdef AVNET_MICROBOARD_LX9
    input        XCLK,       // 40MHz external clock
    input        XRES,       // external reset
    
    input        UART_RXD,  // UART receive line
    output       UART_TXD,  // UART transmit line
            
    output [3:0] LED,       // on-board leds
    output [3:0] DEBUG      // osciloscope
`else
    input        CLK,   // host clock
    input        RES,   // host reset

    inout [31:0] HDATAO, // host data input/output 
    input [31:0] HDADDR, // host addr input
    input        HWR,    // host wr enalbe
    input        HRD,    // host rd enable

    output [3:0]  DEBUG  // old-school oscilloscope debug
`endif
);

`ifdef AVNET_MICROBOARD_LX9

    // internal reset

    reg [7:0] IRES = -1;

    always@(posedge XCLK) IRES <= XRES ? -1 : IRES[7] ? IRES-1 : 0;

    wire CLK = XCLK;
    wire RES = IRES[7];
`endif

`ifndef CACHE_CONTROLLER
    reg [31:0] ROM [0:1023]; 
    reg [31:0] ROMFF;
`endif

    reg [31:0] RAM [0:1023];  // global memory
    reg [31:0] RAMFF;

    // memory initialization

    integer i;
    initial
    begin
        for(i=0;i!=1024;i=i+1)
        begin        
            RAM[i] = 32'd0;
        end
        
        $readmemh("../src/darksocv.ram",RAM);
`ifndef CACHE_CONTROLLER
        for(i=0;i!=1024;i=i+1)
        begin        
            ROM[i] = 32'd0;
        end
        
        $readmemh("../src/darksocv.rom",ROM);
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

`ifndef AVNET_MICROBOARD_LX9        
        if(HWR)
        begin
            RAM[HDADDR[10:2]] <= HDATAO;
        end
        
        RAMFF <= RAM[HDADDR[10:2]];
    end

    assign HDATAO = !HRD ? 32'hzzzzzzzz : RAMFF;
`else
    end
`endif

    // darkriscv cache interface

    wire [31:0] IADDR;
    wire [31:0] DADDR;
    wire [31:0] IDATA;    
    wire [31:0] DATAO;        
    wire [31:0] DATAI;
    wire WR,RD;
    wire [3:0] BE;
    wire [31:0] IOMUX;
    
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
    
    assign DATAI = DADDR[31] ? IOMUX : DCACHED;
    assign IDATA = ICACHED;
`else
    
    wire IHIT=1;
    wire DHIT=1;
    wire WHIT=1;

    reg [31:0] ROMFF2;
    reg [31:0] RAMFF2;
    
    always@(negedge CLK)
    begin
        ROMFF2 <= ROM[IADDR[11:2]];
        RAMFF2 <= RAM[DADDR[11:2]];
    end

    //wire [31:0] ROMFF2 = ROM[IADDR[11:2]];
    //wire [31:0] RAMFF2 = RAM[DADDR[11:2]];

    reg [31:0] ROMBUG = 0;
    
    always@(posedge CLK)
    begin   
        if(WR&&DADDR[31]==0&&DADDR[12]==1)
        begin
            //individual byte/word/long selection, thanks to HYF!                                                                                                                                                                                                                                
            if(BE[0]) RAM[DADDR[11:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
            if(BE[1]) RAM[DADDR[11:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
            if(BE[2]) RAM[DADDR[11:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
            if(BE[3]) RAM[DADDR[11:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];            
        end
        
        // weird bug appears to be related to the "sw ra,12(sp)" instruction.
        //if(WR&&DADDR[31]==0&&DADDR[12]==0)
        //    ROMBUG <= IADDR;
    end    
    
    assign DATAI = DADDR[31] ? IOMUX  : RAMFF2;
    assign IDATA = ROMFF2;
`endif


    // io for debug

    reg [ 7:0]  UART_XFIFO  = 0; // UART TX FIFO
    reg         UART_XREQ   = 0; // request (core side)
    reg         UART_XACK   = 0; // ack (uart side)
    reg [15:0]  UART_XBAUD  = 0; // baud rate counter
    reg [ 3:0]  UART_XSTATE = 6; // idle state

    reg [ 7:0]  UART_RFIFO  = 0; // UART RX FIFO
    reg         UART_RREQ   = 0; // request (uart side)
    reg         UART_RACK   = 0; // ack (core side)
    reg [15:0]  UART_RBAUD  = 0; // baud rate counter
    reg [ 3:0]  UART_RSTATE = 6; // idle state

    reg [2:0]   UART_RXDFF = -1;

    reg [3:0]   LEDFF = 0;

    always@(posedge CLK)
    begin
        if(WR&&DADDR[31])
        begin
            case(DADDR[3:0])
                4:  begin
                        UART_XFIFO <= DATAO[7:0];
`ifdef __ICARUS__
                        // print the UART output to console! :)
                        if(DATAI[7:0]!=13)
                        begin
                            $write("%c",DATAO[7:0]);
                        end            
`else
                        UART_XREQ <= !UART_XACK;    // activate UART!
`endif
                    end
                8:  begin
                        LEDFF <= DATAO[3:0];
                    end        
            endcase
        end

        UART_XBAUD <= UART_XBAUD ? UART_XBAUD-1 : `UART_BAUD;

        // sequence: 6(IDLE), 7(START), 8, 9, 10, 11, 12, 13, 14, 15, 0(STOP), 1(ACK)

        if(RES)
            UART_XSTATE <= 6;
        else 
        if(UART_XBAUD==0)
        begin
            case(UART_XSTATE)
                6: UART_XSTATE <= UART_XREQ^UART_XACK ? 7 : 6;
                default: UART_XSTATE <= UART_XSTATE+1;
                1: begin
                        UART_XSTATE <= 6;
                        UART_XACK <= UART_XREQ;
                        // print the UART output to console! :)
                        if(UART_XFIFO[7:0]!=13)
                        begin
                            $write("%c",UART_XFIFO[7:0]);
                        end
                   end
            endcase
        end
        
        if(RD&&DADDR[31]&&DADDR[3:0]==4)
        begin        
           UART_RACK <= UART_RREQ; // fifo ready
        end                

        UART_RXDFF <= (UART_RXDFF<<1)|UART_RXD;

        UART_RBAUD <= UART_RSTATE==6 ? (`UART_BAUD/2) : 
                          UART_RBAUD ? (UART_RBAUD-1) : 
                                       (`UART_BAUD);

        // sequence: 6(IDLE), 7(START), 8, 9, 10, 11, 12, 13, 14, 15, 0(STOP), 1(ACK)

        if(RES)
            UART_RSTATE <= 6;
        else
        if(UART_RSTATE==6)
        begin
            if(UART_RXDFF[2:1]==2'b10) // "negedge" detection
            begin
                UART_RSTATE <= UART_RSTATE+1; 
            end
        end
        else
        if(UART_RBAUD==0)
        begin
            case(UART_RSTATE)
                default: UART_RSTATE <= UART_RSTATE+1;
                1: begin
                        UART_RSTATE <= 6;
                        UART_RREQ <= !UART_RACK; // fifo not empty!
                   end
            endcase
            
            if(UART_RSTATE[3])
            begin
                UART_RFIFO[UART_RSTATE[2:0]] <= UART_RXDFF[2];
            end
        end
    end

    assign UART_TXD = UART_XSTATE[3] ? UART_XFIFO[UART_XSTATE[2:0]] : 
                      UART_XSTATE==7 ? 0 : 
                                       1;
                                       
    assign IOMUX = DADDR[3:2]==0 ? { 30'd0, UART_RREQ^UART_RACK, UART_XREQ^UART_XACK } :
                   DADDR[3:2]==1 ? { 24'd0, UART_RFIFO } : 
                                   { 28'd0, LEDFF }; 
                                   //{ ROMBUG };

    // darkriscv

    // TODO: replace the HLT by DTACK-like signals separated for 
    // instruction and data, and make the bus interface more 68k-like.
    // add support for multiple cores! \o/

    wire [3:0] KDEBUG;

    darkriscv
    #(
        .RESET_PC(0),
        .RESET_SP(32'h00002000)
    ) 
    core0 
    (
        .CLK(CLK),
        .RES(RESFF[1]),
        .HLT(!IHIT||!DHIT||!WHIT),
        .IDATA(IDATA),
        .IADDR(IADDR),
        .DATAI(DATAI),
        .DATAO(DATAO),
        .DADDR(DADDR),        
        .BE(BE),
        .WR(WR),
        .RD(RD),
        .DEBUG(KDEBUG)
    );

`ifdef __ICARUS__
  initial
  begin
    $dumpfile("darkriscv.vcd");
    $dumpvars(0, core0);
  end
`endif

`ifdef AVNET_MICROBOARD_LX9
    assign LED   = LEDFF;
    assign DEBUG = { WR, RD, UART_RREQ^UART_RACK, UART_RXD };
`else
    assign DEBUG = KDEBUG;
`endif

endmodule
