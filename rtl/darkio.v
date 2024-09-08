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

module darkio
(
    input         CLK,      // clock
    input         RES,      // reset
    input         HLT,      // halt

    input         XDREQ,
    input         XWR,
    input         XRD,
    input  [3:0]  XBE,
    input  [31:0] XADDR,
    input  [31:0] XATAI,
    output [31:0] XATAO,
    output        XDACK,
    output        XIRQ,

    input         RXD,  // UART receive line
    output        TXD,  // UART transmit line

`ifdef SIMULATION
    output        ESIMREQ,
    input         ESIMACK,
`endif

    output [3:0]  LED,       // on-board leds
    output [3:0]  DEBUG      // osciloscope
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

    always@(posedge CLK)
    begin
        DTACK <= RES ? 0 : DTACK ? DTACK-1 : (XDREQ && XRD) ? 1 : 0; // wait-states

        if(RES)
        begin
            IACK <= 0;
            TIMERFF <= (`BOARD_CK/1000)-1; // timer set to 1kHz by default
        end
        else
        if(XDREQ && XWR)
        begin
            case(XADDR[4:0])
                5'b00011:   begin
                                //$display("clear io.irq = %x (ireq=%x, iack=%x)",XATAI[32:24],IREQ,IACK);

                                IACK[7] <= XATAI[7+24] ? IREQ[7] : IACK[7];
                                IACK[6] <= XATAI[6+24] ? IREQ[6] : IACK[6];
                                IACK[5] <= XATAI[5+24] ? IREQ[5] : IACK[5];
                                IACK[4] <= XATAI[4+24] ? IREQ[4] : IACK[4];
                                IACK[3] <= XATAI[3+24] ? IREQ[3] : IACK[3];
                                IACK[2] <= XATAI[2+24] ? IREQ[2] : IACK[2];
                                IACK[1] <= XATAI[1+24] ? IREQ[1] : IACK[1];
                                IACK[0] <= XATAI[0+24] ? IREQ[0] : IACK[0];
                            end
                5'b01000:   LEDFF   <= XATAI[15:0];
                5'b01010:   GPIOFF  <= XATAI[31:16];
                5'b01100:   TIMERFF <= XATAI[31:0];
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

        if(XDREQ && XRD)
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

    assign XATAO = IOMUXFF;
    assign XDACK = DTACK==1||(XDREQ&&XWR);

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
      .RD(!HLT && XRD && XDREQ && XADDR[4:2]==1),
      .WR(!HLT && XWR && XDREQ && XADDR[4:2]==1),
      .BE(XBE),
      .DATAI(XATAI),
      .DATAO(UDATA),
      //.IRQ(UART_IRQ),

`ifndef __TESTMODE__
      .RXD(RXD),
      .TXD(TXD),
`endif		
`ifdef SIMULATION
      .ESIMREQ(ESIMREQ),
      .ESIMACK(ESIMACK),
`endif
      .DEBUG(UDEBUG)
    );

    assign DEBUG = { XDREQ,XRD,XWR,XDACK };

endmodule
