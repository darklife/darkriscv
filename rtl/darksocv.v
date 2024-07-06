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

    // darkriscv bus interface

    wire        HLT;
    wire        IRQ;
    
    wire [31:0] IADDR;
    wire [31:0] IDATA;
    wire        IDACK;
    
    wire [31:0] DADDR;
    wire [31:0] DATAO;
    wire [31:0] DATAI;
    wire [ 2:0] DLEN;
    wire        DRW;
    wire        DDACK;
    
    assign HLT = IDACK||DDACK;

    // darkriscv

    wire [3:0]  KDEBUG;
    wire        IDLE;

`ifdef __THREADS__
    wire [`__THREADS__-1:0] TPTR;
`endif

    darkriscv
    core0
    (
        .CLK    (CLK),
        .RES    (RES),
        .HLT    (HLT),

`ifdef __THREADS__
        .TPTR   (TPTR),
`endif

`ifdef __INTERRUPT__
        .IRQ    (IRQ),
`endif

        .IDATA  (IDATA),
        .IADDR  (IADDR),
        .DADDR  (DADDR),

        .DATAI  (DATAI),
        .DATAO  (DATAO),
        .DLEN   (DLEN),
        .DRW    (DRW),

        .IDLE   (IDLE),
        .DEBUG  (KDEBUG)
    );

    // address map
    
    wire CS0 = DLEN && DADDR[31:30]==0;
    wire CS1 = DLEN && DADDR[31:30]==1;
`ifdef __SDRAM__
    wire CS2 = DLEN && DADDR[31:30]==2;
