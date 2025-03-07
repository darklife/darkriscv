//============================================================================
//
//  MiSTer hardware abstraction module
//  (c)2017-2020 Alexey Melnikov
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

module sys_top
(
	/////////// CLOCK //////////
	input         FPGA_CLK1_50,
	input         FPGA_CLK2_50,
	input         FPGA_CLK3_50,

	//////////// HDMI //////////
	output        HDMI_I2C_SCL,
	inout         HDMI_I2C_SDA,

	output        HDMI_MCLK,
	output        HDMI_SCLK,
	output        HDMI_LRCLK,
	output        HDMI_I2S,

	output        HDMI_TX_CLK,
	output        HDMI_TX_DE,
	output [23:0] HDMI_TX_D,
	output        HDMI_TX_HS,
	output        HDMI_TX_VS,
	
	input         HDMI_TX_INT,

	//////////// SDR ///////////
	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
	output        SDRAM_CKE,

`ifdef MISTER_DUAL_SDRAM
	////////// SDR #2 //////////
	output [12:0] SDRAM2_A,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nWE,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nCS,
	output  [1:0] SDRAM2_BA,
	output        SDRAM2_CLK,

`else
	//////////// VGA ///////////
	output  [5:0] VGA_R,
	output  [5:0] VGA_G,
	output  [5:0] VGA_B,
	inout         VGA_HS,  // VGA_HS is secondary SD card detect when VGA_EN = 1 (inactive)
	output		  VGA_VS,
	input         VGA_EN,  // active low

	/////////// AUDIO //////////
	output		  AUDIO_L,
	output		  AUDIO_R,
	output		  AUDIO_SPDIF,

	//////////// SDIO ///////////
	inout   [3:0] SDIO_DAT,
	inout         SDIO_CMD,
	output        SDIO_CLK,

	//////////// I/O ///////////
	output        LED_USER,
	output        LED_HDD,
	output        LED_POWER,
	input         BTN_USER,
	input         BTN_OSD,
	input         BTN_RESET,
`endif

	////////// I/O ALT /////////
	output        SD_SPI_CS,
	input         SD_SPI_MISO,
	output        SD_SPI_CLK,
	output        SD_SPI_MOSI,

	inout         SDCD_SPDIF,
	output        IO_SCL,
	inout         IO_SDA,

	////////// ADC //////////////
	output        ADC_SCK,
	input         ADC_SDO,
	output        ADC_SDI,
	output        ADC_CONVST,

	////////// MB KEY ///////////
	input   [1:0] KEY,

	////////// MB SWITCH ////////
	input   [3:0] SW,

	////////// MB LED ///////////
	output  [7:0] LED,

	///////// USER IO ///////////
	inout   [6:0] USER_IO
);

//////////////////////  Secondary SD  ///////////////////////////////////
wire SD_CS, SD_CLK, SD_MOSI;

`ifndef MISTER_DUAL_SDRAM
	wire sd_miso = SW[3] | SDIO_DAT[0];
`else
	wire sd_miso = 1;
`endif
wire SD_MISO = mcp_sdcd ? sd_miso : SD_SPI_MISO;

`ifndef MISTER_DUAL_SDRAM
	assign SDIO_DAT[2:1]= 2'bZZ;
	assign SDIO_DAT[3]  = SW[3] ? 1'bZ  : SD_CS;
	assign SDIO_CLK     = SW[3] ? 1'bZ  : SD_CLK;
	assign SDIO_CMD     = SW[3] ? 1'bZ  : SD_MOSI;
	assign SD_SPI_CS    = mcp_sdcd ? ((~VGA_EN & sog & ~cs1) ? 1'b1 : 1'bZ) : SD_CS;
`else
	assign SD_SPI_CS    = mcp_sdcd ? 1'bZ : SD_CS;
`endif

assign SD_SPI_CLK  = mcp_sdcd ? 1'bZ : SD_CLK;
assign SD_SPI_MOSI = mcp_sdcd ? 1'bZ : SD_MOSI;

//////////////////////  LEDs/Buttons  ///////////////////////////////////

reg [7:0] led_overtake = 0;
reg [7:0] led_state    = 0;

wire led_p =  led_power[1] ? ~led_power[0] : 1'b0;
wire led_d =  led_disk[1]  ? ~led_disk[0]  : ~(led_disk[0] | gp_out[29]);
wire led_u = ~led_user;
wire led_locked;

`ifndef MISTER_DUAL_SDRAM
	assign LED_POWER = (SW[3] | led_p) ? 1'bZ : 1'b0;
	assign LED_HDD   = (SW[3] | led_d) ? 1'bZ : 1'b0;
	assign LED_USER  = (SW[3] | led_u) ? 1'bZ : 1'b0;
`endif

//LEDs on main board
//assign LED = (led_overtake & led_state) | (~led_overtake & {1'b0,led_locked,1'b0, ~led_p, 1'b0, ~led_d, 1'b0, ~led_u});
assign LED = leds;

wire btn_r, btn_o, btn_u;
`ifdef MISTER_DUAL_SDRAM
	assign {btn_r,btn_o,btn_u} = {mcp_btn[1],mcp_btn[2],mcp_btn[0]};
`else
	assign {btn_r,btn_o,btn_u} = ~{BTN_RESET,BTN_OSD,BTN_USER} | {mcp_btn[1],mcp_btn[2],mcp_btn[0]};
`endif

wire [2:0] mcp_btn;
wire       mcp_sdcd;
mcp23009 mcp23009
(
	.clk(FPGA_CLK2_50),

	.btn(mcp_btn),
	.led({led_p, led_d, led_u}),
	.sd_cd(mcp_sdcd),

	.scl(IO_SCL),
	.sda(IO_SDA)
);


reg btn_user, btn_osd;
always @(posedge FPGA_CLK2_50) begin
	integer div;
	reg [7:0] deb_user;
	reg [7:0] deb_osd;

	div <= div + 1'b1;
	if(div > 100000) div <= 0;

	if(!div) begin
		deb_user <= {deb_user[6:0], btn_u | ~KEY[1]};
		if(&deb_user) btn_user <= 1;
		if(!deb_user) btn_user <= 0;

		deb_osd <= {deb_osd[6:0], btn_o | ~KEY[0]};
		if(&deb_osd) btn_osd <= 1;
		if(!deb_osd) btn_osd <= 0;
	end
end

/////////////////////////  HPS I/O  /////////////////////////////////////

// gp_in[31] = 0 - quick flag that FPGA is initialized (HPS reads 1 when FPGA is not in user mode)
//                 used to avoid lockups while JTAG loading
wire [31:0] gp_in = {1'b0, btn_user | btn[1], btn_osd | btn[0], SW[3], 8'd0, io_ver, io_ack, io_wide, io_dout};
wire [31:0] gp_out;

wire  [1:0] io_ver = 1; // 0 - obsolete. 1 - optimized HPS I/O. 2,3 - reserved for future.
wire        io_wait;
wire        io_wide;
wire [15:0] io_dout;                  
wire [15:0] io_din = gp_outr[15:0];
wire        io_clk = gp_outr[17];
wire        io_ss0 = gp_outr[18];
wire        io_ss1 = gp_outr[19];
wire        io_ss2 = gp_outr[20];

`ifndef MISTER_DEBUG_NOHDMI
wire io_osd_hdmi = io_ss1 & ~io_ss0;
`endif

wire io_fpga     = ~io_ss1 & io_ss0;
wire io_uio      = ~io_ss1 & io_ss2;

reg  io_ack;
reg  rack;
wire io_strobe = ~rack & io_clk;

always @(posedge clk_sys) begin
	if(~(io_wait | vs_wait) | io_strobe) begin
		rack <= io_clk;
		io_ack <= rack;
	end
end

reg [31:0] gp_outr;
always @(posedge clk_sys) begin
	reg [31:0] gp_outd;
	gp_outr <= gp_outd;
	gp_outd <= gp_out;
end

`ifdef MISTER_DUAL_SDRAM
	wire  [7:0] core_type  = 'hA8; // generic core, dual SDRAM.
`else
	wire  [7:0] core_type  = 'hA4; // generic core.
`endif

// HPS will not communicate to core if magic is different
wire [31:0] core_magic = {24'h5CA623, core_type};

cyclonev_hps_interface_mpu_general_purpose h2f_gp
(
	.gp_in({~gp_out[31] ? core_magic : gp_in}),
	.gp_out(gp_out)
);


reg [15:0] cfg;

reg        cfg_set      = 0;
wire       vga_fb       = cfg[12] | vga_force_scaler;
wire [1:0] hdmi_limited = {cfg[11],cfg[8]};

`ifdef MISTER_DEBUG_NOHDMI
wire       direct_video = 1;
`else
wire       direct_video = cfg[10];
`endif

wire       dvi_mode     = cfg[7];
wire       audio_96k    = cfg[6];
wire       csync_en     = cfg[3];
wire       ypbpr_en     = cfg[5];
wire       io_osd_vga   = io_ss1 & ~io_ss2;
`ifndef MISTER_DUAL_SDRAM
	wire    sog          = cfg[9];
	wire    vga_scaler   = cfg[2] | vga_force_scaler;
`endif

reg        cfg_custom_t = 0;
reg  [5:0] cfg_custom_p1;
reg [31:0] cfg_custom_p2;

reg  [4:0] vol_att = 0;

reg  [6:0] coef_addr;
reg  [8:0] coef_data;
reg        coef_wr = 0;

wire[12:0] ARX, ARY;
reg [11:0] VSET = 0, HSET = 0;
reg        FREESCALE = 0;
reg  [2:0] scaler_flt;
reg        lowlat = 0;
reg        cfg_dis = 0;

reg        vs_wait = 0;
reg [11:0] vs_line = 0;

reg        scaler_out = 0;

reg [31:0] aflt_rate = 7056000;
reg [39:0] acx  = 4258969;
reg  [7:0] acx0 = 3;
reg  [7:0] acx1 = 3;
reg  [7:0] acx2 = 1;
reg [23:0] acy0 = -24'd6216759;
reg [23:0] acy1 =  24'd6143386;
reg [23:0] acy2 = -24'd2023767;
reg        areset = 0;
reg [12:0] arc1x = 0;
reg [12:0] arc1y = 0;
reg [12:0] arc2x = 0;
reg [12:0] arc2y = 0;

always@(posedge clk_sys) begin
	reg  [7:0] cmd;
	reg        has_cmd;
	reg        old_strobe;
	reg  [7:0] cnt = 0;
	reg        vs_d0,vs_d1,vs_d2;
	reg  [4:0] acx_att;

	old_strobe <= io_strobe;
	coef_wr <= 0;

	if(~io_uio) begin
		has_cmd <= 0;
		cmd <= 0;
		areset <= 0;
		acx_att <= 0;
		acx <= acx >> acx_att;
	end
	else
	if(~old_strobe & io_strobe) begin
		if(!has_cmd) begin
			has_cmd <= 1;
			cmd <= io_din[7:0];
			cnt <= 0;
			if(io_din[7:0] == 'h30) vs_wait <= 1;
			if(io_din[7:0] == 'h39) begin
				aflt_rate <= 7056000;
				acx  <= 4258969;
				acx0 <= 3;
				acx1 <= 3;
				acx2 <= 1;
				acy0 <= -24'd6216759;
				acy1 <=  24'd6143386;
				acy2 <= -24'd2023767;
				areset <= 1;
			end
		end
		else begin
			if(cmd == 1) begin
				cfg <= io_din;
				cfg_set <= 1;
				scaler_out <= 1;
			end
			if(cmd == 'h20) begin
				cfg_set <= 0;
				cnt <= cnt + 1'd1;
				if(cnt<8) begin
					case(cnt[2:0])
						0: if(WIDTH  != io_din[11:0]) WIDTH  <= io_din[11:0];
						1: if(HFP    != io_din[11:0]) HFP    <= io_din[11:0];
						2: if(HS     != io_din[11:0]) HS     <= io_din[11:0];
						3: if(HBP    != io_din[11:0]) HBP    <= io_din[11:0];
						4: if(HEIGHT != io_din[11:0]) HEIGHT <= io_din[11:0];
						5: if(VFP    != io_din[11:0]) VFP    <= io_din[11:0];
						6: if(VS     != io_din[11:0]) VS     <= io_din[11:0];
						7: if(VBP    != io_din[11:0]) VBP    <= io_din[11:0];
					endcase
`ifndef MISTER_DEBUG_NOHDMI
					if(cnt == 1) begin
						cfg_custom_p1 <= 0;
						cfg_custom_p2 <= 0;
						cfg_custom_t <= ~cfg_custom_t;
					end
				end
				else begin
					if(cnt[1:0]==0) cfg_custom_p1 <= io_din[5:0];
					if(cnt[1:0]==1) cfg_custom_p2[15:0]  <= io_din;
					if(cnt[1:0]==2) begin
						cfg_custom_p2[31:16] <= io_din;
						cfg_custom_t <= ~cfg_custom_t;
						cnt[2:0] <= 3'b100;
					end
					if(cnt == 8) {lowlat,cfg_dis} <= io_din[15:14];
`endif
				end
			end
			if(cmd == 'h2F) begin
				cnt <= cnt + 1'd1;
				case(cnt[3:0])
					0: {LFB_EN,LFB_FLT,LFB_FMT} <= {io_din[15], io_din[14], io_din[5:0]};
					1: LFB_BASE[15:0]  <= io_din[15:0];
					2: LFB_BASE[31:16] <= io_din[15:0];
					3: LFB_WIDTH       <= io_din[11:0];
					4: LFB_HEIGHT      <= io_din[11:0];
					5: LFB_HMIN        <= io_din[11:0];
					6: LFB_HMAX        <= io_din[11:0];
					7: LFB_VMIN        <= io_din[11:0];
					8: LFB_VMAX        <= io_din[11:0];
					9: LFB_STRIDE      <= io_din[13:0];
				endcase
			end
			if(cmd == 'h25) {led_overtake, led_state} <= io_din;
			if(cmd == 'h26) vol_att <= io_din[4:0];
			if(cmd == 'h27) VSET <= io_din[11:0];
			if(cmd == 'h2A) {coef_wr,coef_addr,coef_data} <= {1'b1,io_din};
			if(cmd == 'h2B) scaler_flt <= io_din[2:0];
			if(cmd == 'h37) {FREESCALE,HSET} <= {io_din[15],io_din[11:0]};
			if(cmd == 'h38) vs_line <= io_din[11:0];
			if(cmd == 'h39) begin
				cnt <= cnt + 1'd1;
				case(cnt[3:0])
					 0: acx_att          <= io_din[4:0];
					 1: aflt_rate[15:0]  <= io_din;
					 2: aflt_rate[31:16] <= io_din;
					 3: acx[15:0]        <= io_din;
					 4: acx[31:16]       <= io_din;
					 5: acx[39:32]       <= io_din[7:0];
					 6: acx0             <= io_din[7:0];
					 7: acx1             <= io_din[7:0];
					 8: acx2             <= io_din[7:0];
					 9: acy0[15:0]       <= io_din;
					10: acy0[23:16]      <= io_din[7:0];
					11: acy1[15:0]       <= io_din;
					12: acy1[23:16]      <= io_din[7:0];
					13: acy2[15:0]       <= io_din;
					14: acy2[23:16]      <= io_din[7:0];
				endcase
			end
			if(cmd == 'h3A) begin
				cnt <= cnt + 1'd1;
				case(cnt[3:0])
					 0: arc1x <= io_din[12:0];
					 1: arc1y <= io_din[12:0];
					 2: arc2x <= io_din[12:0];
					 3: arc2y <= io_din[12:0];
				endcase
			end
		end
	end

	vs_d0 <= HDMI_TX_VS;
	if(vs_d0 == HDMI_TX_VS) vs_d1 <= vs_d0;

	vs_d2 <= vs_d1;
	if(~vs_d2 & vs_d1) vs_wait <= 0;
end

cyclonev_hps_interface_peripheral_uart uart
(
	.ri(0),
	.dsr(uart_dsr),
	.dcd(uart_dsr),
	.dtr(uart_dtr),

	.cts(uart_cts),
	.rts(uart_rts),
	.rxd(uart_rxd),
	.txd(uart_txd)
);

wire aspi_sck,aspi_mosi,aspi_ss,aspi_miso;
cyclonev_hps_interface_peripheral_spi_master spi
(
	.sclk_out(aspi_sck),
	.txd(aspi_mosi), // mosi
	.rxd(aspi_miso), // miso

	.ss_0_n(aspi_ss),
	.ss_in_n(1)
);

wire [63:0] f2h_irq = {video_sync,HDMI_TX_VS};
cyclonev_hps_interface_interrupts interrupts
(
	.irq(f2h_irq)
);

///////////////////////////  RESET  ///////////////////////////////////

reg reset_req = 0;
always @(posedge FPGA_CLK2_50) begin
	reg [1:0] resetd, resetd2;
	reg       old_reset;

	//latch the reset
	old_reset <= reset;
	if(~old_reset & reset) reset_req <= 1;

	//special combination to set/clear the reset
	//preventing of accidental reset control
	if(resetd==1) reset_req <= 1;
	if(resetd==2 && resetd2==0) reset_req <= 0;

	resetd  <= gp_out[31:30];
	resetd2 <= resetd;
end

////////////////////  SYSTEM MEMORY & SCALER  /////////////////////////

wire reset;
wire clk_100m;

sysmem_lite sysmem
(
	//Reset/Clock
	.reset_core_req(reset_req),
	.reset_out(reset),
	.clock(clk_100m),

	//DE10-nano has no reset signal on GPIO, so core has to emulate cold reset button.
	.reset_hps_cold_req(btn_r),

	//64-bit DDR3 RAM access
	.ram1_clk(ram_clk),
	.ram1_address(ram_address),
	.ram1_burstcount(ram_burstcount),
	.ram1_waitrequest(ram_waitrequest),
	.ram1_readdata(ram_readdata),
	.ram1_readdatavalid(ram_readdatavalid),
	.ram1_read(ram_read),
	.ram1_writedata(ram_writedata),
	.ram1_byteenable(ram_byteenable),
	.ram1_write(ram_write),

	//64-bit DDR3 RAM access
	.ram2_clk(clk_audio),
	.ram2_address(ram2_address),
	.ram2_burstcount(ram2_burstcount),
	.ram2_waitrequest(ram2_waitrequest),
	.ram2_readdata(ram2_readdata),
	.ram2_readdatavalid(ram2_readdatavalid),
	.ram2_read(ram2_read),
	.ram2_writedata(ram2_writedata),
	.ram2_byteenable(ram2_byteenable),
	.ram2_write(ram2_write),

	//128-bit DDR3 RAM access
	// HDMI frame buffer
	.vbuf_clk(clk_100m),
	.vbuf_address(vbuf_address),
	.vbuf_burstcount(vbuf_burstcount),
	.vbuf_waitrequest(vbuf_waitrequest),
	.vbuf_writedata(vbuf_writedata),
	.vbuf_byteenable(vbuf_byteenable),
	.vbuf_write(vbuf_write),
	.vbuf_readdata(vbuf_readdata),
	.vbuf_readdatavalid(vbuf_readdatavalid),
	.vbuf_read(vbuf_read)
);

wire [28:0] ram2_address;
wire  [7:0] ram2_burstcount;
wire  [7:0] ram2_byteenable;
wire        ram2_waitrequest;
wire [63:0] ram2_readdata;
wire [63:0] ram2_writedata;
wire        ram2_readdatavalid;
wire        ram2_read;
wire        ram2_write;
wire  [7:0] ram2_bcnt;

ddr_svc ddr_svc
(
	.clk(clk_audio),

	.ram_waitrequest(ram2_waitrequest),
	.ram_burstcnt(ram2_burstcount),
	.ram_addr(ram2_address),
	.ram_readdata(ram2_readdata),
	.ram_read_ready(ram2_readdatavalid),
	.ram_read(ram2_read),
	.ram_writedata(ram2_writedata),
	.ram_byteenable(ram2_byteenable),
	.ram_write(ram2_write),
	.ram_bcnt(ram2_bcnt),

	.ch0_addr(alsa_address),
	.ch0_burst(1),
	.ch0_data(alsa_readdata),
	.ch0_req(alsa_req),
	.ch0_ready(alsa_ready),

	.ch1_addr(pal_addr),
	.ch1_burst(128),
	.ch1_data(pal_data),
	.ch1_req(pal_req),
	.ch1_ready(pal_wr)
);

wire clk_pal = clk_audio;


wire  [27:0] vbuf_address;
wire   [7:0] vbuf_burstcount;
wire         vbuf_waitrequest;
wire [127:0] vbuf_readdata;
wire         vbuf_readdatavalid;
wire         vbuf_read;
wire [127:0] vbuf_writedata;
wire  [15:0] vbuf_byteenable;
wire         vbuf_write;

wire  [23:0] hdmi_data;
wire         hdmi_vs, hdmi_hs, hdmi_de, hdmi_vbl;

`ifndef MISTER_DEBUG_NOHDMI
wire clk_hdmi  = hdmi_clk_out;

ascal 
#(
	.RAMBASE(32'h20000000),
`ifndef MISTER_FB
	.PALETTE2("false"),
`else
	`ifndef MISTER_FB_PALETTE
		.PALETTE2("false"),
	`endif
`endif
	.N_DW(128),
	.N_AW(28)
)
ascal
(
	.reset_na (~reset_req),
	.run      (1),
	.freeze   (0),

	.i_clk    (clk_ihdmi),
	.i_ce     (ce_hpix),
	.i_r      (hr_out),
	.i_g      (hg_out),
	.i_b      (hb_out),
	.i_hs     (hhs_fix),
	.i_vs     (hvs_fix),
	.i_fl     (f1),
	.i_de     (hde_emu),
	.iauto    (1),
	.himin    (0),
	.himax    (0),
	.vimin    (0),
	.vimax    (0),

	.o_clk    (clk_hdmi),
	.o_ce     (scaler_out),
	.o_r      (hdmi_data[23:16]),
	.o_g      (hdmi_data[15:8]),
	.o_b      (hdmi_data[7:0]),
	.o_hs     (hdmi_hs),
	.o_vs     (hdmi_vs),
	.o_de     (hdmi_de),
	.o_vbl    (hdmi_vbl),
	.o_lltune (lltune),
	.htotal   (WIDTH + HFP + HBP + HS),
	.hsstart  (WIDTH + HFP),
	.hsend    (WIDTH + HFP + HS),
	.hdisp    (WIDTH),
	.hmin     (hmin),
	.hmax     (hmax),
	.vtotal   (HEIGHT + VFP + VBP + VS),
	.vsstart  (HEIGHT + VFP),
	.vsend    (HEIGHT + VFP + VS),
	.vdisp    (HEIGHT),
	.vmin     (vmin),
	.vmax     (vmax),

	.mode     ({~lowlat,LFB_EN ? LFB_FLT : |scaler_flt,2'b00}),
	.poly_clk (clk_sys),
	.poly_a   (coef_addr),
	.poly_dw  (coef_data),
	.poly_wr  (coef_wr),

	.pal1_clk (clk_pal),
	.pal1_dw  (pal_d),
	.pal1_a   (pal_a),
	.pal1_wr  (pal_wr),

`ifdef MISTER_FB
	`ifdef MISTER_FB_PALETTE
		.pal2_clk (fb_pal_clk),
		.pal2_dw  (fb_pal_d),
		.pal2_dr  (fb_pal_q),
		.pal2_a   (fb_pal_a),
		.pal2_wr  (fb_pal_wr),
		.pal_n    (fb_en),
	`endif
`endif

	.o_fb_ena         (FB_EN),
	.o_fb_hsize       (FB_WIDTH),
	.o_fb_vsize       (FB_HEIGHT),
	.o_fb_format      (FB_FMT),
	.o_fb_base        (FB_BASE),
	.o_fb_stride      (FB_STRIDE),

	.avl_clk          (clk_100m),
	.avl_waitrequest  (vbuf_waitrequest),
	.avl_readdata     (vbuf_readdata),
	.avl_readdatavalid(vbuf_readdatavalid),
	.avl_burstcount   (vbuf_burstcount),
	.avl_writedata    (vbuf_writedata),
	.avl_address      (vbuf_address),
	.avl_write        (vbuf_write),
	.avl_read         (vbuf_read),
	.avl_byteenable   (vbuf_byteenable)
);
`endif

reg        LFB_EN     = 0;
reg        LFB_FLT    = 0;
reg  [5:0] LFB_FMT    = 0;
reg [11:0] LFB_WIDTH  = 0;
reg [11:0] LFB_HEIGHT = 0;
reg [11:0] LFB_HMIN   = 0;
reg [11:0] LFB_HMAX   = 0;
reg [11:0] LFB_VMIN   = 0;
reg [11:0] LFB_VMAX   = 0;
reg [31:0] LFB_BASE   = 0;
reg [13:0] LFB_STRIDE = 0;

reg        FB_EN     = 0;
reg  [5:0] FB_FMT    = 0;
reg [11:0] FB_WIDTH  = 0;
reg [11:0] FB_HEIGHT = 0;
reg [31:0] FB_BASE   = 0;
reg [13:0] FB_STRIDE = 0;

always @(posedge clk_sys) begin
	FB_EN <= LFB_EN | fb_en;
	if(LFB_EN) begin
		FB_FMT    <= LFB_FMT;
		FB_WIDTH  <= LFB_WIDTH;
		FB_HEIGHT <= LFB_HEIGHT;
		FB_BASE   <= LFB_BASE;
		FB_STRIDE <= LFB_STRIDE;
	end
	else begin
		FB_FMT    <= fb_fmt;
		FB_WIDTH  <= fb_width;
		FB_HEIGHT <= fb_height;
		FB_BASE   <= fb_base;
		FB_STRIDE <= fb_stride;
	end
end

`ifdef MISTER_FB
reg fb_vbl;
always @(posedge clk_vid) fb_vbl <= hdmi_vbl;
`endif

reg  ar_md_start;
wire ar_md_busy;
reg  [11:0] ar_md_mul1, ar_md_mul2, ar_md_div;
wire [11:0] ar_md_res;

sys_umuldiv #(12,12,12) ar_muldiv
(
	.clk(clk_vid),
	.start(ar_md_start),
	.busy(ar_md_busy),

	.mul1(ar_md_mul1),
	.mul2(ar_md_mul2),
	.div(ar_md_div),
	.result(ar_md_res)
);

reg [11:0] hmin;
reg [11:0] hmax;
reg [11:0] vmin;
reg [11:0] vmax;
reg [11:0] hdmi_height;
reg [11:0] hdmi_width;

always @(posedge clk_vid) begin
	reg [11:0] hmini,hmaxi,vmini,vmaxi;
	reg [11:0] wcalc,videow,arx;
	reg [11:0] hcalc,videoh,ary;
	reg  [2:0] state;
	reg        xy;

	hdmi_height <= (VSET && (VSET < HEIGHT)) ? VSET : HEIGHT;
	hdmi_width  <= (HSET && (HSET < WIDTH))  ? HSET : WIDTH;

	if(!ARY) begin
		if(ARX == 1) begin
			arx <= arc1x[11:0];
			ary <= arc1y[11:0];
			xy  <= arc1x[12] | arc1y[12];
		end
		else if(ARX == 2) begin
			arx <= arc2x[11:0];
			ary <= arc2y[11:0];
			xy  <= arc2x[12] | arc2y[12];
		end
		else begin
			arx <= 0;
			ary <= 0;
			xy  <= 0;
		end
	end
	else begin
		arx <= ARX[11:0];
		ary <= ARY[11:0];
		xy  <= ARX[12] | ARY[12];
	end
	
	ar_md_start <= 0;
	state <= state + 1'd1;
	case(state)
		0: if(LFB_EN) begin
				hmini <= LFB_HMIN;
				vmini <= LFB_VMIN;
				hmaxi <= LFB_HMAX;
				vmaxi <= LFB_VMAX;
				state <= 0;
			end
			else if(FREESCALE || !arx || !ary) begin
				wcalc <= hdmi_width;
				hcalc <= hdmi_height;
				state <= 6;
			end
			else if(xy) begin
				wcalc <= arx;
				hcalc <= ary;
				state <= 6;
			end

		1: begin
				ar_md_mul1 <= hdmi_height;
				ar_md_mul2 <= arx;
				ar_md_div  <= ary;
				ar_md_start<= 1;
			end
		2: begin
				wcalc <= ar_md_res;
				if(ar_md_start | ar_md_busy) state <= 2;
			end

		3: begin
				ar_md_mul1 <= hdmi_width;
				ar_md_mul2 <= ary;
				ar_md_div  <= arx;
				ar_md_start<= 1;
			end
		4: begin
				hcalc <= ar_md_res;
				if(ar_md_start | ar_md_busy) state <= 4;
			end

		6: begin
				videow <= (wcalc > hdmi_width)  ? hdmi_width  : wcalc[11:0];
				videoh <= (hcalc > hdmi_height) ? hdmi_height : hcalc[11:0];
			end

		7: begin
				hmini <= ((WIDTH  - videow)>>1);
				hmaxi <= ((WIDTH  - videow)>>1) + videow - 1'd1;
				vmini <= ((HEIGHT - videoh)>>1);
				vmaxi <= ((HEIGHT - videoh)>>1) + videoh - 1'd1;
			end
	endcase
	
	hmin <= hmini;
	hmax <= hmaxi;
	vmin <= vmini;
	vmax <= vmaxi;
end

`ifndef MISTER_DEBUG_NOHDMI
wire [15:0] lltune;
pll_hdmi_adj pll_hdmi_adj
(
	.clk(FPGA_CLK1_50),
	.reset_na(~reset_req),

	.llena(lowlat),
	.lltune({16{hdmi_config_done | cfg_dis}} & lltune),
	.locked(led_locked),
	.i_waitrequest(adj_waitrequest),
	.i_write(adj_write),
	.i_address(adj_address),
	.i_writedata(adj_data),
	.o_waitrequest(cfg_waitrequest),
	.o_write(cfg_write),
	.o_address(cfg_address),
	.o_writedata(cfg_data)
);
`else
	assign led_locked = 0;
`endif

wire [63:0] pal_data;
wire [47:0] pal_d = {pal_data[55:32], pal_data[23:0]};
wire  [6:0] pal_a = ram2_bcnt[6:0];
wire        pal_wr;

reg  [28:0] pal_addr;
reg         pal_req = 0;
always @(posedge clk_pal) begin
	reg old_vs1, old_vs2;

	pal_addr <= LFB_BASE[31:3] - 29'd512;

	old_vs1 <= hdmi_vs;
	old_vs2 <= old_vs1;
	
	if(~old_vs2 & old_vs1 & ~FB_FMT[2] & FB_FMT[1] & FB_FMT[0] & FB_EN) pal_req <= ~pal_req;
end


/////////////////////////  HDMI output  /////////////////////////////////
`ifndef MISTER_DEBUG_NOHDMI
wire hdmi_clk_out;
pll_hdmi pll_hdmi
(
	.refclk(FPGA_CLK1_50),
	.rst(reset_req),
	.reconfig_to_pll(reconfig_to_pll),
	.reconfig_from_pll(reconfig_from_pll),
	.outclk_0(hdmi_clk_out)
);
`endif

//1920x1080@60 PCLK=148.5MHz CEA
reg  [11:0] WIDTH  = 1920;
reg  [11:0] HFP    = 88;
reg  [11:0] HS     = 48;
reg  [11:0] HBP    = 148;
reg  [11:0] HEIGHT = 1080;
reg  [11:0] VFP    = 4;
reg  [11:0] VS     = 5;
reg  [11:0] VBP    = 36;

wire [63:0] reconfig_to_pll;
wire [63:0] reconfig_from_pll;
wire        cfg_waitrequest,adj_waitrequest;
wire        cfg_write;
wire  [5:0] cfg_address;
wire [31:0] cfg_data;
reg         adj_write;
reg   [5:0] adj_address;
reg  [31:0] adj_data;

`ifndef MISTER_DEBUG_NOHDMI
pll_cfg pll_cfg
(
	.mgmt_clk(FPGA_CLK1_50),
	.mgmt_reset(reset_req),
	.mgmt_waitrequest(cfg_waitrequest),
	.mgmt_read(0),
	.mgmt_readdata(),
	.mgmt_write(cfg_write),
	.mgmt_address(cfg_address),
	.mgmt_writedata(cfg_data),
	.reconfig_to_pll(reconfig_to_pll),
	.reconfig_from_pll(reconfig_from_pll)
);

reg cfg_got = 0;
always @(posedge clk_sys) begin
	reg vsd, vsd2;
	if(~cfg_ready || ~cfg_set) cfg_got <= cfg_set;
	else begin
		vsd  <= HDMI_TX_VS;
		vsd2 <= vsd;
		if(~vsd2 & vsd) cfg_got <= cfg_set;
	end
end

reg cfg_ready = 0;
always @(posedge FPGA_CLK1_50) begin
	reg gotd = 0, gotd2 = 0;
	reg custd = 0, custd2 = 0;
	reg old_wait = 0;

	gotd  <= cfg_got;
	gotd2 <= gotd;
	
	adj_write <= 0;
	
	custd <= cfg_custom_t;
	custd2 <= custd;
	if(custd2 != custd & ~gotd) begin
		adj_address <= cfg_custom_p1;
		adj_data <= cfg_custom_p2;
		adj_write <= 1;
	end

	if(~gotd2 & gotd) begin
		adj_address <= 2;
		adj_data <= 0;
		adj_write <= 1;
	end

	old_wait <= adj_waitrequest;
	if(old_wait & ~adj_waitrequest & gotd) cfg_ready <= 1;
end

`else

wire cfg_ready = 1;

`endif

wire hdmi_config_done;
hdmi_config hdmi_config
(
	.iCLK(FPGA_CLK1_50),
	.iRST_N(cfg_ready & ~HDMI_TX_INT & ~cfg_dis),
	.done(hdmi_config_done),

	.I2C_SCL(HDMI_I2C_SCL),
	.I2C_SDA(HDMI_I2C_SDA),

	.dvi_mode(dvi_mode),
	.audio_96k(audio_96k),
	.limited(hdmi_limited),
	.ypbpr(ypbpr_en & direct_video)
);

assign HDMI_I2C_SCL = hdmi_scl_en ? 1'b0 : 1'bZ;
assign HDMI_I2C_SDA = hdmi_sda_en ? 1'b0 : 1'bZ;

wire hdmi_scl_en, hdmi_sda_en;
cyclonev_hps_interface_peripheral_i2c hdmi_i2c
(
	.out_clk(hdmi_scl_en),
	.scl(HDMI_I2C_SCL),
	.out_data(hdmi_sda_en),
	.sda(HDMI_I2C_SDA)
);

`ifndef MISTER_DEBUG_NOHDMI
wire [23:0] hdmi_data_sl;
wire        hdmi_de_sl, hdmi_vs_sl, hdmi_hs_sl;

`ifdef MISTER_FB
reg dis_output;
always @(posedge clk_hdmi) begin
	reg dis;
	dis <= fb_force_blank;
	dis_output <= dis;
end
`else
wire dis_output = 0;
`endif

scanlines #(1) HDMI_scanlines
(
	.clk(clk_hdmi),

	.scanlines(scanlines),
	.din(dis_output ? 24'd0 : hdmi_data),
	.hs_in(hdmi_hs),
	.vs_in(hdmi_vs),
	.de_in(hdmi_de),
	
	.dout(hdmi_data_sl),
	.hs_out(hdmi_hs_sl),
	.vs_out(hdmi_vs_sl),
	.de_out(hdmi_de_sl)
);

wire [23:0] hdmi_data_osd;
wire        hdmi_de_osd, hdmi_vs_osd, hdmi_hs_osd;

osd hdmi_osd
(
	.clk_sys(clk_sys),

	.io_osd(io_osd_hdmi),
	.io_strobe(io_strobe),
	.io_din(io_din),

	.clk_video(clk_hdmi),
	.din(hdmi_data_sl),
	.hs_in(hdmi_hs_sl),
	.vs_in(hdmi_vs_sl),
	.de_in(hdmi_de_sl),

	.dout(hdmi_data_osd),
	.hs_out(hdmi_hs_osd),
	.vs_out(hdmi_vs_osd),
	.de_out(hdmi_de_osd)
);
`endif

wire hdmi_cs_osd;
csync csync_hdmi(clk_hdmi, hdmi_hs_osd, hdmi_vs_osd, hdmi_cs_osd);

reg [23:0] dv_data;
reg        dv_hs, dv_vs, dv_de;
always @(posedge clk_vid) begin
	reg [23:0] dv_d1, dv_d2;
	reg        dv_de1, dv_de2, dv_hs1, dv_hs2, dv_vs1, dv_vs2;
	reg [12:0] vsz, vcnt;
	reg        old_hs, old_vs;
	reg        vde;
	reg  [3:0] hss;

	if(ce_pix) begin
		hss <= (hss << 1) | vga_hs_osd;

		old_hs <= vga_hs_osd;
		if(~old_hs && vga_hs_osd) begin
			old_vs <= vga_vs_osd;
			if(~&vcnt) vcnt <= vcnt + 1'd1;
			if(~old_vs & vga_vs_osd & ~f1) vsz <= vcnt;
			if(old_vs & ~vga_vs_osd) vcnt <= 0;
			
			if(vcnt == 1) vde <= 1;
			if(vcnt == vsz - 3) vde <= 0;
		end

		dv_de1 <= !{hss,vga_hs_osd} && vde;
		dv_hs1 <= csync_en ? vga_cs_osd : vga_hs_osd;
		dv_vs1 <= vga_vs_osd;
	end

	dv_d1  <= vga_data_osd;
	dv_d2  <= dv_d1;
	dv_de2 <= dv_de1;
	dv_hs2 <= dv_hs1;
	dv_vs2 <= dv_vs1;

	dv_data<= dv_d2;
	dv_de  <= dv_de2;
	dv_hs  <= dv_hs2;
	dv_vs  <= dv_vs2;
end

wire hdmi_tx_clk;
`ifndef MISTER_DEBUG_NOHDMI
cyclonev_clkselect hdmi_clk_sw
( 
	.clkselect({1'b1, ~vga_fb & direct_video}),
	.inclk({clk_vid, hdmi_clk_out, 2'b00}),
	.outclk(hdmi_tx_clk)
);
`else
assign hdmi_tx_clk = clk_vid;
`endif

altddio_out
#(
	.extend_oe_disable("OFF"),
	.intended_device_family("Cyclone V"),
	.invert_output("OFF"),
	.lpm_hint("UNUSED"),
	.lpm_type("altddio_out"),
	.oe_reg("UNREGISTERED"),
	.power_up_high("OFF"),
	.width(1)
)
hdmiclk_ddr
(
	.datain_h(1'b0),
	.datain_l(1'b1),
	.outclock(hdmi_tx_clk),
	.dataout(HDMI_TX_CLK),
	.aclr(1'b0),
	.aset(1'b0),
	.oe(1'b1),
	.outclocken(1'b1),
	.sclr(1'b0),
	.sset(1'b0)
);

reg hdmi_out_hs;
reg hdmi_out_vs;
reg hdmi_out_de;
reg [23:0] hdmi_out_d;

always @(posedge hdmi_tx_clk) begin
	reg hs,vs,de;
	reg [23:0] d;
	
	hs <= (~vga_fb & direct_video) ? dv_hs   : (direct_video & csync_en) ? hdmi_cs_osd : hdmi_hs_osd;
	vs <= (~vga_fb & direct_video) ? dv_vs   : hdmi_vs_osd;
	de <= (~vga_fb & direct_video) ? dv_de   : hdmi_de_osd;
	d  <= (~vga_fb & direct_video) ? dv_data : hdmi_data_osd;

	hdmi_out_hs <= hs;
	hdmi_out_vs <= vs;
	hdmi_out_de <= de;
	hdmi_out_d  <= d;
end

assign HDMI_TX_HS = hdmi_out_hs;
assign HDMI_TX_VS = hdmi_out_vs;
assign HDMI_TX_DE = hdmi_out_de;
assign HDMI_TX_D  = hdmi_out_d;

/////////////////////////  VGA output  //////////////////////////////////

wire [23:0] vga_data_sl;
wire        vga_de_sl, vga_vs_sl, vga_hs_sl;
scanlines #(0) VGA_scanlines
(
	.clk(clk_vid),

	.scanlines(scanlines),
	.din(de_emu ? {r_out, g_out, b_out} : 24'd0),
	.hs_in(hs_fix),
	.vs_in(vs_fix),
	.de_in(de_emu),

	.dout(vga_data_sl),
	.hs_out(vga_hs_sl),
	.vs_out(vga_vs_sl),
	.de_out(vga_de_sl)
);

wire [23:0] vga_data_osd;
wire        vga_vs_osd, vga_hs_osd;
osd vga_osd
(
	.clk_sys(clk_sys),

	.io_osd(io_osd_vga),
	.io_strobe(io_strobe),
	.io_din(io_din),
	.osd_status(osd_status),

	.clk_video(clk_vid),
	.din(vga_data_sl),
	.hs_in(vga_hs_sl),
	.vs_in(vga_vs_sl),
	.de_in(vga_de_sl),

	.dout(vga_data_osd),
	.hs_out(vga_hs_osd),
	.vs_out(vga_vs_osd)
);

wire vga_cs_osd;
csync csync_vga(clk_vid, vga_hs_osd, vga_vs_osd, vga_cs_osd);

`ifndef MISTER_DUAL_SDRAM
	wire [23:0] vgas_o;
	wire vgas_hs, vgas_vs, vgas_cs;
	vga_out vga_scaler_out
	(
		.clk(clk_hdmi),
		.ypbpr_en(ypbpr_en),
		.hsync(hdmi_hs_osd),
		.vsync(hdmi_vs_osd),
		.csync(hdmi_cs_osd),
		.dout(vgas_o),
		.din({24{hdmi_de_osd}} & hdmi_data_osd),
		.hsync_o(vgas_hs),
		.vsync_o(vgas_vs),
		.csync_o(vgas_cs)
	);

	wire [23:0] vga_o;
	wire vga_hs, vga_vs, vga_cs;
	vga_out vga_out
	(
		.clk(clk_vid),
		.ypbpr_en(ypbpr_en),
		.hsync(vga_hs_osd),
		.vsync(vga_vs_osd),
		.csync(vga_cs_osd),
		.dout(vga_o),
		.din(vga_data_osd),
		.hsync_o(vga_hs),
		.vsync_o(vga_vs),
		.csync_o(vga_cs)
	);

	wire cs1 = (vga_fb | vga_scaler) ? vgas_cs : vga_cs;

	assign VGA_VS = (VGA_EN | SW[3]) ? 1'bZ      : ((vga_fb | vga_scaler) ? ~vgas_vs : ~vga_vs) | csync_en;
	assign VGA_HS = (VGA_EN | SW[3]) ? 1'bZ      :  (vga_fb | vga_scaler) ? (csync_en ? ~vgas_cs : ~vgas_hs) : (csync_en ? ~vga_cs : ~vga_hs);
	assign VGA_R  = (VGA_EN | SW[3]) ? 6'bZZZZZZ :  (vga_fb | vga_scaler) ? vgas_o[23:18] : vga_o[23:18];
	assign VGA_G  = (VGA_EN | SW[3]) ? 6'bZZZZZZ :  (vga_fb | vga_scaler) ? vgas_o[15:10] : vga_o[15:10];
	assign VGA_B  = (VGA_EN | SW[3]) ? 6'bZZZZZZ :  (vga_fb | vga_scaler) ? vgas_o[7:2]   : vga_o[7:2]  ;
`endif

reg video_sync = 0;
always @(posedge clk_vid) begin
	reg [11:0] line_cnt  = 0;
	reg [11:0] sync_line = 0;
	reg  [1:0] hs_cnt = 0;
	reg        old_hs;

	old_hs <= hs_fix;
	if(~old_hs & hs_fix) begin

		video_sync <= (sync_line == line_cnt);

		line_cnt <= line_cnt + 1'd1;
		if(~hs_cnt[1]) begin	
			hs_cnt <= hs_cnt + 1'd1;
			if(hs_cnt[0]) begin
				sync_line <= (line_cnt - vs_line);
				line_cnt <= 0;
			end
		end
	end

	if(de_emu) hs_cnt <= 0;
end

/////////////////////////  Audio output  ////////////////////////////////

assign SDCD_SPDIF =(SW[3] & ~spdif) ? 1'b0 : 1'bZ;

`ifndef MISTER_DUAL_SDRAM
	wire analog_l, analog_r;

	assign AUDIO_SPDIF = SW[3] ? 1'bZ : SW[0] ? HDMI_LRCLK : spdif;
	assign AUDIO_R     = SW[3] ? 1'bZ : SW[0] ? HDMI_I2S   : analog_r;
	assign AUDIO_L     = SW[3] ? 1'bZ : SW[0] ? HDMI_SCLK  : analog_l;
`endif

assign HDMI_MCLK = clk_audio;
wire clk_audio;

pll_audio pll_audio
(
	.refclk(FPGA_CLK3_50),
	.rst(0),
	.outclk_0(clk_audio)
);

wire spdif;
audio_out audio_out
(
	.reset(reset | areset),
	.clk(clk_audio),

	.att(vol_att),
	.mix(audio_mix),
	.sample_rate(audio_96k),

	.flt_rate(aflt_rate),
	.cx(acx),
	.cx0(acx0),
	.cx1(acx1),
	.cx2(acx2),
	.cy0(acy0),
	.cy1(acy1),
	.cy2(acy2),

	.is_signed(audio_s),
	.core_l(audio_l),
	.core_r(audio_r),

	.alsa_l(alsa_l),
	.alsa_r(alsa_r),

	.i2s_bclk(HDMI_SCLK),
	.i2s_lrclk(HDMI_LRCLK),
	.i2s_data(HDMI_I2S),
`ifndef MISTER_DUAL_SDRAM
	.dac_l(analog_l),
	.dac_r(analog_r),
`endif
	.spdif(spdif)
);


wire [28:0] alsa_address;
wire [63:0] alsa_readdata;
wire        alsa_ready;
wire        alsa_req;
wire        alsa_late;

wire [15:0] alsa_l, alsa_r;

alsa alsa
(
	.reset(reset),
	.clk(clk_audio),

	.ram_address(alsa_address),
	.ram_data(alsa_readdata),
	.ram_req(alsa_req),
	.ram_ready(alsa_ready),

	.spi_ss(aspi_ss),
	.spi_sck(aspi_sck),
	.spi_mosi(aspi_mosi),
	.spi_miso(aspi_miso),

	.pcm_l(alsa_l),
	.pcm_r(alsa_r)
);

////////////////  User I/O (USB 3.0 connector) /////////////////////////

assign USER_IO[0] =                       !user_out[0]  ? 1'b0 : 1'bZ;
assign USER_IO[1] =                       !user_out[1]  ? 1'b0 : 1'bZ;
assign USER_IO[2] = !(SW[1] ? HDMI_I2S   : user_out[2]) ? 1'b0 : 1'bZ;
assign USER_IO[3] =                       !user_out[3]  ? 1'b0 : 1'bZ;
assign USER_IO[4] = !(SW[1] ? HDMI_SCLK  : user_out[4]) ? 1'b0 : 1'bZ;
assign USER_IO[5] = !(SW[1] ? HDMI_LRCLK : user_out[5]) ? 1'b0 : 1'bZ;
assign USER_IO[6] =                       !user_out[6]  ? 1'b0 : 1'bZ;

assign user_in[0] =         USER_IO[0];
assign user_in[1] =         USER_IO[1];
assign user_in[2] = SW[1] | USER_IO[2];
assign user_in[3] =         USER_IO[3];
assign user_in[4] = SW[1] | USER_IO[4];
assign user_in[5] = SW[1] | USER_IO[5];
assign user_in[6] =         USER_IO[6];


///////////////////  User module connection ////////////////////////////

wire        clk_sys;
wire [15:0] audio_l, audio_r;
wire        audio_s;
wire  [1:0] audio_mix;
wire  [1:0] scanlines;
wire  [7:0] r_out, g_out, b_out, hr_out, hg_out, hb_out;
wire        vs_fix, hs_fix, de_emu, vs_emu, hs_emu, f1;
wire        hvs_fix, hhs_fix, hde_emu;
wire        clk_vid, ce_pix, clk_ihdmi, ce_hpix;
wire        vga_force_scaler;

wire        ram_clk;
wire [28:0] ram_address;
wire [7:0]  ram_burstcount;
wire        ram_waitrequest;
wire [63:0] ram_readdata;
wire        ram_readdatavalid;
wire        ram_read;
wire [63:0] ram_writedata;
wire [7:0]  ram_byteenable;
wire        ram_write;

wire        led_user;
wire  [1:0] led_power;
wire  [1:0] led_disk;
wire  [7:0] leds;
wire  [1:0] btn;

sync_fix sync_v(clk_vid, vs_emu, vs_fix);
sync_fix sync_h(clk_vid, hs_emu, hs_fix);

wire  [6:0] user_out, user_in;

assign clk_ihdmi= clk_vid;
assign ce_hpix  = ce_pix;
assign hr_out   = r_out;
assign hg_out   = g_out;
assign hb_out   = b_out;
assign hhs_fix  = hs_fix;
assign hvs_fix  = vs_fix;
assign hde_emu  = de_emu;

wire uart_dtr;
wire uart_dsr;
wire uart_cts;
wire uart_rts;
wire uart_rxd;
wire uart_txd;

wire osd_status;

wire        fb_en;
wire  [4:0] fb_fmt;
wire [11:0] fb_width;
wire [11:0] fb_height;
wire [31:0] fb_base;
wire [13:0] fb_stride;


`ifdef MISTER_FB
	`ifdef MISTER_FB_PALETTE
		wire        fb_pal_clk;
		wire  [7:0] fb_pal_a;
		wire [23:0] fb_pal_d;
		wire [23:0] fb_pal_q;
		wire        fb_pal_wr;
	`endif
	wire   fb_force_blank;
`else
	assign fb_en = 0;
	assign fb_fmt = 0;
	assign fb_width = 0;
	assign fb_height = 0;
	assign fb_base = 0;
	assign fb_stride = 0;
`endif

emu emu
(
	.CLK_50M(FPGA_CLK2_50),
	.RESET(reset),
	.HPS_BUS({f1, HDMI_TX_VS, 
				 clk_100m, clk_ihdmi,
				 ce_hpix, hde_emu, hhs_fix, hvs_fix, 
				 io_wait, clk_sys, io_fpga, io_uio, io_strobe, io_wide, io_din, io_dout}),

	.VGA_R(r_out),
	.VGA_G(g_out),
	.VGA_B(b_out),
	.VGA_HS(hs_emu),
	.VGA_VS(vs_emu),
	.VGA_DE(de_emu),
	.VGA_F1(f1),
	.VGA_SCALER(vga_force_scaler),

	.HDMI_WIDTH(direct_video ? 12'd0 : hdmi_width),
	.HDMI_HEIGHT(direct_video ? 12'd0 : hdmi_height),

	.CLK_VIDEO(clk_vid),
	.CE_PIXEL(ce_pix),
	.VGA_SL(scanlines),
	.VIDEO_ARX(ARX),
	.VIDEO_ARY(ARY),

`ifdef MISTER_FB
	.FB_EN(fb_en),
	.FB_FORMAT(fb_fmt),
	.FB_WIDTH(fb_width),
	.FB_HEIGHT(fb_height),
	.FB_BASE(fb_base),
	.FB_STRIDE(fb_stride),
	.FB_VBL(fb_vbl),
	.FB_LL(lowlat),
	.FB_FORCE_BLANK(fb_force_blank),

`ifdef MISTER_FB_PALETTE
	.FB_PAL_CLK (fb_pal_clk),
	.FB_PAL_ADDR(fb_pal_a),
	.FB_PAL_DOUT(fb_pal_d),
	.FB_PAL_DIN (fb_pal_q),
	.FB_PAL_WR  (fb_pal_wr),
`endif

`endif

	.LED_USER(led_user),
	.LED_POWER(led_power),
	.LED_DISK(led_disk),
	.LEDS(leds),

	.CLK_AUDIO(clk_audio),
	.AUDIO_L(audio_l),
	.AUDIO_R(audio_r),
	.AUDIO_S(audio_s),
	.AUDIO_MIX(audio_mix),

	.ADC_BUS({ADC_SCK,ADC_SDO,ADC_SDI,ADC_CONVST}),

	.DDRAM_CLK(ram_clk),
	.DDRAM_ADDR(ram_address),
	.DDRAM_BURSTCNT(ram_burstcount),
	.DDRAM_BUSY(ram_waitrequest),
	.DDRAM_DOUT(ram_readdata),
	.DDRAM_DOUT_READY(ram_readdatavalid),
	.DDRAM_RD(ram_read),
	.DDRAM_DIN(ram_writedata),
	.DDRAM_BE(ram_byteenable),
	.DDRAM_WE(ram_write),

	.SDRAM_DQ(SDRAM_DQ),
	.SDRAM_A(SDRAM_A),
	.SDRAM_DQML(SDRAM_DQML),
	.SDRAM_DQMH(SDRAM_DQMH),
	.SDRAM_BA(SDRAM_BA),
	.SDRAM_nCS(SDRAM_nCS),
	.SDRAM_nWE(SDRAM_nWE),
	.SDRAM_nRAS(SDRAM_nRAS),
	.SDRAM_nCAS(SDRAM_nCAS),
	.SDRAM_CLK(SDRAM_CLK),
	.SDRAM_CKE(SDRAM_CKE),

`ifdef MISTER_DUAL_SDRAM
	.SDRAM2_DQ(SDRAM2_DQ),
	.SDRAM2_A(SDRAM2_A),
	.SDRAM2_BA(SDRAM2_BA),
	.SDRAM2_nCS(SDRAM2_nCS),
	.SDRAM2_nWE(SDRAM2_nWE),
	.SDRAM2_nRAS(SDRAM2_nRAS),
	.SDRAM2_nCAS(SDRAM2_nCAS),
	.SDRAM2_CLK(SDRAM2_CLK),
	.SDRAM2_EN(SW[3]),
`endif

	.BUTTONS(btn),
	.OSD_STATUS(osd_status),

	.SD_SCK(SD_CLK),
	.SD_MOSI(SD_MOSI),
	.SD_MISO(SD_MISO),
	.SD_CS(SD_CS),
`ifdef MISTER_DUAL_SDRAM
	.SD_CD(mcp_sdcd),
`else
	.SD_CD(mcp_sdcd & (SW[0] ? VGA_HS : (SW[3] | SDCD_SPDIF))),
`endif

	.UART_CTS(uart_rts),
	.UART_RTS(uart_cts),
	.UART_RXD(uart_txd),
	.UART_TXD(uart_rxd),
	.UART_DTR(uart_dsr),
	.UART_DSR(uart_dtr),

	.USER_OUT(user_out),
	.USER_IN(user_in)
);

endmodule

/////////////////////////////////////////////////////////////////////

module sync_fix
(
	input clk,
	
	input sync_in,
	output sync_out
);

assign sync_out = sync_in ^ pol;

reg pol;
always @(posedge clk) begin
	integer pos = 0, neg = 0, cnt = 0;
	reg s1,s2;

	s1 <= sync_in;
	s2 <= s1;

	if(~s2 & s1) neg <= cnt;
	if(s2 & ~s1) pos <= cnt;

	cnt <= cnt + 1;
	if(s2 != s1) cnt <= 0;

	pol <= pos > neg;
end

endmodule

/////////////////////////////////////////////////////////////////////

// CSync generation
// Shifts HSync left by 1 HSync period during VSync

module csync
(
	input  clk,
	input  hsync,
	input  vsync,

	output csync
);

assign csync = (csync_vs ^ csync_hs);

reg csync_hs, csync_vs;
always @(posedge clk) begin
	reg prev_hs;
	reg [15:0] h_cnt, line_len, hs_len;

	// Count line/Hsync length
	h_cnt <= h_cnt + 1'd1;

	prev_hs <= hsync;
	if (prev_hs ^ hsync) begin
		h_cnt <= 0;
		if (hsync) begin
			line_len <= h_cnt - hs_len;
			csync_hs <= 0;
		end
		else hs_len <= h_cnt;
	end
	
	if (~vsync) csync_hs <= hsync;
	else if(h_cnt == line_len) csync_hs <= 1;
	
	csync_vs <= vsync;
end

endmodule
