//============================================================================
//
//  Copyright (C) 2017-2020 Sorgelig
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
//============================================================================

//////////////////////////////////////////////////////////
// DW:
//  6 : 2R 2G 2B
//  8 : 3R 3G 2B
//  9 : 3R 3G 3B
// 12 : 4R 4G 4B
// 24 : 8R 8G 8B

module arcade_video #(parameter WIDTH=320, DW=8, GAMMA=1)
(
	input         clk_video,
	input         ce_pix,

	input[DW-1:0] RGB_in,
	input         HBlank,
	input         VBlank,
	input         HSync,
	input         VSync,

	output        CLK_VIDEO,
	output        CE_PIXEL,
	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,
	output  [1:0] VGA_SL,

	input   [2:0] fx,
	input         forced_scandoubler,
	inout  [21:0] gamma_bus
);

assign CLK_VIDEO = clk_video;

wire hs_fix,vs_fix;
sync_fix sync_v(CLK_VIDEO, HSync, hs_fix);
sync_fix sync_h(CLK_VIDEO, VSync, vs_fix);

reg [DW-1:0] RGB_fix;

reg CE,HS,VS,HBL,VBL;
always @(posedge CLK_VIDEO) begin
	reg old_ce;
	old_ce <= ce_pix;
	CE <= 0;
	if(~old_ce & ce_pix) begin
		CE <= 1;
		HS <= hs_fix;
		if(~HS & hs_fix) VS <= vs_fix;

		RGB_fix <= RGB_in;
		HBL <= HBlank;
		if(HBL & ~HBlank) VBL <= VBlank;
	end
end

wire [7:0] R,G,B;

generate
	if(DW == 6) begin
		assign R = {RGB_fix[5:4],RGB_fix[5:4],RGB_fix[5:4],RGB_fix[5:4]};
		assign G = {RGB_fix[3:2],RGB_fix[3:2],RGB_fix[3:2],RGB_fix[3:2]};
		assign B = {RGB_fix[1:0],RGB_fix[1:0],RGB_fix[1:0],RGB_fix[1:0]};
	end
	else if(DW == 8) begin
		assign R = {RGB_fix[7:5],RGB_fix[7:5],RGB_fix[7:6]};
		assign G = {RGB_fix[4:2],RGB_fix[4:2],RGB_fix[4:3]};
		assign B = {RGB_fix[1:0],RGB_fix[1:0],RGB_fix[1:0],RGB_fix[1:0]};
	end
	else if(DW == 9) begin
		assign R = {RGB_fix[8:6],RGB_fix[8:6],RGB_fix[8:7]};
		assign G = {RGB_fix[5:3],RGB_fix[5:3],RGB_fix[5:4]};
		assign B = {RGB_fix[2:0],RGB_fix[2:0],RGB_fix[2:1]};
	end
	else if(DW == 12) begin
		assign R = {RGB_fix[11:8],RGB_fix[11:8]};
		assign G = {RGB_fix[7:4],RGB_fix[7:4]};
		assign B = {RGB_fix[3:0],RGB_fix[3:0]};
	end
	else begin // 24
		assign R = RGB_fix[23:16];
		assign G = RGB_fix[15:8];
		assign B = RGB_fix[7:0];
	end
endgenerate

assign VGA_SL  = sl[1:0];
wire [2:0] sl = fx ? fx - 1'd1 : 3'd0;
wire scandoubler = fx || forced_scandoubler;

video_mixer #(.LINE_LENGTH(WIDTH+4), .HALF_DEPTH(DW!=24), .GAMMA(GAMMA)) video_mixer
(
	.CLK_VIDEO(CLK_VIDEO),
	.ce_pix(CE),
	.CE_PIXEL(CE_PIXEL),

	.scandoubler(scandoubler),
	.hq2x(fx==1),
	.gamma_bus(gamma_bus),

	.R((DW!=24) ? R[7:4] : R),
	.G((DW!=24) ? G[7:4] : G),
	.B((DW!=24) ? B[7:4] : B),

	.HSync (HS),
	.VSync (VS),
	.HBlank(HBL),
	.VBlank(VBL),

	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_VS(VGA_VS),
	.VGA_HS(VGA_HS),
	.VGA_DE(VGA_DE)
);

endmodule

//============================================================================
//
//  Screen +90/-90 deg. rotation
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
//============================================================================

