
//  3-tap IIR filter for 2 channels. 
//  Copyright (C) 2020 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

//
//  Can be converted to 2-tap (coeff_x2 = 0, coeff_y2 = 0) or 1-tap (coeff_x1,2 = 0, coeff_y1,2 = 0)
//
module IIR_filter
#(
	parameter use_params = 1,                     // set to 1 to use following parameters, 0 for input port variables.
	parameter stereo   =  1,                      // 0 for mono (input_l)

	parameter coeff_x  =  0.00000774701983513660, // Base gain value for X. Float. Range: 0.0 ... 0.999(9)
	parameter coeff_x0 =  3,                      // Gain scale factor for X0. Integer. Range -7 ... +7
	parameter coeff_x1 =  3,                      // Gain scale factor for X1. Integer. Range -7 ... +7
	parameter coeff_x2 =  1,                      // Gain scale factor for X2. Integer. Range -7 ... +7
	parameter coeff_y0 = -2.96438150626551080000, // Coefficient for Y0. Float. Range -3.999(9) ... 3.999(9)
	parameter coeff_y1 =  2.92939452735121100000, // Coefficient for Y1. Float. Range -3.999(9) ... 3.999(9)
	parameter coeff_y2 = -0.96500747158831091000  // Coefficient for Y2. Float. Range -3.999(9) ... 3.999(9)
)
(
	input         clk,
	input         reset,

	input         ce,        // must be double of calculated rate for stereo!
	input         sample_ce, // desired output sample rate

	input  [39:0] cx,
	input   [7:0] cx0,
	input   [7:0] cx1,
	input   [7:0] cx2,
	input  [23:0] cy0,
	input  [23:0] cy1,
	input  [23:0] cy2,

	input  [15:0] input_l,  input_r,  // signed samples
	output [15:0] output_l, output_r  // signed samples
);

localparam  [39:0] pcoeff_x  = coeff_x  * 40'h8000000000;
localparam  [31:0] pcoeff_y0 = coeff_y0 * 24'h200000;
localparam  [31:0] pcoeff_y1 = coeff_y1 * 24'h200000;
localparam  [31:0] pcoeff_y2 = coeff_y2 * 24'h200000;

wire [39:0] vcoeff    = use_params ? pcoeff_x        : cx;
wire [23:0] vcoeff_y0 = use_params ? pcoeff_y0[23:0] : cy0;
wire [23:0] vcoeff_y1 = use_params ? pcoeff_y1[23:0] : cy1;
wire [23:0] vcoeff_y2 = use_params ? pcoeff_y2[23:0] : cy2;

wire [59:0] inp_mul = $signed(inp) * $signed(vcoeff);

wire [39:0] x = inp_mul[59:20];
wire [39:0] y = x + tap0;

wire [39:0] tap0;
iir_filter_tap iir_tap_0
(
	.clk(clk),
	.reset(reset),
	.ce(ce),
	.ch(ch),
	.cx(use_params ? coeff_x0[7:0] : cx0),
	.cy(vcoeff_y0),
	.x(x),
	.y(y),
	.z(tap1),
	.tap(tap0)
);

wire [39:0] tap1;
iir_filter_tap iir_tap_1
(
	.clk(clk),
	.reset(reset),
	.ce(ce),
	.ch(ch),
	.cx(use_params ? coeff_x1[7:0] : cx1),
	.cy(vcoeff_y1),
	.x(x),
	.y(y),
	.z(tap2),
	.tap(tap1)
);

wire [39:0] tap2;
iir_filter_tap iir_tap_2
(
	.clk(clk),
	.reset(reset),
	.ce(ce),
	.ch(ch),
	.cx(use_params ? coeff_x2[7:0] : cx2),
	.cy(vcoeff_y2),
	.x(x),
	.y(y),
	.z(0),
	.tap(tap2)
);

wire [15:0] y_clamp = (~y[39] & |y[38:35]) ? 16'h7FFF : (y[39] & ~&y[38:35]) ? 16'h8000 : y[35:20];

reg        ch = 0;
reg [15:0] out_l, out_r, out_m;
reg [15:0] inp, inp_m;
always @(posedge clk) if (ce) begin
	if(!stereo) begin
		ch    <= 0;
		inp   <= input_l;
		out_l <= y_clamp;
		out_r <= y_clamp;
	end
	else begin
		ch <= ~ch;
		if(ch) begin
			out_m <= y_clamp;
			inp   <= inp_m;
		end
		else begin
			out_l <= out_m;
			out_r <= y_clamp;
			inp   <= input_l;
			inp_m <= input_r;
		end
	end
end

reg [31:0] out;
always @(posedge clk) if (sample_ce) out <= {out_l, out_r};

assign {output_l, output_r} = out;

endmodule

module iir_filter_tap
(
	input         clk,
	input         reset,

	input         ce,
	input         ch,

	input   [7:0] cx,
	input  [23:0] cy,

	input  [39:0] x,
	input  [39:0] y,
	input  [39:0] z,
	output [39:0] tap
);

wire signed [60:0] y_mul = $signed(y[36:0]) * $signed(cy);

function [39:0] x_mul;
	input [39:0] x;
begin
	x_mul = 0;
	if(cx[0]) x_mul =  x_mul + {{4{x[39]}}, x[39:4]};
	if(cx[1]) x_mul =  x_mul + {{3{x[39]}}, x[39:3]};
	if(cx[2]) x_mul =  x_mul + {{2{x[39]}}, x[39:2]};
	if(cx[7]) x_mul = ~x_mul; //cheap NEG
end
endfunction

(* ramstyle = "logic" *) reg [39:0] intreg[2];
always @(posedge clk, posedge reset) begin
	if(reset) {intreg[0],intreg[1]} <= 80'd0;
	else if(ce) intreg[ch] <= x_mul(x) - y_mul[60:21] + z;
end

assign tap = intreg[ch];

endmodule

// simplified IIR 1-tap.
module DC_blocker
(
	input         clk,
	input         ce, // 48/96 KHz
	input         mute,

	input         sample_rate,
	input  [15:0] din,
	output [15:0] dout
);

wire [39:0] x  = {din[15], din, 23'd0};
wire [39:0] x0 = x - (sample_rate ? {{11{x[39]}}, x[39:11]} : {{10{x[39]}}, x[39:10]});
wire [39:0] y1 = y - (sample_rate ? {{10{y[39]}}, y[39:10]} : {{09{y[39]}}, y[39:09]});
wire [39:0] y0 = x0 - x1 + y1;

reg  [39:0] x1, y;
always @(posedge clk) if(ce) begin
	x1 <= x0;
	y  <= ^y0[39:38] ? {{2{y0[39]}},{38{y0[38]}}} : y0;
end

assign dout = mute ? 16'd0 : y[38:23];

endmodule
