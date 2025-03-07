//============================================================================
//  Darkriscv port to MiSTer
//  Copyright (c) 2025 Nicolas Sauzede <nicolas.sauzede@gmail.com>
//
//  Heavily based on MiSTer Lesson1 tutorial (see below)
//============================================================================
//  Lesson1 port to MiSTer
//  Copyright (c) 2019 alanswx
//
//  This is a port from mist of the first lesson - how to display a checkerboard
//  on the screen. This works with the open source HDMI scaler, so it will work with
//  vga and HDMI. It also implements the OSD because with sorelig's sys library
//  lots of great functionality comes for free.
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [45:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM (USE_FB=1 in qsf)
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,
	output  [7:0] LEDS,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);


///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign USER_OUT = '1;
//assign {UART_RTS, UART_TXD, UART_DTR} = 0;
wire [7:0] the_8leds;
wire from_dut;
wire to_dut;
assign UART_TXD = from_dut;
assign to_dut = UART_RXD;
assign {UART_RTS, UART_DTR} = 0;
    dut dut1 (
        .clk(CLK_50M),
        .reset(RESET),
        .leds(the_8leds),
        .tx(from_dut),
        .rx(to_dut)
    );

assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;
assign {SDRAM_DQ, SDRAM_A, SDRAM_BA, SDRAM_CLK, SDRAM_CKE, SDRAM_DQML, SDRAM_DQMH, SDRAM_nWE, SDRAM_nCAS, SDRAM_nRAS, SDRAM_nCS} = 'Z;
assign {DDRAM_CLK, DDRAM_BURSTCNT, DDRAM_ADDR, DDRAM_DIN, DDRAM_BE, DDRAM_RD, DDRAM_WE} = '0;  

assign VGA_SL = 0;
assign VGA_F1 = 0;
assign VGA_SCALER = 0;

assign AUDIO_S = 0;
assign AUDIO_L = 0;
assign AUDIO_R = 0;
assign AUDIO_MIX = 0;

//assign LED_DISK = 0;
//assign LED_POWER = 0;
//assign LED_USER=0;
wire nreset;
assign nreset = ~(the_8leds == "R");
reg [31:0] BLINK = 0;
always @(posedge CLK_50M) begin
    BLINK <= ~nreset ? 0 : BLINK ? BLINK-1 : `BOARD_CK;
end
assign LED_USER = BLINK[24];
assign LED_POWER = {1'b1, BLINK[23]};
assign LED_DISK = { 1'b1, BLINK[22]};
//assign the_8leds = BLINK[29:22];
`ifdef TEST_MODE
wire test_mode;
assign test_mode = (the_8leds == "T");
assign LEDS = ~test_mode ? the_8leds : (BLINK < (`BOARD_CK/2)) ? -1 : 0;
`else
assign LEDS = the_8leds;
`endif

assign BUTTONS = 0;


//
// Aspect ratio
//

wire [1:0] ar = status[9:8];

assign VIDEO_ARX = (!ar) ? 12'd4 : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? 12'd3 : 12'd0;


//
// CONF_STR for OSD and other settings
//

`include "build_id.v"
localparam CONF_STR = {
	"darkriscv;;",
	"-;",
	"O89,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"-;",
	"-;",
	"-;",
	"J1,Red;",
	"jn,A;",
	"V,v",`BUILD_DATE

};

wire [31:0] joy;

//
// HPS is the module that communicates between the linux and fpga
//
wire [31:0] status;

hps_io #(.STRLEN(($size(CONF_STR)>>3)) , .PS2DIV(1000), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.status(status),
	.joystick_0(joy),
	.conf_str(CONF_STR)
	
);


///////////////////
//  PLL - clocks are the most important part of a system
///////////////////////////////////////////////////
wire clk_sys, locked;

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys), // 25.116279 Mhz - for the vga pixel clock
	.locked(locked)
);

///////////////////////////////////////////////////
wire [7:0] color = joy[4] ? 8'b000_111_00 : 8'hFF;

assign CLK_VIDEO = clk_sys;
assign CE_PIXEL = 1;
vga vga (
	 .color (color),
	 .pclk  (clk_sys),
	 .hs    (VGA_HS),
	 .vs    (VGA_VS),
	 .r     (VGA_R),
	 .g     (VGA_G),
	 .b     (VGA_B),
	 .VGA_DE(VGA_DE)
);
			
			

endmodule