module screen_rotate
(
	input         CLK_VIDEO,
	input         CE_PIXEL,

	input   [7:0] VGA_R,
	input   [7:0] VGA_G,
	input   [7:0] VGA_B,
	input         VGA_HS,
	input         VGA_VS,
	input         VGA_DE,

	input         rotate_ccw,
	input         no_rotate,

	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,

	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,
	output        DDRAM_RD
);

parameter MEM_BASE    = 7'b0010010; // buffer at 0x24000000, 3x8MB

assign DDRAM_CLK      = CLK_VIDEO;
assign DDRAM_BURSTCNT = 1;
assign DDRAM_ADDR     = {MEM_BASE, i_fb, ram_addr[22:3]};
assign DDRAM_BE       = ram_addr[2] ? 8'hF0 : 8'h0F;
assign DDRAM_DIN      = {ram_data,ram_data};
assign DDRAM_WE       = ram_wr;
assign DDRAM_RD       = 0;

assign FB_EN     = fb_en[2];
assign FB_FORMAT = 5'b00110;
assign FB_BASE   = {MEM_BASE,o_fb,23'd0};
assign FB_WIDTH  = vsz;
assign FB_HEIGHT = hsz;
assign FB_STRIDE = stride;

function [1:0] buf_next;
	input [1:0] a,b;
	begin
		buf_next = 1;
		if ((a==0 && b==1) || (a==1 && b==0)) buf_next = 2;
		if ((a==1 && b==2) || (a==2 && b==1)) buf_next = 0;
	end
endfunction

reg [1:0] i_fb,o_fb;
always @(posedge CLK_VIDEO) begin
	reg old_vbl,old_vs;
	old_vbl <= FB_VBL;
	old_vs <= VGA_VS;

	if(FB_LL) begin
		if(~old_vbl & FB_VBL) o_fb<={1'b0,~i_fb[0]};
		if(~old_vs & VGA_VS)  i_fb<={1'b0,~i_fb[0]};
	end
	else begin
		if(~old_vbl & FB_VBL) o_fb<=buf_next(o_fb,i_fb);
		if(~old_vs & VGA_VS)  i_fb<=buf_next(i_fb,o_fb);
	end
end

initial begin
	fb_en = 0;
end

reg  [2:0] fb_en = 0;
reg [11:0] hsz = 320, vsz = 240;
reg [11:0] bwidth;
reg [22:0] bufsize;
always @(posedge CLK_VIDEO) begin
	reg [11:0] hcnt = 0, vcnt = 0;
	reg old_vs, old_de;

	if(CE_PIXEL) begin
		old_vs <= VGA_VS;
		old_de <= VGA_DE;
		
		hcnt <= hcnt + 1'd1;
		if(~old_de & VGA_DE) begin
			hcnt <= 1;
			vcnt <= vcnt + 1'd1;
		end
		if(old_de & ~VGA_DE) hsz <= hcnt;
		if(~old_vs & VGA_VS) begin
			vsz <= vcnt;
			bwidth <= vcnt + 2'd3;
			vcnt <= 0;
			fb_en <= {fb_en[1:0], ~no_rotate};
		end
		if(old_vs & ~VGA_VS) bufsize <= hsz * stride;
	end
end

wire [13:0] stride = {bwidth[11:2], 4'd0};

reg [22:0] ram_addr, next_addr;
reg [31:0] ram_data;
reg        ram_wr;
always @(posedge CLK_VIDEO) begin
	reg [13:0] hcnt = 0;
	reg old_vs, old_de;

	ram_wr <= 0;
	if(CE_PIXEL) begin
		old_vs <= VGA_VS;
		old_de <= VGA_DE;

		if(~old_vs & VGA_VS) begin
			next_addr <= rotate_ccw ? (bufsize - stride) : {vsz-1'd1, 2'b00};
			hcnt <= rotate_ccw ? 3'd4 : {vsz-2'd2, 2'b00};
		end
		if(VGA_DE) begin
			ram_wr <= 1;
			ram_data <= {VGA_B,VGA_G,VGA_R};
			ram_addr <= next_addr;
			next_addr <= rotate_ccw ? (next_addr - stride) : (next_addr + stride);
		end
		if(old_de & ~VGA_DE) begin
			next_addr <= rotate_ccw ? (bufsize - stride + hcnt) : hcnt;
			hcnt <= rotate_ccw ? (hcnt + 3'd4) : (hcnt - 3'd4);
		end
	end
end

endmodule
