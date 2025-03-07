//
// Communication module to MT32-pi (external MIDI emulator on RPi)
// (C) 2020 Sorgelig, Kitrinx
//
// https://github.com/dwhinham/mt32-pi
//

module mt32pi
(
	input             CLK_AUDIO,

	input             CLK_VIDEO,
	input             CE_PIXEL,
	input             VGA_VS,
	input             VGA_DE,

	input       [6:0] USER_IN,
	output      [6:0] USER_OUT,

	input             reset,
	input             midi_tx,
	output            midi_rx,

	output reg [15:0] mt32_i2s_r,
	output reg [15:0] mt32_i2s_l,

	output reg        mt32_available,

	input             mt32_mode_req,
	input       [1:0] mt32_rom_req,
	input       [7:0] mt32_sf_req,

	output reg  [7:0] mt32_mode,
	output reg  [7:0] mt32_rom,
	output reg  [7:0] mt32_sf,
	output reg        mt32_newmode,

	output reg        mt32_lcd_en,
	output reg        mt32_lcd_pix,
	output reg        mt32_lcd_update
);

//
// Pin | USB Name | Signal
// ----+----------+--------------
// 0   | D+       | I/O I2C_SDA / RX (midi in)
// 1   | D-       | O   TX (midi out)
// 2   | TX-      | I   I2S_WS (1 == right)
// 3   | GND_d    | I   I2C_SCL
// 4   | RX+      | I   I2S_BCLK
// 5   | RX-      | I   I2S_DAT
// 6   | TX+      | -   none
//

assign USER_OUT[0]   = sda_out;
assign USER_OUT[1]   = midi_tx;
assign USER_OUT[6:2] = '1;


//
// crossed/straight cable selection
//

generate
	genvar i;
	for(i = 0; i<2; i++) begin : clk_rate
		wire clk_in = i ? USER_IN[6] : USER_IN[4];
		reg [4:0] cnt;
		always @(posedge CLK_AUDIO) begin : clkr
			reg       clk_sr, clk, old_clk;
			reg [4:0] cnt_tmp;

			clk_sr <= clk_in;
			if (clk_sr == clk_in) clk <= clk_sr;

			if(~&cnt_tmp) cnt_tmp <= cnt_tmp + 1'd1;
			else cnt <= '1;

			old_clk <= clk;
			if(~old_clk & clk) begin
				cnt <= cnt_tmp;
				cnt_tmp <= 0;
			end
		end
	end
	
	reg crossed;
	always @(posedge CLK_AUDIO) crossed <= (clk_rate[0].cnt <= clk_rate[1].cnt);
endgenerate

wire   i2s_ws   = crossed ? USER_IN[2] : USER_IN[5];
wire   i2s_data = crossed ? USER_IN[5] : USER_IN[2];
wire   i2s_bclk = crossed ? USER_IN[4] : USER_IN[6];
assign midi_rx  = ~mt32_available ? USER_IN[0] : crossed ? USER_IN[6] : USER_IN[4];


//
// i2s receiver
//

always @(posedge CLK_AUDIO) begin : i2s_proc
	reg [15:0] i2s_buf = 0;
	reg  [4:0] i2s_cnt = 0;
	reg        clk_sr;
	reg        i2s_clk = 0;
	reg        old_clk, old_ws;
	reg        i2s_next = 0;

	// Debounce clock
	clk_sr <= i2s_bclk;
	if (clk_sr == i2s_bclk) i2s_clk <= clk_sr;

	// Latch data and ws on rising edge
	old_clk <= i2s_clk;
	if (i2s_clk && ~old_clk) begin

		if (~i2s_cnt[4]) begin
			i2s_cnt <= i2s_cnt + 1'd1;
			i2s_buf[~i2s_cnt[3:0]] <= i2s_data;
		end

		// Word Select will change 1 clock before the new word starts
		old_ws <= i2s_ws;
		if (old_ws != i2s_ws) i2s_next <= 1;
	end

	if (i2s_next) begin
		i2s_next <= 0;
		i2s_cnt <= 0;
		i2s_buf <= 0;

		if (i2s_ws) mt32_i2s_l <= i2s_buf;
		else        mt32_i2s_r <= i2s_buf;
	end
	
	if (reset) begin
		i2s_buf    <= 0;
		mt32_i2s_l <= 0;
		mt32_i2s_r <= 0;
	end
end


//
// i2c slave
//

reg        sda_out;
reg  [7:0] lcd_data[1024];
reg        lcd_sz;

