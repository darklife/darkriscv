
module audio_out
#(
	parameter CLK_RATE = 24576000
)
(
	input        reset,
	input        clk,

	//0 - 48KHz, 1 - 96KHz
	input        sample_rate,

	input  [31:0] flt_rate,
	input  [39:0] cx,
	input   [7:0] cx0,
	input   [7:0] cx1,
	input   [7:0] cx2,
	input  [23:0] cy0,
	input  [23:0] cy1,
	input  [23:0] cy2,

	input  [4:0] att,
	input  [1:0] mix,

	input        is_signed,
	input [15:0] core_l,
	input [15:0] core_r,

	input [15:0] alsa_l,
	input [15:0] alsa_r,

	// I2S
	output       i2s_bclk,
	output       i2s_lrclk,
	output       i2s_data,

	// SPDIF
   output       spdif,

	// Sigma-Delta DAC
	output       dac_l,
	output       dac_r
);

localparam AUDIO_RATE = 48000;
localparam AUDIO_DW = 16;

localparam CE_RATE = AUDIO_RATE*AUDIO_DW*8;
localparam FILTER_DIV = (CE_RATE/(AUDIO_RATE*32))-1;

wire [31:0] real_ce = sample_rate ? {CE_RATE[30:0],1'b0} : CE_RATE[31:0];

reg mclk_ce;
always @(posedge clk) begin
	reg [31:0] cnt;

	mclk_ce = 0;
	cnt = cnt + real_ce;
	if(cnt >= CLK_RATE) begin
		cnt = cnt - CLK_RATE;
		mclk_ce = 1;
	end
end

reg i2s_ce;
always @(posedge clk) begin
	reg div;
	i2s_ce <= 0;
	if(mclk_ce) begin
		div <= ~div;
		i2s_ce <= div;
	end
end

i2s i2s
(
	.reset(reset),

	.clk(clk),
	.ce(i2s_ce),

	.sclk(i2s_bclk),
	.lrclk(i2s_lrclk),
	.sdata(i2s_data),

	.left_chan(al),
	.right_chan(ar)
);

spdif toslink
(
	.rst_i(reset),

	.clk_i(clk),
	.bit_out_en_i(mclk_ce),

	.sample_i({ar,al}),
	.spdif_o(spdif)
);

sigma_delta_dac #(15) sd_l
(
	.CLK(clk),
	.RESET(reset),
	.DACin({~al[15], al[14:0]}),
	.DACout(dac_l)
);

sigma_delta_dac #(15) sd_r
(
	.CLK(clk),
	.RESET(reset),
	.DACin({~ar[15], ar[14:0]}),
	.DACout(dac_r)
);

reg sample_ce;
always @(posedge clk) begin
	reg [8:0] div = 0;
	reg [1:0] add = 0;

	div <= div + add;
	if(!div) begin
		div <= 2'd1 << sample_rate;
		add  <= 2'd1 << sample_rate;
	end

	sample_ce <= !div;
end

reg flt_ce;
always @(posedge clk) begin
	reg [31:0] cnt = 0;

	flt_ce = 0;
	cnt = cnt + {flt_rate[30:0],1'b0};
	if(cnt >= CLK_RATE) begin
		cnt = cnt - CLK_RATE;
		flt_ce = 1;
	end
end

reg [15:0] cl,cr;
always @(posedge clk) begin
	reg [15:0] cl1,cl2;
	reg [15:0] cr1,cr2;

	cl1 <= core_l; cl2 <= cl1;
	if(cl2 == cl1) cl <= cl2;

	cr1 <= core_r; cr2 <= cr1;
	if(cr2 == cr1) cr <= cr2;
end

reg a_en1 = 0, a_en2 = 0;
always @(posedge clk, posedge reset) begin
	reg  [1:0] dly1 = 0;
	reg [14:0] dly2 = 0;

	if(reset) begin
		dly1 <= 0;
		dly2 <= 0;
		a_en1 <= 0;
		a_en2 <= 0;
	end
	else begin
		if(flt_ce) begin
			if(~&dly1) dly1 <= dly1 + 1'd1;
			else a_en1 <= 1;
		end

		if(sample_ce) begin
			if(!dly2[13+sample_rate]) dly2 <= dly2 + 1'd1;
			else a_en2 <= 1;
		end
	end
end

wire [15:0] acl, acr;
IIR_filter #(.use_params(0)) IIR_filter
(
	.clk(clk),
	.reset(reset),

	.ce(flt_ce & a_en1),
	.sample_ce(sample_ce),

	.cx(cx),
	.cx0(cx0),
	.cx1(cx1),
	.cx2(cx2),
	.cy0(cy0),
	.cy1(cy1),
	.cy2(cy2),

	.input_l({~is_signed ^ cl[15], cl[14:0]}),
	.input_r({~is_signed ^ cr[15], cr[14:0]}),
	.output_l(acl),
	.output_r(acr)
);

wire [15:0] adl;
DC_blocker dcb_l
(
	.clk(clk),
	.ce(sample_ce),
	.sample_rate(sample_rate),
	.mute(~a_en2),
	.din(acl),
	.dout(adl)
);

wire [15:0] adr;
DC_blocker dcb_r
(
	.clk(clk),
	.ce(sample_ce),
	.sample_rate(sample_rate),
	.mute(~a_en2),
	.din(acr),
	.dout(adr)
);

wire [15:0] al, audio_l_pre;
aud_mix_top audmix_l
(
	.clk(clk),
	.ce(sample_ce),
	.att(att),
	.mix(mix),

	.core_audio(adl),
	.pre_in(audio_r_pre),
	.linux_audio(alsa_l),

	.pre_out(audio_l_pre),
	.out(al)
);

wire [15:0] ar, audio_r_pre;
aud_mix_top audmix_r
(
	.clk(clk),
	.ce(sample_ce),
	.att(att),
	.mix(mix),

	.core_audio(adr),
	.pre_in(audio_l_pre),
	.linux_audio(alsa_r),

	.pre_out(audio_r_pre),
	.out(ar)
);

endmodule

module aud_mix_top
(
	input             clk,
	input             ce,

	input       [4:0] att,
	input       [1:0] mix,

	input      [15:0] core_audio,
	input      [15:0] linux_audio,
	input      [15:0] pre_in,

	output reg [15:0] pre_out = 0,
	output reg [15:0] out = 0
);

reg signed [16:0] a1, a2, a3, a4;
always @(posedge clk) if (ce) begin

	a1 <= {core_audio[15],core_audio};
	a2 <= a1 + {linux_audio[15],linux_audio};

	pre_out <= a2[16:1];

	case(mix)
		0: a3 <= a2;
		1: a3 <= $signed(a2) - $signed(a2[16:3]) + $signed(pre_in[15:2]);
		2: a3 <= $signed(a2) - $signed(a2[16:2]) + $signed(pre_in[15:1]);
		3: a3 <= {a2[16],a2[16:1]} + {pre_in[15],pre_in};
	endcase

	if(att[4]) a4 <= 0;
	else a4 <= a3 >>> att[3:0];

	//clamping
	out <= ^a4[16:15] ? {a4[16],{15{a4[15]}}} : a4[15:0];
end

endmodule
