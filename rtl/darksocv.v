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

    output [3:0] LED,       // on-board leds
    output [3:0] DEBUG      // osciloscope
);

    // internal/external reset logic

    reg [7:0] IRES = -1;

`ifdef INVRES
    always@(posedge XCLK) IRES <= XRES==0 ? -1 : IRES[7] ? IRES-1 : 0; // reset low
`else
    always@(posedge XCLK) IRES <= XRES==1 ? -1 : IRES[7] ? IRES-1 : 0; // reset high
`endif

    // clock generator logic
`ifdef BOARD_CK_REF

    //`define BOARD_CK (`BOARD_CK_REF * `BOARD_CK_MUL / `BOARD_CK_DIV)

    wire LOCKED, CLKFB, CLK;


    // useful script to calculate MUL/DIV values:
    //
    // awk 'BEGIN {
    //   ref=66.6; target=97.4;
    //   for(m=2;m<=32;m++) for(d=1;d<=32;d++) {
    //     mul=ref*m; delta=target-(mul/d);
    //     if(mul>=600&&mul<=1600) print (delta<0?-delta:delta),mul/d,mul,m,d;
    //   }
    // }' | sort -nr
    //
    // example: reference w/ 66MHz, m=19, d=13 and fx=97.4MHz;
    // not so useful after I discovered that my evaluation board already has an external clock generator :D
    //
    // important remark: the xilinx-7 pll requires a ref*mul bandwidth between 0.6 and 1.6GHz!

    `ifdef XILINX7CLK

       MMCME2_BASE #(
       .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
       .CLKFBOUT_MULT_F(`BOARD_CK_MUL),     // Multiply value for all CLKOUT (2.000-64.000).
       .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
       .CLKIN1_PERIOD((1e9/`BOARD_CK_REF)),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
       .CLKOUT0_DIVIDE_F(`BOARD_CK_DIV),    // Divide amount for CLKOUT0 (1.000-128.000).
       .CLKOUT1_DIVIDE(`BOARD_CK_DIV),
       .CLKOUT2_DIVIDE(`BOARD_CK_DIV),
       .CLKOUT3_DIVIDE(`BOARD_CK_DIV),
       .CLKOUT4_DIVIDE(`BOARD_CK_DIV),
       .CLKOUT5_DIVIDE(`BOARD_CK_DIV),
       .CLKOUT6_DIVIDE(`BOARD_CK_DIV),
       // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
       .CLKOUT0_DUTY_CYCLE(0.5),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .CLKOUT2_DUTY_CYCLE(0.5),
       .CLKOUT3_DUTY_CYCLE(0.5),
       .CLKOUT4_DUTY_CYCLE(0.5),
       .CLKOUT5_DUTY_CYCLE(0.5),
       .CLKOUT6_DUTY_CYCLE(0.5),
       // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
       .CLKOUT0_PHASE(0.0),
       .CLKOUT1_PHASE(0.0),
       .CLKOUT2_PHASE(0.0),
       .CLKOUT3_PHASE(0.0),
       .CLKOUT4_PHASE(0.0),
       .CLKOUT5_PHASE(0.0),
       .CLKOUT6_PHASE(0.0),
       .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
       .DIVCLK_DIVIDE(1),         // Master division value (1-106)
       .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
       .STARTUP_WAIT("TRUE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
    )
       MMCME2_BASE_inst (
           // Clock Outputs: 1-bit (each) output: User configurable clock outputs
           .CLKOUT0(CLK),     // 1-bit output: CLKOUT0
           //.CLKOUT0B(CLKOUT0B),   // 1-bit output: Inverted CLKOUT0
           //.CLKOUT1(CLKPWM),     // 1-bit output: CLKOUT1
           //.CLKOUT1B(CLKOUT1B),   // 1-bit output: Inverted CLKOUT1
           //.CLKOUT2(CLKOUT2),     // 1-bit output: CLKOUT2
           //.CLKOUT2B(CLKOUT2B),   // 1-bit output: Inverted CLKOUT2
           //.CLKOUT3(CLKOUT3),     // 1-bit output: CLKOUT3
           //.CLKOUT3B(CLKOUT3B),   // 1-bit output: Inverted CLKOUT3
           //.CLKOUT4(CLKOUT4),     // 1-bit output: CLKOUT4
           //.CLKOUT5(CLKOUT5),     // 1-bit output: CLKOUT5
           //.CLKOUT6(CLKOUT6),     // 1-bit output: CLKOUT6
           // Feedback Clocks: 1-bit (each) output: Clock feedback ports
           .CLKFBOUT(CLKFB),   // 1-bit output: Feedback clock
           //.CLKFBOUTB(CLKFBOUTB), // 1-bit output: Inverted CLKFBOUT
           // Status Ports: 1-bit (each) output: MMCM status ports
           .LOCKED(LOCKED),       // 1-bit output: LOCK
           // Clock Inputs: 1-bit (each) input: Clock input
           .CLKIN1(XCLK),       // 1-bit input: Clock
           // Control Ports: 1-bit (each) input: MMCM control ports
           .PWRDWN(1'b0),       // 1-bit input: Power-down
           .RST(IRES[7]),             // 1-bit input: Reset
           // Feedback Clocks: 1-bit (each) input: Clock feedback ports
           .CLKFBIN(CLKFB)      // 1-bit input: Feedback clock
        );

    `else

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
          .LOCKED(LOCKED),     // 1-bit output: DCM_SP Lock Output
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

    `endif

    reg [7:0] DRES = -1;

    always@(posedge CLK)
    begin
        DRES <= LOCKED==0 ? -1 : DRES ? DRES-1 : 0;
    end

    wire RES = DRES[7];

`else

// todo: rework of pll: XILINX7CLK, ...
`ifdef LATTICE_ECP5_PLL_REF25MHZ
    wire CLK;
    pll_ref_25MHz #(
      .freq(`BOARD_CK/1_000_000)
    ) ecp5_pll_I (
      .clki(XCLK),
      .clko(CLK)
    );
`elsif LATTICE_ICE40_BREAKOUT_HX8K
    pll pll_i // 12MHz in, 50 MHz out
    (
      .clock_in  (XCLK ),
      .clock_out (CLK),
      .locked    (locked)
    );
`else
    // when there is no need for a clock generator:
   wire CLK = XCLK;
`endif

   wire RES = IRES[7];

`endif
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
/*        for(i=0;i!=2**`MLEN/4;i=i+1)
        begin
            MEM[i] = 32'd0;
        end*/

        // workaround for vivado: no path in simulation and .mem extension

`ifdef XILINX_SIMULATOR
        $readmemh("darksocv.mem",MEM);
`else
        $readmemh("../src/darksocv.mem",MEM);
`endif
    end

`endif

    // darkriscv bus interface

    wire [31:0] IADDR;
    wire [31:0] DADDR;
    wire [31:0] IDATA;
    wire [31:0] DATAO;
    wire [31:0] DATAI;
    wire        WR,RD;
    wire [3:0]  BE;

`ifdef __FLEXBUZZ__
    wire [31:0] XATAO;
    wire [31:0] XATAI;
    wire [ 2:0] DLEN;
    wire        RW;
`endif

    wire [31:0] IOMUX [0:4];

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
    `ifdef __HARVARD__
        ROMFF <= ROM[IADDR[`MLEN-1:2]];
    `else
        ROMFF <= MEM[IADDR[`MLEN-1:2]];
    `endif
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


`ifdef __3STAGE__

    reg [31:0] ROMFF2 = 0;
    reg        HLT2   = 0;

    always@(posedge CLK) // stage #0.5
    begin
        if(HLT^HLT2)
        begin
            ROMFF2 <= ROMFF;
        end

        HLT2 <= HLT;
    end

    assign IDATA = HLT2 ? ROMFF2 : ROMFF;
