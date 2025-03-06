
module i2s
#(
	parameter AUDIO_DW = 16
)
(
	input      reset,
	input      clk,
	input      ce,

	output reg sclk,
	output reg lrclk,
	output reg sdata,

	input [AUDIO_DW-1:0]	left_chan,
	input [AUDIO_DW-1:0]	right_chan
);

always @(posedge clk) begin
	reg  [7:0] bit_cnt;
	reg msclk;

	reg [AUDIO_DW-1:0] left;
	reg [AUDIO_DW-1:0] right;

	if (reset) begin
		bit_cnt <= 1;
		lrclk   <= 1;
		sclk    <= 1;
		msclk   <= 1;
	end
	else begin
		sclk <= msclk;
		if(ce) begin
			msclk <= ~msclk;
			if(msclk) begin
				if(bit_cnt >= AUDIO_DW) begin
					bit_cnt <= 1;
					lrclk <= ~lrclk;
					if(lrclk) begin
						left  <= left_chan;
						right <= right_chan;
					end
				end
				else begin
					bit_cnt <= bit_cnt + 1'd1;
				end
				sdata <= lrclk ? right[AUDIO_DW - bit_cnt] : left[AUDIO_DW - bit_cnt];
			end
		end
	end
end

endmodule
