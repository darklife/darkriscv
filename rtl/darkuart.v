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

// the following defines are automatically defined:
/*
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
*/
// uart states

`define UART_STATE_IDLE  6
`define UART_STATE_START 7
`define UART_STATE_DATA0 8
`define UART_STATE_DATA1 9
`define UART_STATE_DATA2 10
`define UART_STATE_DATA3 11
`define UART_STATE_DATA4 12
`define UART_STATE_DATA5 13
`define UART_STATE_DATA6 14
`define UART_STATE_DATA7 15
`define UART_STATE_STOP  0
`define UART_STATE_ACK   1

// UART registers
// 
// 0: status register ro, 1 = xmit busy, 2 = recv bfusy
// 1: buffer register rw, w = xmit fifo, r = recv fifo
// 2: baud rate msb   rw (not used)
// 3: baud rate lsb   rw (not used)

module darkuart
//#(
// parameter [15:0] BAUD = 0
//) 
(
    input           CLK,            // clock
    input           RES,            // reset
        
    input           RD,             // bus read
    input           WR,             // bus write
    input  [ 3:0]   BE,             // byte enable
    input  [31:0]   DATAI,          // data input
    output [31:0]   DATAO,          // data output
    output          IRQ,            // interrupt req

    input           RXD,            // UART recv line
    output          TXD,            // UART xmit line

`ifdef SIMULATION
    output reg	    FINISH_REQ = 0,
`endif
    
    output [3:0]    DEBUG           // osc debug
);

    reg [15:0]  UART_TIMER = `__BAUD__;  // baud rate from config.vh
    reg         UART_IREQ  = 0;     // UART interrupt req
    reg         UART_IACK  = 0;     // UART interrupt ack

`ifdef __UARTQUEUE__
    reg [ 7:0]  UART_XFIFO [0:255]; // UART TX FIFO
    wire [7:0]  UART_XTMP;          // UART TX FIFO
    reg [ 8:0]  UART_XREQ  = 0;     // xmit request (core side)
    reg [ 8:0]  UART_XACK  = 0;     // xmit ack (uart side)
`else
    reg [ 7:0]  UART_XFIFO = 0;     // UART TX FIFO
    reg         UART_XREQ  = 0;     // xmit request (core side)
    reg         UART_XACK  = 0;     // xmit ack (uart side)
`endif
    reg [15:0]  UART_XBAUD = 0;     // baud rate counter
    reg [ 3:0]  UART_XSTATE= 0;     // idle state

`ifdef __UARTQUEUE__
    reg [ 7:0]  UART_RFIFO [0:255]; // UART RX FIFO
    reg [ 7:0]  UART_RTMP  = 0;     // UART RX FIFO
    reg [ 8:0]  UART_RREQ  = 0;     // request (uart side)
    reg [ 8:0]  UART_RACK  = 0;     // ack (core side)
`else
    reg [ 7:0]  UART_RFIFO = 0;     // UART RX FIFO
    reg         UART_RREQ  = 0;     // request (uart side)
    reg         UART_RACK  = 0;     // ack (core side)
`endif
    reg [15:0]  UART_RBAUD = 0;     // baud rate counter
    reg [ 3:0]  UART_RSTATE= 0;     // idle state

    reg [2:0]   UART_RXDFF = -1;

`ifdef __UARTQUEUE__
    wire [7:0]  UART_STATE = { 6'd0, UART_RREQ!=UART_RACK, UART_XREQ==(UART_XACK^9'h100) };

    integer i;
    
    initial
    for(i=0;i!=256;i=i+1)
    begin
        UART_RFIFO[i] = 0;
        UART_XFIFO[i] = 0;
    end
`else
    wire [7:0]  UART_STATE = { 6'd0, UART_RREQ!=UART_RACK, UART_XREQ!=UART_XACK };    
`endif
    reg [7:0]   UART_STATEFF = 0;

    // bus interface

    reg [31:0] DATAOFF = 0;

    reg [1:0] IOREQ = 0;
    reg [1:0] IOACK = 0;

    always@(posedge CLK)
    begin
        if(WR)
        begin
            if(BE[1])
            begin

`ifdef SIMULATION
                // print the UART output to console! :)
                if(DATAI[15:8]!=13) // remove the '\r'
                begin
                    UART_XFIFO <= DATAI[15:8];
                    $write("%c",DATAI[15:8]);
                    
                    if(IOREQ==1&&DATAI[15:8]==" ")
                    begin
                        $fflush(32'h8000_0001);
                        IOREQ <= 2;
                    end
                    else
                        IOREQ <= 0;
                end
                
                //if(DATAI[15:8]=="#") // break point
                //begin
                //    $display("[checkpoint #]");
                //    $stop();
                //end
                
                if(DATAI[15:8]==">") // prompt '>'
                begin
                
    `ifndef __INTERACTIVE__
                    $display(" the __INTERACTIVE__ option is disabled, ending simulation...");
                    FINISH_REQ <= 1;
    `endif                    
                    if(IOACK==0) IOREQ <= 1;
                end
`else
    `ifdef __UARTQUEUE__
                if(UART_XREQ!=(UART_XACK^9'h100))
                begin
                    UART_XFIFO[UART_XREQ[7:0]] <= DATAI[15:8];
                    UART_XREQ <= UART_XREQ+1;
                end
    `else            
                UART_XFIFO <= DATAI[15:8];
                UART_XREQ <= !UART_XACK;    // activate UART!
    `endif
`endif
            end
            //if(BE[2]) UART_TIMER[ 7:0] <= DATAI[23:16];
            //if(BE[3]) UART_TIMER[15:8] <= DATAI[31:24];           
        end
    
        if(RES)
        begin
            UART_RACK <= UART_RREQ;
            UART_STATEFF <= UART_STATE;
        end
        else
        if(RD)
        begin