`else
    assign IDATA = ROMFF;
`endif

    always@(posedge CLK) // stage #0.5
    begin
`ifdef __HARVARD__
        ROMFF <= ROM[IADDR[`MLEN-1:2]];
`else
        ROMFF <= MEM[IADDR[`MLEN-1:2]];
`endif
    end

    //assign IDATA = ROM[IADDR[`MLEN-1:2]];

//    always@(posedge CLK)
//    begin
//        // weird bug appears to be related to the "sw ra,12(sp)" instruction.
//        if(WR&&DADDR[31]==0&&DADDR[12]==0)
//        begin
//            ROMBUG <= IADDR;
//        end
//    end

//    assign IDATA = ROMFF;

`endif

`ifdef __DCACHE__

    // data cache

    reg  [55:0] DCACHE [0:63]; // data cache
    reg  [63:0] DTAG = 0;      // data cache tag

    wire [5:0]  DPTR    = DADDR[7:2];
    wire [55:0] DCACHEO = DCACHE[DPTR];
    wire [31:0] DCACHED = DCACHEO[31: 0]; // data
    wire [31:8] DCACHEA = DCACHEO[55:32]; // address

    wire DHIT = RD&&!DADDR[31]/*&&DADDR[`MLEN-1]*/ ? DTAG[DPTR] && DCACHEA==DADDR[31:8] : 1;

    reg   FFX = 0;
    reg  FFX2 = 0;

    reg [31:0] RAMFF;

    reg        WTAG    = 0;
    reg [31:0] WCACHEA = 0;

    wire WHIT = WR&&!DADDR[31]/*&&DADDR[`MLEN-1]*/ ? WTAG&&WCACHEA==DADDR : 1;

    always@(posedge CLK)
    begin
    `ifdef __HARVARD__
        RAMFF <= RAM[DADDR[`MLEN-1:2]];
    `else
        RAMFF <= MEM[DADDR[`MLEN-1:2]];
    `endif

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
        `ifdef __HARVARD__
            if(BE[0]) RAM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
            if(BE[1]) RAM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
            if(BE[2]) RAM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
            if(BE[3]) RAM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        `else
            if(BE[0]) MEM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
            if(BE[1]) MEM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
            if(BE[2]) MEM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
            if(BE[3]) MEM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        `endif
            DCACHE[DPTR][0 * 8 + 7: 0 * 8] <= BE[0] ? DATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8];
            DCACHE[DPTR][1 * 8 + 7: 1 * 8] <= BE[1] ? DATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8];
            DCACHE[DPTR][2 * 8 + 7: 2 * 8] <= BE[2] ? DATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8];
            DCACHE[DPTR][3 * 8 + 7: 3 * 8] <= BE[3] ? DATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8];

            DCACHE[DPTR][55:32] <= DADDR[31:8];

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

    assign DATAI = DADDR[31] ? IOMUX[DADDR[4:2]==3'b100 ? 3'b100 : DADDR[3:2]] : DCACHED;

