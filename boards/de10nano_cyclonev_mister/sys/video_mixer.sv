//
//
// Copyright (c) 2017,2021 Alexey Melnikov
//
// This program is GPL Licensed. See COPYING for the full license.
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

//
// LINE_LENGTH: Length of  display line in pixels
//              Usually it's length from HSync to HSync.
//              May be less if line_start is used.
//
// HALF_DEPTH:  If =1 then color dept is 4 bits per component
//
// altera message_off 10720 
// altera message_off 12161

module video_mixer
#(
	parameter LINE_LENGTH  = 768,
	parameter HALF_DEPTH   = 0,
	parameter GAMMA        = 0
)
(
	input            CLK_VIDEO, // should be multiple by (ce_pix*4)
	output reg       CE_PIXEL,  // output pixel clock enable

	input            ce_pix,    // input pixel clock or clock_enable

	input            scandoubler,
	input            hq2x, 	    // high quality 2x scaling

	inout     [21:0] gamma_bus,

	// color
	input [DWIDTH:0] R,
	input [DWIDTH:0] G,
	input [DWIDTH:0] B,

	// Positive pulses.
	input            HSync,
	input            VSync,
	input            HBlank,
	input            VBlank,

	// video output signals
	output reg [7:0] VGA_R,
	output reg [7:0] VGA_G,
	output reg [7:0] VGA_B,
	output reg       VGA_VS,
	output reg       VGA_HS,
	output reg       VGA_DE
);

localparam DWIDTH = HALF_DEPTH ? 3 : 7;
localparam DWIDTH_SD = GAMMA ? 7 : DWIDTH;
localparam HALF_DEPTH_SD = GAMMA ? 0 : HALF_DEPTH;

generate
	if(GAMMA && HALF_DEPTH) begin
		wire [7:0] R_in  = {R,R};
		wire [7:0] G_in  = {G,G};
		wire [7:0] B_in  = {B,B};
	end else begin
		wire [DWIDTH:0] R_in  = R;
		wire [DWIDTH:0] G_in  = G;
		wire [DWIDTH:0] B_in  = B;
	end
endgenerate


wire hs_g, vs_g;
wire hb_g, vb_g;
wire [DWIDTH_SD:0] R_gamma, G_gamma, B_gamma;

generate
	if(GAMMA) begin
		assign gamma_bus[21] = 1;
		gamma_corr gamma(
			.clk_sys(gamma_bus[20]),
			.clk_vid(CLK_VIDEO),
			.ce_pix(ce_pix),

			.gamma_en(gamma_bus[19]),
			.gamma_wr(gamma_bus[18]),
			.gamma_wr_addr(gamma_bus[17:8]),
			.gamma_value(gamma_bus[7:0]),

			.HSync(HSync),
			.VSync(VSync),
			.HBlank(HBlank),
			.VBlank(VBlank),
			.RGB_in({R_in,G_in,B_in}),

			.HSync_out(hs_g),
			.VSync_out(vs_g),
			.HBlank_out(hb_g),
			.VBlank_out(vb_g),
			.RGB_out({R_gamma,G_gamma,B_gamma})
		);
	end else begin
		assign gamma_bus[21] = 0;
		assign {R_gamma,G_gamma,B_gamma} = {R_in,G_in,B_in};
		assign {hs_g, vs_g, hb_g, vb_g} = {HSync, VSync, HBlank, VBlank};
	end
endgenerate

wire [DWIDTH_SD:0] R_sd;
wire [DWIDTH_SD:0] G_sd;
wire [DWIDTH_SD:0] B_sd;
wire hs_sd, vs_sd, hb_sd, vb_sd, ce_pix_sd;

scandoubler #(.LENGTH(LINE_LENGTH), .HALF_DEPTH(HALF_DEPTH_SD)) sd
(
	.clk_vid(CLK_VIDEO),
	.hq2x(hq2x),

	.ce_pix(ce_pix),
	.hs_in(hs_g),
	.vs_in(vs_g),
	.hb_in(hb_g),
	.vb_in(vb_g),
	.r_in(R_gamma),
	.g_in(G_gamma),
	.b_in(B_gamma),

	.ce_pix_out(ce_pix_sd),
	.hs_out(hs_sd),
	.vs_out(vs_sd),
	.hb_out(hb_sd),
	.vb_out(vb_sd),
	.r_out(R_sd),
	.g_out(G_sd),
	.b_out(B_sd)
);

wire [DWIDTH_SD:0] rt = (scandoubler ? R_sd : R_gamma);
wire [DWIDTH_SD:0] gt = (scandoubler ? G_sd : G_gamma);
wire [DWIDTH_SD:0] bt = (scandoubler ? B_sd : B_gamma);

always @(posedge CLK_VIDEO) begin
	reg [7:0] r,g,b;
	reg hde,vde,hs,vs, old_vs;
	reg old_hde;
	reg old_ce;
	reg ce_osc, fs_osc;
	
	old_ce <= ce_pix;
	ce_osc <= ce_osc | (old_ce ^ ce_pix);

	old_vs <= vs;
	if(~old_vs & vs) begin
		fs_osc <= ce_osc;
		ce_osc <= 0;
	end

	CE_PIXEL <= scandoubler ? ce_pix_sd : fs_osc ? (~old_ce & ce_pix) : ce_pix;

	if(!GAMMA && HALF_DEPTH) begin
		r <= {rt,rt};
		g <= {gt,gt};
		b <= {bt,bt};
	end
	else begin
		r <= rt;
		g <= gt;
		b <= bt;
	end

	hde <= scandoubler ? ~hb_sd : ~hb_g;
	vde <= scandoubler ? ~vb_sd : ~vb_g;
	vs  <= scandoubler ?  vs_sd :  vs_g;
	hs  <= scandoubler ?  hs_sd :  hs_g;

	if(CE_PIXEL) begin
		VGA_R <= r;
		VGA_G <= g;
		VGA_B <= b;

		VGA_VS <= vs;
		VGA_HS <= hs;

		old_hde <= hde;
		if(old_hde ^ hde) VGA_DE <= vde & hde;
	end
end

endmodule
