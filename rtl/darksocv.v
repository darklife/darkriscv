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

// the following defines are user defined:

//`define __ICACHE__              // instruction cache
//`define __DCACHE__              // data cache (bug: simulation only)
//`define __WAITSTATES__          // wait-state tests, no cache
`define __3STAGE__              // single phase 3-state pipeline 
`define __INTERRUPT__           // interrupt controller

// the board is automatically defined in the xst/xise files via 
// Makefile or ISE otherwise, please define you board name here:

//`define AVNET_MICROBOARD_LX9
//`define XILINX_AC701_A200
//`define QMTECH_SDRAM_LX16

// the following defines are automatically defined:

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

`ifdef AVNET_MICROBOARD_LX9
    `define BOARD_ID 1
    `define BOARD_CK 100000000
    
    // example of DCM logic:
    //
    //`define BOARD_CK_REF 66666666 
    //`define BOARD_CK_MUL 3
    //`define BOARD_CK_DIV 2
`endif

`ifdef XILINX_AC701_A200
    `define BOARD_ID 2
    //`define BOARD_CK 90000000
    `define BOARD_CK_REF 90000000 
    `define BOARD_CK_MUL 4
    `define BOARD_CK_DIV 2
`endif

`ifdef QMTECH_SDRAM_LX16
    `define BOARD_ID 3
    `define BOARD_CK 50000000
`endif

`ifndef BOARD_ID
    `define BOARD_ID 0    
    `define BOARD_CK 100000000   
`endif

module darksocv
(
    input        XCLK,      // external clock
    input        XRES,      // external reset
    
    input        UART_RXD,  // UART receive line
    output       UART_TXD,  // UART transmit line

    output [3:0] LED,       // on-board leds
    output [3:0] DEBUG      // osciloscope
);

    // internal/external reset logic

    reg [7:0] IRES = -1;

`ifdef QMTECH_SDRAM_LX16
    always@(posedge XCLK) IRES <= XRES==0 ? -1 : IRES[7] ? IRES-1 : 0; // reset low
`else
    always@(posedge XCLK) IRES <= XRES==1 ? -1 : IRES[7] ? IRES-1 : 0; // reset high
