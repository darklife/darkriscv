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

module darksocv
(
    input        XCLK,      // external clock
    input        XRES,      // external reset

    input        UART_RXD,  // UART receive line
    output       UART_TXD,  // UART transmit line

`ifdef __SDRAM__

    output          S_CLK,
    output          S_CKE,
    output          S_NCS,
    output          S_NWE,
    output          S_NRAS,
    output          S_NCAS,
    output [1:0]    S_DQM,
    output [1:0]    S_BA,
    output [12:0]   S_A,
    inout  [15:0]   S_DB,

`endif

    output [3:0] LED,       // on-board leds
    output [3:0] DEBUG      // osciloscope
);

    // clock and reset

    wire CLK,RES;

`ifdef BOARD_CK

    darkpll darkpll0
    (
        .XCLK(XCLK),
        .XRES(XRES),
        .CLK(CLK),
        .RES(RES)
    );

`else

    // internal/external reset logic

    reg [7:0] IRES = -1;

    `ifdef INVRES
        always@(posedge XCLK) IRES <= XRES==0 ? -1 : IRES[7] ? IRES-1 : 0; // reset low
    `else
        always@(posedge XCLK) IRES <= XRES==1 ? -1 : IRES[7] ? IRES-1 : 0; // reset high
    `endif

    assign CLK = XCLK;
    assign RES = IRES[7];

`endif

`ifdef __TESTMODE__

    // tips to port darkriscv for a new target:
	 //
	 // - 1st of all, test the blink code to confirms the reset
	 //   polarity, i.e. the LEDs must blink at startup when
	 //   the reset button *is not pressed*
	 // - 2nd check the blink rate: the 31-bit counter that starts
	 //   with BOARD_CK value and counts to zero, blinking w/
	 //   50% of this period

	 reg [31:0] BLINK = 0;

	 always@(posedge CLK)
	 begin
        BLINK <= RES ? 0 : BLINK ? BLINK-1 : `BOARD_CK;
	 end

	 assign LED      = (BLINK < (`BOARD_CK/2)) ? -1 : 0;
	 assign UART_TXD = UART_RXD;
`endif

    // darkbridge interface

    wire        XIRQ;
    wire        XDREQ;
    wire [31:0] XADDR;
    wire [31:0] XATAO;
    wire        XWR,
                XRD;
    wire [3:0]  XBE;
    wire [3:0]  XDREQMUX;

    assign XDREQMUX[0] = XDREQ && XADDR[31:30]==0;
    assign XDREQMUX[1] = XDREQ && XADDR[31:30]==1;
    assign XDREQMUX[2] = XDREQ && XADDR[31:30]==2;
    assign XDREQMUX[3] = XDREQ && XADDR[31:30]==3;

    wire [31:0] XATAIMUX [0:3];
    wire        XDACKMUX [0:3];

    // darkriscv

    wire [3:0]  KDEBUG;

    wire        ESIMREQ,ESIMACK;

    wire        HLT;

    wire        IDREQ;
    wire [31:0] IADDR;
    wire [31:0] IDATA;
    wire        IDACK;

`ifndef __HARVARD__

    assign IDREQ = 0;

`endif

    darkbridge
    bridge0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

`ifdef __INTERRUPT__
        .XIRQ    (XIRQ),
`endif

        .XXDREQ  (XDREQ),
        .XXADDR  (XADDR),
        .XXATAI  (XATAIMUX[XADDR[31:30]]),
        .XXATAO  (XATAO),
        .XXRD    (XRD),
        .XXWR    (XWR),
        .XXBE    (XBE),
        .XXDACK  (XDACKMUX[XADDR[31:30]]),

`ifdef __HARVARD__
        .YDREQ  (IDREQ),
        .YADDR  (IADDR),
        .YDATA  (IDATA),
        .YDACK  (IDACK),
`endif

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

        .DEBUG  (KDEBUG)
    );

    // bram memory w/ CS==0

    darkram bram0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

        .IDREQ  (IDREQ),
        .IADDR  (IADDR),
        .IDATA  (IDATA),
        .IDACK  (IDACK),

        .XDREQ  (XDREQMUX[0]),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XADDR  (XADDR),
        .XATAI  (XATAO),
        .XATAO  (XATAIMUX[0]),
        .XDACK  (XDACKMUX[0])
    );

    // io block w/ CS==1

    wire [3:0] IODEBUG;

    darkio io0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

`ifdef __INTERRUPT__
        .XIRQ    (XIRQ),
`endif

        .XDREQ  (XDREQMUX[1]),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XADDR  (XADDR),
        .XATAI  (XATAO),
        .XATAO  (XATAIMUX[1]),
        .XDACK  (XDACKMUX[1]),

        .RXD    (UART_RXD),
        .TXD    (UART_TXD),

        .LED    (LED),

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

        .DEBUG  (IODEBUG)
    );

    // sdram w/ CS==2

`ifdef __SDRAM__

    // sdram interface, thanks to my good friend Hirosh Dabui!

    wire READY;

    mt48lc16m16a2_ctrl
    #(
        .SDRAM_CLK_FREQ(`BOARD_CK/1000000)
    )
    sdram0
    (
        .clk        (CLK),
        .resetn     (!RES),

        .addr       (XADDR[24:0]),
        .din        (XATAO),
        .dout       (XATAIMUX[2]),
        .wmask      (XWR ? XBE : 4'b0000),
        .valid      (XDREQMUX[2]),
        .ready      (READY),

        .sdram_clk  (S_CLK),
        .sdram_cke  (S_CKE),
        .sdram_dqm  (S_DQM),
        .sdram_addr (S_A),
        .sdram_ba   (S_BA),
        .sdram_csn  (S_NCS),
        .sdram_wen  (S_NWE),
        .sdram_rasn (S_NRAS),
        .sdram_casn (S_NCAS),
        .sdram_dq   (S_DB)
    );

    assign XDACKMUX[2] = READY;

`else

    reg [3:0] DTACK2 = 0;
    reg       PRINT2 = 1;

    always@(posedge CLK)
    begin
        DTACK2 <= RES ? 0 : DTACK2 ? DTACK2-1 : XDREQMUX[2] ? 13 : 0;
        if(XDREQMUX[2] && PRINT2)
        begin
            $display("sdram: unmapped addr=%x",XADDR);
            PRINT2 <= 0;
        end
    end

    assign XATAIMUX[2] = 32'hdeadbeef;
    assign XDACKMUX[2] = DTACK2==1;

`endif

    // unmapped area w/ CS==3

    reg [3:0] DTACK3 = 0;
    reg PRINT3 = 1;

    always@(posedge CLK)
    begin
        DTACK3 <= RES ? 0 : DTACK3 ? DTACK3-1 : XDREQMUX[3] ? 1 : 0;
        if(XDREQMUX[3] && PRINT3)
        begin
            $display("sdram: unmapped addr=%x",XADDR);
            PRINT3 <= 0;
        end
    end

    assign XATAIMUX[3] = 32'hdeadbeef;
    assign XDACKMUX[3] = DTACK3==1;

    assign DEBUG = KDEBUG;

endmodule
