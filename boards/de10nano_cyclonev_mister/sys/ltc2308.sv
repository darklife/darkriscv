//============================================================================
//
//  LTC2308 controller
//  Copyright (C) 2019 Sorgelig
//
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


// NUM_CH 1..8
// Sampling rate = ADC_RATE/NUM_CH
// ADC_RATE max is ~500KHz
// CLK_RATE max is ~80MHz
module ltc2308 #(parameter NUM_CH = 2, ADC_RATE = 96000, CLK_RATE = 50000000)
(
	input        reset,
	input        clk,

	inout  [3:0] ADC_BUS,

	output reg   dout_sync,             // toggle with every ADC round
	output reg   [(NUM_CH*12)-1:0] dout // 12 bits per channel (unsigned)
);

localparam TCONV = CLK_RATE/625000;

reg  sck;
wire sdo = cfg[5];

assign ADC_BUS[3] = sck;
wire   sdi = ADC_BUS[2];
assign ADC_BUS[1] = sdo;
assign ADC_BUS[0] = convst;

reg         convst;
reg   [5:0] cfg;

reg  [31:0] sum;
wire [31:0] next_sum = sum + ADC_RATE;

reg   [2:0] pin;
wire  [2:0] next_pin = (pin == (NUM_CH-1)) ? 3'd0 : (pin + 1'd1);

always @(posedge clk) begin
	reg  [7:0] tconv;
	reg  [3:0] bitcnt;
	reg [10:0] adcin;

	convst <= 0;

	if(reset) begin
		sum    <= 0;
		tconv  <= 0;
		bitcnt <= 0;
		sck    <= 0;
		cfg    <= 0;
		dout   <= 0;
		pin    <= NUM_CH[2:0]-1'd1;
	end
	else begin
		sum <= next_sum;
		if(next_sum >= CLK_RATE) begin
			sum    <= next_sum - CLK_RATE;
			tconv  <= TCONV[7:0];
			convst <= 1;
			bitcnt <= 12;
			cfg    <= {1'b1, next_pin[0], next_pin[2:1], 1'b1, 1'b0};
			if(!next_pin) dout_sync <= ~dout_sync;
		end

		if(tconv) tconv <= tconv - 1'd1;
		else if(bitcnt) begin
			sck <= ~sck;

			if(sck) cfg <= cfg<<1;
			else begin
				adcin <= {adcin[9:0],sdi};
				bitcnt <= bitcnt - 1'd1;
				if(bitcnt == 1) begin
					dout[pin*12 +:12] <= {adcin,sdi};
					pin <= next_pin;
				end
			end
		end
		else sck <= 0;
	end
end

endmodule

module ltc2308_tape #(parameter HIST_LOW = 16, HIST_HIGH = 64, ADC_RATE = 48000, CLK_RATE = 50000000)
(
	input        reset,
	input        clk,

	inout  [3:0] ADC_BUS,
	output reg   dout,
	output       active
);

wire [11:0] adc_data;
wire        adc_sync;
ltc2308 #(1, ADC_RATE, CLK_RATE) adc
(
	.reset(reset),
	.clk(clk),

	.ADC_BUS(ADC_BUS),
	.dout(adc_data),
	.dout_sync(adc_sync)
);

always @(posedge clk) begin
	reg [13:0] data1,data2,data3,data4, sum;
	reg adc_sync_d;

	adc_sync_d<=adc_sync;
	if(adc_sync_d ^ adc_sync) begin
		data1 <= data2;
		data2 <= data3;
		data3 <= data4;
		data4 <= adc_data;
		
		sum <= data1+data2+data3+data4;

		if(sum[13:2]<HIST_LOW)  dout <= 0;
		if(sum[13:2]>HIST_HIGH) dout <= 1;
	end
end

assign active = |act;

reg [1:0] act;
always @(posedge clk) begin
	reg [31:0] onesec;
	reg old_dout;
	
	onesec <= onesec + 1;
	if(onesec>CLK_RATE) begin
		onesec <= 0;
		if(act) act <= act - 1'd1;
	end

	old_dout <= dout;
	if(old_dout ^ dout) act <= 2;
end

endmodule