`endif

    // clock generator logic
    
`ifdef BOARD_CK_REF

    `define BOARD_CK (`BOARD_CK_REF * `BOARD_CK_MUL / `BOARD_CK_DIV)

    wire DCM_LOCKED;
    
    // useful script to calculate MUL/DIV values:
    // 
    // awk 'BEGIN { for(m=2;m<=32;m++) for(d=1;d<=32;d++) print 66.666*m/d,m,d }' | sort -n
    // 
    // example: reference w/ 66MHz, m=19, d=13 and fx=97.4MHz. not so useful after I discovered 
    // that my evaluation board already has external clock generator :D
    
   DCM_SP #(
      .CLKDV_DIVIDE(2.0),                   // CLKDV divide value
                                            // (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      .CLKFX_DIVIDE(`BOARD_CK_DIV),                     // Divide value on CLKFX outputs - D - (1-32)
      .CLKFX_MULTIPLY(`BOARD_CK_MUL),                   // Multiply value on CLKFX outputs - M - (2-32)
      .CLKIN_DIVIDE_BY_2("FALSE"),          // CLKIN divide by two (TRUE/FALSE)
      .CLKIN_PERIOD((1e9/`BOARD_CK_REF)),                  // Input clock period specified in nS
      .CLKOUT_PHASE_SHIFT("NONE"),          // Output phase shift (NONE, FIXED, VARIABLE)
      .CLK_FEEDBACK("1X"),                  // Feedback source (NONE, 1X, 2X)
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      .DFS_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DLL_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DSS_MODE("NONE"),                    // Unsupported - Do not change value
      .DUTY_CYCLE_CORRECTION("TRUE"),       // Unsupported - Do not change value
      .FACTORY_JF(16'hc080),                // Unsupported - Do not change value
      .PHASE_SHIFT(0),                      // Amount of fixed phase shift (-255 to 255)
      .STARTUP_WAIT("FALSE")                // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   DCM_SP_inst (
      //.CLK0(CLK0),         // 1-bit output: 0 degree clock output
      //.CLK180(CLK180),     // 1-bit output: 180 degree clock output
      //.CLK270(CLK270),     // 1-bit output: 270 degree clock output
      //.CLK2X(CLK2X),       // 1-bit output: 2X clock frequency clock output
      //.CLK2X180(CLK2X180), // 1-bit output: 2X clock frequency, 180 degree clock output
      //.CLK90(CLK90),       // 1-bit output: 90 degree clock output
      //.CLKDV(CLKDV),       // 1-bit output: Divided clock output
      .CLKFX(CLK),       // 1-bit output: Digital Frequency Synthesizer output (DFS)
      //.CLKFX180(CLKFX180), // 1-bit output: 180 degree CLKFX output
      .LOCKED(DCM_LOCKED),     // 1-bit output: DCM_SP Lock Output
      //.PSDONE(PSDONE),     // 1-bit output: Phase shift done output
      //.STATUS(STATUS),     // 8-bit output: DCM_SP status output
      //.CLKFB(CLKFB),       // 1-bit input: Clock feedback input
      .CLKIN(XCLK),       // 1-bit input: Clock input
      //.DSSEN(DSSEN),       // 1-bit input: Unsupported, specify to GND.
      //.PSCLK(PSCLK),       // 1-bit input: Phase shift clock input
      .PSEN(1'b0),         // 1-bit input: Phase shift enable
      //.PSINCDEC(PSINCDEC), // 1-bit input: Phase shift increment/decrement input
      .RST(IRES[7])            // 1-bit input: Active high reset input
   );

    reg [7:0] DRES = -1;
    
    always@(posedge CLK)
    begin    
        DRES <= DCM_LOCKED==0 ? -1 : DRES ? DRES-1 : 0;
    end

    wire RES = DRES[7];

`else    

    // when there is no need for a clock generator:

    wire CLK = XCLK;
    wire RES = IRES[7];    
`endif
    // ro/rw memories

    reg [31:0] ROM [0:1023]; // ro memory
    reg [31:0] RAM [0:1023]; // rw memory

    // memory initialization

    integer i;
    initial
    begin
        for(i=0;i!=1024;i=i+1)
        begin        
            ROM[i] = 32'd0;
            RAM[i] = 32'd0;
        end

        $readmemh("../src/darksocv.rom",ROM);        
        $readmemh("../src/darksocv.ram",RAM);
    end

    // darkriscv bus interface

    wire [31:0] IADDR;
    wire [31:0] DADDR;
    wire [31:0] IDATA;    
    wire [31:0] DATAO;        
    wire [31:0] DATAI;
    wire        WR,RD;
    wire [3:0]  BE;

    wire [31:0] IOMUX [0:3];

    reg  [15:0] GPIOFF = 0;
    reg  [15:0] LEDFF  = 0;
    
    wire HLT;
    
`ifdef __ICACHE__

    // instruction cache

    reg  [55:0] ICACHE [0:63]; // instruction cache
    reg  [63:0] ITAG = 0;      // instruction cache tag
    
    wire [5:0]  IPTR    = IADDR[7:2];
    wire [55:0] ICACHEO = ICACHE[IPTR];
    wire [31:0] ICACHED = ICACHEO[31: 0]; // data
    wire [31:8] ICACHEA = ICACHEO[55:32]; // address
    
    wire IHIT = ITAG[IPTR] && ICACHEA==IADDR[31:8];

    reg  IFFX = 0;
    reg IFFX2 = 0;
    
    reg [31:0] ROMFF;

    always@(posedge CLK)
    begin
        ROMFF <= ROM[IADDR[11:2]];

        if(IFFX2)
        begin
            IFFX2 <= 0;
            IFFX  <= 0;
        end
        else    
        if(!IHIT)
        begin
            ICACHE[IPTR] <= { IADDR[31:8], ROMFF };
            ITAG[IPTR]    <= IFFX; // cached!
            IFFX          <= 1;
            IFFX2         <= IFFX;
        end
    end

    assign IDATA = ICACHED;

`else

    reg [31:0] ROMFF;

`ifdef __WAITSTATES__
    
    reg [1:0] IHITACK = 0;
    
    wire IHIT = !(IHITACK!=1);
    
    always@(posedge CLK) // stage #1.0
    begin
        IHITACK <= RES ? 1 : IHITACK ? IHITACK-1 : 1; // wait-states
    end    
`else

    wire IHIT = 1;
    
`endif

    always@(posedge CLK) // stage #0.5    
    begin
        if(!HLT)
        begin
            ROMFF <= ROM[IADDR[11:2]];
        end
    end

    //assign IDATA = ROM[IADDR[11:2]];

//    always@(posedge CLK)
//    begin   
//        // weird bug appears to be related to the "sw ra,12(sp)" instruction.
//        if(WR&&DADDR[31]==0&&DADDR[12]==0)
//        begin
//            ROMBUG <= IADDR;
//        end
//    end
    
    assign IDATA = ROMFF;

`endif

`ifdef __DCACHE__

    // data cache

    reg  [55:0] DCACHE [0:63]; // data cache
    reg  [63:0] DTAG = 0;      // data cache tag

    wire [5:0]  DPTR    = DADDR[7:2];
    wire [55:0] DCACHEO = DCACHE[DPTR];
    wire [31:0] DCACHED = DCACHEO[31: 0]; // data
    wire [31:8] DCACHEA = DCACHEO[55:32]; // address

    wire DHIT = RD&&!DADDR[31]&&DADDR[12] ? DTAG[DPTR] && DCACHEA==DADDR[31:8] : 1;

    reg   FFX = 0;
    reg  FFX2 = 0;
    
    reg [31:0] RAMFF;    

    reg        WTAG    = 0;
    reg [31:0] WCACHEA = 0;
    
    wire WHIT = WR&&!DADDR[31]&&DADDR[12] ? WTAG&&WCACHEA==DADDR : 1;

    always@(posedge CLK)
    begin
        RAMFF <= RAM[DADDR[11:2]];

        if(FFX2)
        begin
            FFX2 <= 0;
            FFX  <= 0;
            WCACHEA <= 0;
            WTAG <= 0;
        end
        else
        if(!WHIT)
        begin
            //individual byte/word/long selection, thanks to HYF!
            if(BE[0]) RAM[DADDR[11:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
            if(BE[1]) RAM[DADDR[11:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
            if(BE[2]) RAM[DADDR[11:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
            if(BE[3]) RAM[DADDR[11:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];        

            DCACHE[DPTR][0 * 8 + 7: 0 * 8] <= BE[0] ? DATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8];
            DCACHE[DPTR][1 * 8 + 7: 1 * 8] <= BE[1] ? DATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8];
            DCACHE[DPTR][2 * 8 + 7: 2 * 8] <= BE[2] ? DATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8];
            DCACHE[DPTR][3 * 8 + 7: 3 * 8] <= BE[3] ? DATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8];

            DCACHE[DPTR][55:32] <= DADDR[31:8];
            
            //DCACHE[DPTR] <= { DADDR[31:8],
            //                        BE[3] ? DATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8],
            //                        BE[2] ? DATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8],
            //                        BE[1] ? DATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8],
            //                        BE[0] ? DATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8]
            //                };

            DTAG[DPTR]   <= FFX; // cached!
            WTAG         <= FFX;

            WCACHEA      <= DADDR;

            FFX          <= 1;
            FFX2         <= FFX;
        end
        else
        if(!DHIT)
        begin
            DCACHE[DPTR] <= { DADDR[31:8], RAMFF };
            DTAG[DPTR]   <= FFX; // cached!
            FFX          <= 1;
            FFX2         <= FFX;
        end        
    end
    
    assign DATAI = DADDR[31] ? IOMUX[DADDR[3:2]] : DCACHED;

`else

    // no cache!

    reg [31:0] RAMFF;
`ifdef __WAITSTATES__
    
    reg [1:0] DACK = 0;
    
    wire WHIT = 1;
    wire DHIT = !((WR||RD) && DACK!=1);
    
    always@(posedge CLK) // stage #1.0
    begin
        DACK <= RES ? 0 : DACK ? DACK-1 : (RD||WR) ? 1 : 0; // wait-states
    end

`elsif __3STAGE__

    // for single phase clock: 1 wait state in read op always required!

    reg [1:0] DACK = 0;
    
    wire WHIT = 1;
    wire DHIT = !((RD) && DACK!=1);
    
    always@(posedge CLK) // stage #1.0
    begin
        DACK <= RES ? 0 : DACK ? DACK-1 : (RD) ? 1 : 0; // wait-states
    end

`else

    // for dual phase clock: 0 wait state

    wire WHIT = 1;
    wire DHIT = 1;

`endif
    
    always@(posedge CLK) // stage #1.5
    begin
        RAMFF <= RAM[DADDR[11:2]];
    end

    //assign DATAI = DADDR[31] ? IOMUX  : RAM[DADDR[11:2]];
    
    always@(posedge CLK)
    begin    
        //if(WR&&DADDR[31]==0&&DADDR[12]==1)
        //begin
            //individual byte/word/long selection, thanks to HYF!
            if(WR&&DADDR[31]==0&&DADDR[12]==1&&BE[0]) RAM[DADDR[11:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
            if(WR&&DADDR[31]==0&&DADDR[12]==1&&BE[1]) RAM[DADDR[11:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
            if(WR&&DADDR[31]==0&&DADDR[12]==1&&BE[2]) RAM[DADDR[11:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
            if(WR&&DADDR[31]==0&&DADDR[12]==1&&BE[3]) RAM[DADDR[11:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        //end
    end    
    
    assign DATAI = DADDR[31] ? IOMUX[DADDR[3:2]]  : RAMFF;

`endif

    // io for debug

    reg IREQ = 0;
    reg IACK = 0;

    wire [7:0] BOARD_IRQ;

    wire   [7:0] BOARD_ID = `BOARD_ID;              // board id
    wire   [7:0] BOARD_CM = (`BOARD_CK/1000000);    // board clock (MHz)
    wire   [7:0] BOARD_CK = (`BOARD_CK/10000)%100;  // board clock (kHz)

    assign IOMUX[0] = { BOARD_IRQ, BOARD_CK, BOARD_CM, BOARD_ID };
    //assign IOMUX[1] = from UART!
    assign IOMUX[2] = { GPIOFF, LEDFF };
    assign IOMUX[3] = TIMERFF;

    reg [31:0] TIMER = 0;
    reg [31:0] TIMERFF = 0; // timer disabled

    reg XTIMER = 0;

    always@(posedge CLK)
    begin
        if(WR&&DADDR[31]&&DADDR[3:0]==4'b1000)
        begin
            LEDFF <= DATAO[15:0];
        end

        if(WR&&DADDR[31]&&DADDR[3:0]==4'b1010)
        begin
            GPIOFF <= DATAO[31:16];
        end

        if(RES)
            TIMERFF <= 0;
        else
        if(WR&&DADDR[31]&&DADDR[3:0]==4'b1100)
        begin
            TIMERFF <= DATAO[31:0];
        end
        
`ifdef __INTERRUPT__
        if(RES)
            IACK <= IREQ;
        else
        if(WR&&DADDR[31]&&DADDR[3:0]==4'b0011)
        begin
            IACK <= IREQ;
        end
        
        if(TIMERFF)
        begin        
            TIMER <= TIMER ? TIMER-1 : TIMERFF;
        
            if(TIMER==0)
            begin
                IREQ <= !IACK;
                XTIMER <= !XTIMER;
            end
        end
`endif        
    end

    assign BOARD_IRQ[7]   = IREQ^IACK;

    // unused irqs

    assign BOARD_IRQ[6:2] = 0;
    assign BOARD_IRQ[0]   = 0;

    assign HLT = !IHIT||!DHIT||!WHIT;

    // darkuart
  
    wire [3:0] UDEBUG;
    wire       UART_IRQ;

    darkuart
    #( 
      .BAUD((`BOARD_CK/115200))
    )
    uart0
    (
      .CLK(CLK),
      .RES(RES),
      .RD(!HLT&&RD&&DADDR[31]&&DADDR[3:2]==1),
      .WR(!HLT&&WR&&DADDR[31]&&DADDR[3:2]==1),
      .BE(BE),
      .DATAI(DATAO),
      .DATAO(IOMUX[1]),
      .IRQ(BOARD_IRQ[1]),
      .RXD(UART_RXD),
      .TXD(UART_TXD),
      .DEBUG(UDEBUG)
    );

    // darkriscv

    wire [3:0] KDEBUG;

    darkriscv
    #(
        .RESET_PC(32'h00000000),
        .RESET_SP(32'h00002000)
    ) 
    core0 
    (
`ifdef __3STAGE__
        .CLK(CLK),
`else
        .CLK(!CLK),
`endif
        .RES(RES),
        .HLT(HLT),
`ifdef __INTERRUPT__        
        .IREQ(IREQ^IACK),
`endif        
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
    $dumpfile("darksocv.vcd");
    $dumpvars(0, core0);
  end
`endif

    assign LED   = LEDFF[3:0];
    
    assign DEBUG = { GPIOFF[0], XTIMER, WR, RD }; // UDEBUG;

endmodule