`ifdef __UARTQUEUE__
            if(BE[1]) UART_RACK     <= UART_RACK!=UART_RREQ?UART_RACK+1:UART_RACK; // fifo ready
`else
            if(BE[1]) UART_RACK     <= UART_RREQ; // fifo ready
`endif
            if(BE[0]) UART_STATEFF <= UART_STATE; // state update, clear irq
        end
    end
    
    assign IRQ   = |(UART_STATE^UART_STATEFF);
`ifdef __UARTQUEUE__
    assign DATAO = { UART_TIMER, UART_RFIFO[UART_RACK[7:0]], UART_STATE };
`else
    assign DATAO = { UART_TIMER, UART_RFIFO, UART_STATE };
`endif

    // xmit path: 6(IDLE), 7(START), 8, 9, 10, 11, 12, 13, 14, 15, 0(STOP), 1(ACK)
    
    always@(posedge CLK)
    begin    
        UART_XBAUD <= UART_XSTATE==`UART_STATE_IDLE ? UART_TIMER :      // xbaud=timer
                      UART_XBAUD ? UART_XBAUD-1 : UART_TIMER;           // while() { while(xbaud--); xbaud=timer }

        UART_XSTATE <= RES||UART_XSTATE==`UART_STATE_ACK  ? `UART_STATE_IDLE :
                            UART_XSTATE==`UART_STATE_IDLE ? UART_XSTATE+(UART_XREQ!=UART_XACK) :
                                                            UART_XSTATE+(UART_XBAUD==0);
`ifdef __UARTQUEUE__
        UART_XACK   <= RES ? UART_XREQ : UART_XSTATE==`UART_STATE_ACK && UART_XACK!=UART_XREQ  ? UART_XACK+1 : UART_XACK;
`else                                                           
        UART_XACK   <= RES||UART_XSTATE==`UART_STATE_ACK  ? UART_XREQ : UART_XACK;
`endif        
    end

`ifdef __UARTQUEUE__
    assign UART_XTMP = UART_XFIFO[UART_XACK[7:0]];
    
    assign TXD = UART_XSTATE[3] ? UART_XTMP[UART_XSTATE[2:0]] : UART_XSTATE==`UART_STATE_START ? 0 : 1;
`else
    assign TXD = UART_XSTATE[3] ? UART_XFIFO[UART_XSTATE[2:0]] : UART_XSTATE==`UART_STATE_START ? 0 : 1;
`endif

    // recv path: 6(IDLE), 7(START), 8, 9, 10, 11, 12, 13, 14, 15, 0(STOP), 1(ACK)

    always@(posedge CLK)
    begin
        UART_RXDFF <= (UART_RXDFF<<1)|RXD;

        UART_RBAUD <= UART_RSTATE==`UART_STATE_IDLE ? { 1'b0, UART_TIMER[15:1] } :    // rbaud=timer/2
                      UART_RBAUD ? UART_RBAUD-1 : UART_TIMER;               // while() { while(rbaud--); rbaud=timer }

        UART_RSTATE <= RES||UART_RSTATE==`UART_STATE_ACK  ? `UART_STATE_IDLE :
                            UART_RSTATE==`UART_STATE_IDLE ? UART_RSTATE+(UART_RXDFF[2:1]==2'b10) : // start bit detection
                                                            UART_RSTATE+(UART_RBAUD==0);
                                                            
`ifdef __UARTQUEUE__
        if(UART_RSTATE==`UART_STATE_ACK&&(UART_RREQ!=(UART_RACK^9'h100)))
        begin
            UART_RREQ <= UART_RREQ+1;
            UART_RFIFO[UART_RREQ[7:0]] <= UART_RTMP;
        end
`else
        UART_RREQ <= (IOACK==2 || UART_RSTATE==`UART_STATE_ACK) ? !UART_RACK : UART_RREQ;
`endif
        if(UART_RSTATE[3]) 
        begin
`ifdef __UARTQUEUE__  
            UART_RTMP[UART_RSTATE[2:0]] <= UART_RXDFF[2];
`else
            UART_RFIFO[UART_RSTATE[2:0]] <= UART_RXDFF[2];
`endif
        end
`ifdef SIMULATION
        else
        if(IOACK==1)
        begin
            UART_RFIFO <= $fgetc(32'h8000_0000);
            IOACK <= 2;
        end
        else
        if(IOACK==2)
        begin
            IOACK <= UART_RREQ^UART_RACK ? 3 : 2;
        end
        else
        if(IOACK==3)
        begin
            IOACK <= UART_RREQ^UART_RACK ? 3 : (UART_RFIFO=="\n" ? 0 : 1);
        end
        else
        if(IOREQ==2)
        begin
            IOACK <= 1;
        end
`endif        
    end

    //debug
    
    assign DEBUG = { RXD, TXD, UART_XSTATE!=`UART_STATE_IDLE, UART_RSTATE!=`UART_STATE_IDLE };
    
endmodule