reg        reset_r  = 0;
wire [7:0] mode_req = reset_r ? 8'hA0 : mt32_mode_req ? 8'hA2 : 8'hA1;
wire [7:0] rom_req  = {6'd0, mt32_rom_req};

always @(posedge CLK_AUDIO) begin : i2c_slave
	reg        sda_sr, scl_sr;
	reg        old_sda, old_scl;
	reg        sda, scl;
	reg  [7:0] tmp;
	reg  [3:0] cnt = 0;
	reg [10:0] bcnt = 0;
	reg        ack;
	reg        i2c_rw;
	reg        disp, dispdata;
	reg  [2:0] div;
	reg        old_reset;
	
	old_reset <= reset;
	if(old_reset & ~reset) sda_out <= 1;

	div <= div + 1'd1;
	if(!div) begin
		sda_sr <= USER_IN[0];
		if(sda_sr == USER_IN[0]) sda <= sda_sr;
		old_sda <= sda;

		scl_sr <= USER_IN[3];
		if(scl_sr == USER_IN[3]) scl <= scl_sr;
		old_scl <= scl;

		//start
		if(old_scl & scl & old_sda & ~sda) begin
			cnt <= 9;
			bcnt <= 0;
			ack <= 0;
			i2c_rw <= 0;
			disp <= 0;
			dispdata <= 0;
		end

		//stop
		if(old_scl & scl & ~old_sda & sda) begin
			cnt <= 0;
			if(dispdata) begin
				lcd_sz <= ~bcnt[9];
				mt32_lcd_update <= ~mt32_lcd_update;
			end
		end

		//data latch
		if(~old_scl && scl && cnt) begin
			tmp <= {tmp[6:0], sda};
			cnt <= cnt - 1'd1;
		end

		if(!cnt) sda_out <= 1;

		//data set
		if(old_scl && ~scl) begin
			sda_out <= 1;
			if(cnt == 1) begin
				if(!bcnt) begin
					if(tmp[7:1] == 'h45 || tmp[7:1] == 'h3c) begin
						disp <= (tmp[7:1] == 'h3c);
						sda_out <= 0;
						mt32_available <= 1;
						ack <= 1;
						i2c_rw <= tmp[0];
						bcnt <= bcnt + 1'd1;
						cnt <= 10;
					end
					else begin
						// wrong address, stop
						cnt <= 0;
					end
				end
				else if(ack) begin
					if(~i2c_rw) begin
						if(disp) begin
							if(bcnt == 1) dispdata <= (tmp[7:6] == 2'b01);
							else if(dispdata) lcd_data[bcnt[9:0] - 2'd2] <= tmp;
						end
						else begin
							if(bcnt == 1) mt32_mode <= tmp;
							if(bcnt == 2) mt32_rom  <= tmp;
							if(bcnt == 3) mt32_sf   <= tmp;
							if(bcnt == 3) mt32_newmode <= ~mt32_newmode;
						end
					end
					if(~&bcnt) bcnt <= bcnt + 1'd1;
					sda_out <= 0;
					cnt <= 10;
				end
			end
			else if(i2c_rw && ack && cnt && ~disp) begin
				if(bcnt == 1) sda_out <= mode_req[cnt[2:0] - 2'd2];
				if(bcnt == 2) sda_out <= rom_req[cnt[2:0] - 2'd2];
				if(bcnt == 3) sda_out <= mt32_sf_req[cnt[2:0] - 2'd2];
				if(bcnt == 3) reset_r <= 0;
			end
		end
	end

	if(reset) begin
		reset_r <= 1;
		mt32_available <= 0;
	end
end

always @(posedge CLK_VIDEO) begin
	reg old_de, old_vs;
	reg [7:0] hcnt;
	reg [6:0] vcnt;
	reg [7:0] sh;

	if(CE_PIXEL) begin
		old_de <= VGA_DE;
		old_vs <= VGA_VS;

		if(~&hcnt) hcnt <= hcnt + 1'd1;
		sh <= (sh << 1) | (~old_de & VGA_DE);
		if(sh[7]) hcnt <= 0;

		if(old_de & ~VGA_DE & ~&vcnt) vcnt <= vcnt + 1'd1;
		if(~old_vs & VGA_VS) vcnt <= 0;

		mt32_lcd_en  <= mt32_available & ~hcnt[7] && (lcd_sz ? !vcnt[6] : !vcnt[6:5]);
		mt32_lcd_pix <= lcd_data[{vcnt[5:3],hcnt[6:0]}][vcnt[2:0]];
	end
end

endmodule
