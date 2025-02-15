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

module darkpll
(
    input        XCLK,      // external clock
    input        XRES,      // external reset

    output       CLK,       // internal clock
    output       RES        // internal reset
);

    // internal/external reset logic

    reg [7:0] IRES = -1;

`ifdef INVRES
    always@(posedge XCLK) IRES <= XRES==0 ? -1 : IRES[7] ? IRES-1 : 0; // reset low
`else
    always@(posedge XCLK) IRES <= XRES==1 ? -1 : IRES[7] ? IRES-1 : 0; // reset high
`endif

    wire LOCKED;

    // clock generator logic
    //`define BOARD_CK (`BOARD_CK_REF * `BOARD_CK_MUL / `BOARD_CK_DIV)
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

    wire CLKFB;

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

`elsif XILINX6CLK

    wire CLKFB;

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

`elsif LATTICE_ECP5_PLL_REF25MHZ

    pll_ref_25MHz #(
        .freq(`BOARD_CK/1_000_000)
    ) ecp5_pll_I (
        .clki(XCLK),
        .clko(CLK)
    );
    
    assign LOCKED = 1;

`elsif LATTICE_ICE40_BREAKOUT_HX8K

    pll pll_i // 12MHz in, 50 MHz out
    (
        .clock_in  (XCLK),
        .clock_out (CLK),
        .locked    (LOCKED)
    );

`else

    // when there is no need for a clock generator:
    
   assign CLK = XCLK;
   assign LOCKED = !IRES[7];

`endif

    // here I use the CLK and LOCKED to drive RES

    reg [7:0] DRES = -1;

    always@(posedge CLK)
    begin
        DRES <= LOCKED==0 ? -1 : DRES ? DRES-1 : 0;
    end

    assign RES = DRES[7];

endmodule
