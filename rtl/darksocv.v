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
    wire [31:0] XADDR;
    wire [31:0] XATAO;
    wire        XWR,
                XRD;
    wire [3:0]  XBE;
    wire [3:0]  XCS;

    wire [31:0] XATAIMUX [0:3];
    wire        XDACKMUX [0:3];
    
    assign XDACKMUX[0] = 0; // unused
    assign XDACKMUX[3] = 0; // unused    
    
    // darkriscv

    wire [3:0]  KDEBUG;
    
    wire        ESIMREQ,ESIMACK;

    darkbridge
    bridge0
    (
        .CLK    (CLK),
        .RES    (RES),

`ifdef __INTERRUPT__
        .XIRQ    (XIRQ),
`endif

        .XADDR  (XADDR),
        .XATAI  (XATAIMUX[XADDR[31:30]]),
        .XATAO  (XATAO),
        .XRD    (XRD),
        .XWR    (XWR),
        .XBE    (XBE),
        .XCS    (XCS),
        .XDACK  (XDACKMUX[XADDR[31:30]]),

`ifdef SIMULATION
        .ESIMREQ(ESIMREQ),
        .ESIMACK(ESIMACK),
`endif

        .DEBUG  (KDEBUG)
    );

    // io block

    reg [15:0] GPIOFF = 0;
    reg [15:0] LEDFF  = 0;

    reg  [7:0] IREQ = 0;
    reg  [7:0] IACK = 0;

    reg [31:0] TIMERFF = 0;
    reg [31:0] TIMEUS = 0;

    reg [31:0] IOMUXFF = 0;

    wire [7:0] BOARD_IRQ;

    wire [7:0] BOARD_ID = `BOARD_ID;              // board id
    wire [7:0] BOARD_CM = (`BOARD_CK/2000000);    // board clock (MHz)

    wire [7:0] CORE_ID = 0;                       // core id, unused

    wire [31:0] UDATA; // uart data

    reg [31:0] TIMER = 0;

    reg XTIMER = 0;

    reg [1:0] DTACK  = 0;

    wire DHIT = !((XRD) && DTACK!=1); // the XWR operatio does not need ws. in this config.

    always@(posedge CLK)
    begin
        DTACK <= RES ? 0 : DTACK ? DTACK-1 : (XRD) ? 1 : 0; // wait-states

        if(RES)
        begin
            IACK <= 0;
            TIMERFF <= (`BOARD_CK/1000000)-1; // timer set to 1MHz by default
        end
        else
        if(XCS[1] && XWR)
        begin
            case(XADDR[4:0])
                5'b00011:   begin
                                //$display("clear io.irq = %x (ireq=%x, iack=%x)",XATAO[32:24],IREQ,IACK);

                                IACK[7] <= XATAO[7+24] ? IREQ[7] : IACK[7];
                                IACK[6] <= XATAO[6+24] ? IREQ[6] : IACK[6];
                                IACK[5] <= XATAO[5+24] ? IREQ[5] : IACK[5];
                                IACK[4] <= XATAO[4+24] ? IREQ[4] : IACK[4];
                                IACK[3] <= XATAO[3+24] ? IREQ[3] : IACK[3];
                                IACK[2] <= XATAO[2+24] ? IREQ[2] : IACK[2];
                                IACK[1] <= XATAO[1+24] ? IREQ[1] : IACK[1];
                                IACK[0] <= XATAO[0+24] ? IREQ[0] : IACK[0];
                            end
                5'b01000:   LEDFF   <= XATAO[15:0];
                5'b01010:   GPIOFF  <= XATAO[31:16];
                5'b01100:   TIMERFF <= XATAO[31:0];
            endcase
        end
        
        if(RES)
            IREQ <= 0;
        else
        if(TIMERFF)
        begin
            TIMER <= TIMER ? TIMER-1 : TIMERFF;

            if(TIMER==0 && IREQ==IACK)
            begin
                IREQ[7] <= !IACK[7];

                //$display("timr0 set");
            end

            XTIMER  <= XTIMER+(TIMER==0);
            TIMEUS <= (TIMER == TIMERFF) ? TIMEUS + 1'b1 : TIMEUS;
        end

        if(XCS[1] && XRD)
        begin
            casex(XADDR[4:0])
                5'b000xx:   IOMUXFF <= { BOARD_IRQ, CORE_ID, BOARD_CM, BOARD_ID };
                5'b001xx:   IOMUXFF <= UDATA; // from uart
                5'b0100x:   IOMUXFF <= LEDFF;
                5'b0101x:   IOMUXFF <= GPIOFF;
                5'b011xx:   IOMUXFF <= TIMERFF;
                5'b100xx:   IOMUXFF <= TIMEUS;
            endcase
        end
    end

    assign XATAIMUX[1] = IOMUXFF;
    assign XDACKMUX[1] = !DHIT;

    assign BOARD_IRQ = IREQ^IACK;
    
    assign XIRQ = |BOARD_IRQ;
    
`ifndef __TESTMODE__
    assign LED = LEDFF[3:0];
`endif

    // darkuart

    wire [3:0] UDEBUG;

    darkuart
    uart0
    (
      .CLK(CLK),
      .RES(RES),
      .RD(XRD && XCS[1] && XADDR[4:2]==1),
      .WR(XWR && XCS[1] && XADDR[4:2]==1),
      .BE(XBE),
      .DATAI(XATAO),
      .DATAO(UDATA),
      //.IRQ(UART_IRQ),

`ifndef __TESTMODE__
      .RXD(UART_RXD),
      .TXD(UART_TXD),
`endif		
`ifdef SIMULATION
      .ESIMREQ(ESIMREQ),
      .ESIMACK(ESIMACK),
`endif
      .DEBUG(UDEBUG)
    );

    // sdram
    
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
        .valid      (XCS[2]),
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

    assign XDACKMUX[2] = !READY;

`endif
	 
    assign DEBUG = KDEBUG;

endmodule