`endif
    wire CS3 = 0;

    // legacy bus interface-X

    wire [31:0] XADDR;
    wire [31:0] XATAO;
    wire [31:0] XATAI;
    wire        XWR,XRD,XDACK;
    wire [3:0]  XBE;

    wire [31:0] XATAIMUX [0:3];
    wire        XDACKMUX [0:3];
    
    assign DATAI = DLEN[0] ? ( DADDR[1:0]==3 ? XATAI[31:24] :
                               DADDR[1:0]==2 ? XATAI[23:16] :
                               DADDR[1:0]==1 ? XATAI[15: 8] :
                                               XATAI[ 7: 0] ):
                   DLEN[1] ? ( DADDR[1]==1   ? XATAI[31:16] :
                                               XATAI[15: 0] ):
                                               XATAI;

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
    assign XATAI = XATAIMUX[DADDR[31:30]];
    assign XDACK = XDACKMUX[DADDR[31:30]];

    assign DDACK = DLEN ? !XDACKMUX[DADDR[31:30]] : 0;

    // ro/rw memories

`ifdef __HARVARD__

    reg [31:0] ROM [0:2**`MLEN/4-1]; // ro memory
    reg [31:0] RAM [0:2**`MLEN/4-1]; // rw memory

    // memory initialization

    integer i;
    initial
    begin
        for(i=0;i!=2**`MLEN/4;i=i+1)
        begin
            ROM[i] = 32'd0;
            RAM[i] = 32'd0;
        end

        // workaround for vivado: no path in simulation and .mem extension

    `ifdef XILINX_SIMULATOR
        $readmemh("darksocv.rom.mem",ROM);
        $readmemh("darksocv.ram.mem",RAM);
    `else
        $readmemh("../src/darksocv.rom.mem",ROM);
        $readmemh("../src/darksocv.ram.mem",RAM);
    `endif
    end

`else

    reg [31:0] MEM [0:2**`MLEN/4-1]; // ro memory

    // memory initialization

    integer i;
    initial
    begin
    `ifdef SIMULATION
        $display("clearing MEM w/ %d words...",2**`MLEN/4);
        for(i=0;i!=2**`MLEN/4;i=i+1)
        begin
            MEM[i] = 32'd0;
        end
    `endif

     // workaround for vivado: no path in simulation and .mem extension

    `ifdef XILINX_SIMULATOR
        $readmemh("darksocv.mem",MEM);
	 `elsif MODEL_TECH
		  $readmemh("../../../../src/darksocv.mem",MEM);
    `else
        $readmemh("../src/darksocv.mem",MEM,0);
    `endif
    end

`endif

    // instruction memory

    reg [1:0]  ITACK  = 0;
    reg [31:0] ROMFF  = 0;
    reg [31:0] ROMFF2 = 0;
    reg        HLT2   = 0;

    wire IHIT = !ITACK;

    always@(posedge CLK)
    begin
        ITACK <= RES ? 0 : ITACK ? ITACK-1 : 0;
        
        if(HLT^HLT2)
        begin
            ROMFF2 <= ROMFF;
        end

        HLT2 <= HLT;

`ifdef __HARVARD__
        ROMFF <= ROM[IADDR[`MLEN-1:2]];
`else
        ROMFF <= MEM[IADDR[`MLEN-1:2]];
`endif
    end

    assign IDATA = HLT2 ? ROMFF2 : ROMFF;
    assign IDACK = !IHIT;

    // data memory

    reg [1:0] DTACK  = 0;
    reg [31:0] RAMFF = 0; 

    wire DHIT = !((XRD
            `ifdef __RMW_CYCLE__
                    ||XWR		// worst code ever! but it is 3:12am...
            `endif
                    ) && DTACK!=1); // the XWR operatio does not need ws. in this config.

    always@(posedge CLK) // stage #1.0
    begin
        DTACK <= RES ? 0 : DTACK ? DTACK-1 : (XRD
            `ifdef __RMW_CYCLE__
                    ||XWR		// 2nd worst code ever!
            `endif
                    ) ? 1 : 0; // wait-states

`ifdef __HARVARD__
        RAMFF <= RAM[XADDR[`MLEN-1:2]];
`else
        RAMFF <= MEM[XADDR[`MLEN-1:2]];
`endif

        //individual byte/word/long selection, thanks to HYF!

`ifdef __RMW_CYCLE__

        // read-modify-write operation w/ 1 wait-state:

        if(!HLT && XWR && CS0)
        begin
    `ifdef __HARVARD__
            RAM[XADDR[`MLEN-1:2]] <=
    `else
            MEM[XADDR[`MLEN-1:2]] <=
    `endif
                                {
                                    XBE[3] ? XATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8],
                                    XBE[2] ? XATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8],
                                    XBE[1] ? XATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8],
                                    XBE[0] ? XATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8]
                                };
        end

`else

    // write-only operation w/ 0 wait-states:

    `ifdef __HARVARD__
        if(!HLT && XWR && CS0 && XBE[3]) RAM[XADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= XATAO[3 * 8 + 7: 3 * 8];
        if(!HLT && XWR && CS0 && XBE[2]) RAM[XADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= XATAO[2 * 8 + 7: 2 * 8];
        if(!HLT && XWR && CS0 && XBE[1]) RAM[XADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= XATAO[1 * 8 + 7: 1 * 8];
        if(!HLT && XWR && CS0 && XBE[0]) RAM[XADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= XATAO[0 * 8 + 7: 0 * 8];
    `else
        if(!HLT && XWR && CS0 && XBE[3]) MEM[XADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= XATAO[3 * 8 + 7: 3 * 8];
        if(!HLT && XWR && CS0 && XBE[2]) MEM[XADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= XATAO[2 * 8 + 7: 2 * 8];
        if(!HLT && XWR && CS0 && XBE[1]) MEM[XADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= XATAO[1 * 8 + 7: 1 * 8];
        if(!HLT && XWR && CS0 && XBE[0]) MEM[XADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= XATAO[0 * 8 + 7: 0 * 8];
    `endif
`endif
    end

    assign XATAIMUX[0] = RAMFF;
    assign XDACKMUX[0] = DHIT;

    // io for debug

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

`ifdef __THREADS__
    wire   [7:0] CORE_ID = TPTR;                    // core id
`else
    wire   [7:0] CORE_ID = 0;                       // core id
`endif

    wire [31:0] UDATA; // uart data

    reg [31:0] TIMER = 0;

    reg XTIMER = 0;

    always@(posedge CLK)
    begin
        if(RES)
        begin
            IACK <= 0;
            TIMERFF <= (`BOARD_CK/1000000)-1; // timer set to 1MHz by default
        end
        else
        if(!HLT && CS1 && XWR)
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

        if(CS1 && XRD)
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
    assign XDACKMUX[1] = DHIT;

    assign BOARD_IRQ = IREQ^IACK;
    
    assign IRQ = |BOARD_IRQ;
    
`ifndef __TESTMODE__
    assign LED = LEDFF[3:0];
`endif

    // darkuart

    wire [3:0] UDEBUG;

    wire FINISH_REQ;

    darkuart
    uart0
    (
      .CLK(CLK),
      .RES(RES),
      .RD(!HLT && XRD && CS1 && XADDR[4:2]==1),
      .WR(!HLT && XWR && CS1 && XADDR[4:2]==1),
      .BE(XBE),
      .DATAI(XATAO),
      .DATAO(UDATA),
      .IRQ(UART_IRQ),

`ifndef __TESTMODE__
      .RXD(UART_RXD),
      .TXD(UART_TXD),
`endif		
`ifdef SIMULATION
      .FINISH_REQ(FINISH_REQ),
`endif
      .DEBUG(UDEBUG)
    );

    // sdram
    
`ifdef __SDRAM__

    // sdram interface, thanks to my good friend Hirosh Dabui!

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
        .valid      (CS2),
        .ready      (XDACKMUX[2]),

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

`endif
	 
    assign DEBUG = { XTIMER, KDEBUG[2:0] }; // UDEBUG;

`ifdef SIMULATION

    `ifdef __PERFMETER__

        integer clocks=0, running=0, load=0, store=0, flush=0, halt=0;

    `ifdef __THREADS__
        integer thread[0:(2**`__THREADS__)-1],curtptr=0,cnttptr=0;
        integer j;

        initial for(j=0;j!=(2**`__THREADS__);j=j+1) thread[j] = 0;
    `endif

        always@(posedge CLK)
        begin
            if(!RES)
            begin
                clocks = clocks+1;

                if(HLT)
                begin
                         if(XWR)	store = store+1;
                    else if(XRD)	load  = load +1;
                    else 		halt  = halt +1;
                end
                else
                if(IDLE)
                begin
                    flush=flush+1;
                end
                else
                begin

        `ifdef __THREADS__
                    for(j=0;j!=(2**`__THREADS__);j=j+1)
                            thread[j] = thread[j]+(j==TPTR?1:0);

                    if(TPTR!=curtptr)
                    begin
                        curtptr = TPTR;
                        cnttptr = cnttptr+1;
                    end
        `endif
                    running = running +1;
                end

                if(FINISH_REQ)
                begin
                    $display("****************************************************************************");
                    $display("DarkRISCV Pipeline Report (%0d clocks):",clocks);

                    $display("core0: %0d%% run, %0d%% wait (%0d%% i-bus, %0d%% d-bus/rd, %0d%% d-bus/wr), %0d%% idle",
                        100.0*running/clocks,
                        100.0*(load+store+halt)/clocks,
                        100.0*halt/clocks,
                        100.0*load/clocks,
                        100.0*store/clocks,
                        100.0*flush/clocks);

         `ifdef __THREADS__
                    for(j=0;j!=(2**`__THREADS__);j=j+1) $display("  thread%0d: %0d%% running",j,100.0*thread[j]/clocks);

                    $display("%0d thread switches, %0d clocks/threads",cnttptr,clocks/cnttptr);
         `endif
                    $display("****************************************************************************");
                    $finish();
                end
            end
        end
    `else
        always@(posedge CLK) if(FINISH_REQ) $finish();
    `endif

`endif

endmodule