`else

    // no cache!

    `ifdef __FLEXBUZZ__

    // must work just exactly as the default interface, since we have no
    // flexbuzz devices available yet (i.e., all devices are 32-bit now)

    assign XATAI = DLEN[0] ? ( DADDR[1:0]==3 ? DATAI[31:24] :
                               DADDR[1:0]==2 ? DATAI[23:16] :
                               DADDR[1:0]==1 ? DATAI[15: 8] :
                                               DATAI[ 7: 0] ):
                   DLEN[1] ? ( DADDR[1]==1   ? DATAI[31:16] :
                                               DATAI[15: 0] ):
                                               DATAI;

    assign DATAO = DLEN[0] ? ( DADDR[1:0]==3 ? {        XATAO[ 7: 0], 24'hx } :
                               DADDR[1:0]==2 ? {  8'hx, XATAO[ 7: 0], 16'hx } :
                               DADDR[1:0]==1 ? { 16'hx, XATAO[ 7: 0],  8'hx } :
                                               { 24'hx, XATAO[ 7: 0]        } ):
                   DLEN[1] ? ( DADDR[1]==1   ? { XATAO[15: 0], 16'hx } :
                                               { 16'hx, XATAO[15: 0] } ):
                                                 XATAO;

    assign RD = DLEN&&RW==1;
    assign WR = DLEN&&RW==0;

    assign BE =    DLEN[0] ? ( DADDR[1:0]==3 ? 4'b1000 : // 8-bit
                               DADDR[1:0]==2 ? 4'b0100 :
                               DADDR[1:0]==1 ? 4'b0010 :
                                               4'b0001 ) :
                   DLEN[1] ? ( DADDR[1]==1   ? 4'b1100 : // 16-bit
                                               4'b0011 ) :
                                               4'b1111;  // 32-bit

    `endif

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
    wire DHIT = !((RD
            `ifdef __RMW_CYCLE__
                    ||WR		// worst code ever! but it is 3:12am...
            `endif
                    ) && DACK!=1); // the WR operatio does not need ws. in this config.

    always@(posedge CLK) // stage #1.0
    begin
        DACK <= RES ? 0 : DACK ? DACK-1 : (RD
            `ifdef __RMW_CYCLE__
                    ||WR		// 2nd worst code ever!
            `endif
                    ) ? 1 : 0; // wait-states
    end

`else

    // for dual phase clock: 0 wait state

    wire WHIT = 1;
    wire DHIT = 1;

`endif

    always@(posedge CLK) // stage #1.5
    begin
`ifdef __HARVARD__
        RAMFF <= RAM[DADDR[`MLEN-1:2]];
`else
        RAMFF <= MEM[DADDR[`MLEN-1:2]];
`endif
    end

    //assign DATAI = DADDR[31] ? IOMUX  : RAM[DADDR[`MLEN-1:2]];

    reg [31:0] IOMUXFF = 0;
    reg [31:0] XADDR   = 0;

    //individual byte/word/long selection, thanks to HYF!

    always@(posedge CLK)
    begin

`ifdef __RMW_CYCLE__

        // read-modify-write operation w/ 1 wait-state:

        if(!HLT&&WR&&DADDR[31]==0/*&&DADDR[`MLEN-1]==1*/)
        begin
    `ifdef __HARVARD__
            RAM[DADDR[`MLEN-1:2]] <=
    `else
            MEM[DADDR[`MLEN-1:2]] <=
    `endif
                                {
                                    BE[3] ? DATAO[3 * 8 + 7: 3 * 8] : RAMFF[3 * 8 + 7: 3 * 8],
                                    BE[2] ? DATAO[2 * 8 + 7: 2 * 8] : RAMFF[2 * 8 + 7: 2 * 8],
                                    BE[1] ? DATAO[1 * 8 + 7: 1 * 8] : RAMFF[1 * 8 + 7: 1 * 8],
                                    BE[0] ? DATAO[0 * 8 + 7: 0 * 8] : RAMFF[0 * 8 + 7: 0 * 8]
                                };
        end

`else
        // write-only operation w/ 0 wait-states:
    `ifdef __HARVARD__
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[3]) RAM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[2]) RAM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[1]) RAM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[0]) RAM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
    `else
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[3]) MEM[DADDR[`MLEN-1:2]][3 * 8 + 7: 3 * 8] <= DATAO[3 * 8 + 7: 3 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[2]) MEM[DADDR[`MLEN-1:2]][2 * 8 + 7: 2 * 8] <= DATAO[2 * 8 + 7: 2 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[1]) MEM[DADDR[`MLEN-1:2]][1 * 8 + 7: 1 * 8] <= DATAO[1 * 8 + 7: 1 * 8];
        if(!HLT&&WR&&DADDR[31]==0&&/*DADDR[`MLEN-1]==1&&*/BE[0]) MEM[DADDR[`MLEN-1:2]][0 * 8 + 7: 0 * 8] <= DATAO[0 * 8 + 7: 0 * 8];
    `endif
`endif

        XADDR <= DADDR; // 1 clock delayed
        IOMUXFF <= IOMUX[DADDR[4:2]==3'b100 ? 3'b100 : DADDR[3:2]]; // read w/ 2 wait-states
    end

    //assign DATAI = DADDR[31] ? IOMUX[DADDR[3:2]]  : RAMFF;
    //assign DATAI = DADDR[31] ? IOMUXFF : RAMFF;
    assign DATAI = XADDR[31] ? IOMUX[XADDR[4:2]==3'b100 ? 3'b100 : XADDR[3:2]] : RAMFF;

`endif

    // io for debug

    reg [7:0] IREQ = 0;
    reg [7:0] IACK = 0;

    reg [31:0] TIMERFF = 0;
    reg [31:0] TIMEUS = 0;

    wire [7:0] BOARD_IRQ;

    wire   [7:0] BOARD_ID = `BOARD_ID;              // board id
    wire   [7:0] BOARD_CM = (`BOARD_CK/2000000);    // board clock (MHz)

`ifdef __THREADS__
    wire [`__THREADS__-1:0] TPTR;
    wire   [7:0] CORE_ID = TPTR;                    // core id
`else
    wire   [7:0] CORE_ID = 0;                       // core id
`endif

    assign IOMUX[0] = { BOARD_IRQ, CORE_ID, BOARD_CM, BOARD_ID };
    //assign IOMUX[1] = from UART!
    assign IOMUX[2] = { GPIOFF, LEDFF };
    assign IOMUX[3] = TIMERFF;
    assign IOMUX[4] = TIMEUS;

    reg [31:0] TIMER = 0;

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
            TIMERFF <= (`BOARD_CK/1000000)-1; // timer set to 1MHz by default
        else
        if(WR&&DADDR[31]&&DADDR[3:0]==4'b1100)
        begin
            TIMERFF <= DATAO[31:0];
        end

        if(RES)
            IACK <= 0;
        else
        if(WR&&DADDR[31]&&DADDR[3:0]==4'b0011)
        begin
            //$display("clear io.irq = %x (ireq=%x, iack=%x)",DATAO[32:24],IREQ,IACK);

            IACK[7] <= DATAO[7+24] ? IREQ[7] : IACK[7];
            IACK[6] <= DATAO[6+24] ? IREQ[6] : IACK[6];
            IACK[5] <= DATAO[5+24] ? IREQ[5] : IACK[5];
            IACK[4] <= DATAO[4+24] ? IREQ[4] : IACK[4];
            IACK[3] <= DATAO[3+24] ? IREQ[3] : IACK[3];
            IACK[2] <= DATAO[2+24] ? IREQ[2] : IACK[2];
            IACK[1] <= DATAO[1+24] ? IREQ[1] : IACK[1];
            IACK[0] <= DATAO[0+24] ? IREQ[0] : IACK[0];
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
    end

    assign BOARD_IRQ = IREQ^IACK;

    assign HLT = !IHIT||!DHIT||!WHIT;

    // darkuart

    wire [3:0] UDEBUG;

    wire FINISH_REQ;

    darkuart
//    #(
//      .BAUD((`BOARD_CK/115200))
//    )
    uart0
    (
      .CLK(CLK),
      .RES(RES),
      .RD(!HLT&&RD&&DADDR[31]&&DADDR[3:2]==1),
      .WR(!HLT&&WR&&DADDR[31]&&DADDR[3:2]==1),
      .BE(BE),
      .DATAI(DATAO),
      .DATAO(IOMUX[1]),
      //.IRQ(UART_IRQ),
      .RXD(UART_RXD),
      .TXD(UART_TXD),
`ifdef SIMULATION
      .FINISH_REQ(FINISH_REQ),
`endif
      .DEBUG(UDEBUG)
    );

    // darkriscv

    wire [3:0] KDEBUG;

    wire IDLE;

    darkriscv
//    #(
//        .RESET_PC(32'h00000000),
//        .RESET_SP(32'h00002000)
//    )
    core0
    (
`ifdef __3STAGE__
        .CLK(CLK),
`elsif  __WAITSTATES__
        .CLK(CLK),
`else
        .CLK(!CLK),
`endif
        .RES(RES),
        .HLT(HLT),
`ifdef __THREADS__
        .TPTR(TPTR),
`endif
`ifdef __INTERRUPT__
        .INT(|BOARD_IRQ),
`endif
        .IDATA(IDATA),
        .IADDR(IADDR),
        .DADDR(DADDR),

`ifdef __FLEXBUZZ__
        .DATAI(XATAI),
        .DATAO(XATAO),
        .DLEN(DLEN),
        .RW(RW),
`else
        .DATAI(DATAI),
        .DATAO(DATAO),
        .BE(BE),
        .WR(WR),
        .RD(RD),
`endif

        .IDLE(IDLE),

        .DEBUG(KDEBUG)
    );

    assign LED   = LEDFF[3:0];

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
                         if(WR)	store = store+1;
                    else if(RD)	load  = load +1;
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
