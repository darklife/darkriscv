
module hdmi_config
(
	//	Host Side
	input       iCLK,
	input       iRST_N,
	
	input       dvi_mode,
	input       audio_96k,
	input [1:0] limited,
	input       ypbpr,

	output reg  done,

	//	I2C Side
	output		I2C_SCL,
	inout 		I2C_SDA
);

//	Internal Registers/Wires
reg        mI2C_GO = 0;
wire       mI2C_END;
wire       mI2C_ACK;
reg [15:0] LUT_DATA;
reg  [7:0] LUT_INDEX = 0;

i2c #(50_000_000, 20_000) i2c_av
(
	.CLK(iCLK),

	.I2C_SCL(I2C_SCL),  // I2C CLOCK
	.I2C_SDA(I2C_SDA),  // I2C DATA

	.I2C_ADDR('h39),    // 0x39 is the Slave Address of the ADV7513 chip!
	.I2C_WLEN(1),
	.I2C_WDATA1(init_data[LUT_INDEX][15:8]), // SUB_ADDR
	.I2C_WDATA2(init_data[LUT_INDEX][7:0]),  // DATA
	.START(mI2C_GO),    // START transfer
	.READ(0),
	.END(mI2C_END),     // END transfer 
	.ACK(mI2C_ACK)      // ACK
);

//////////////////////	Config Control	////////////////////////////
always@(posedge iCLK or negedge iRST_N) begin
	reg  [1:0] mSetup_ST = 0;

	if(!iRST_N) begin
		LUT_INDEX	<=	0;
		mSetup_ST	<=	0;
		mI2C_GO		<=	0;
		done        <= 0;
	end else begin
		if(init_data[LUT_INDEX] != 16'hFFFF) begin
			case(mSetup_ST)
			0:	begin
					mI2C_GO		<=	1;
					mSetup_ST	<=	1;
				end
			1: if(~mI2C_END) mSetup_ST	<=	2;
			2:	begin
					mI2C_GO <= 0;
					if(mI2C_END) begin
						mSetup_ST <= 0;
						if(!mI2C_ACK) LUT_INDEX <= LUT_INDEX + 8'd1;
					end
				end
			endcase
		end
		else done <= 1;
	end
end

////////////////////////////////////////////////////////////////////
/////////////////////	Config Data LUT   //////////////////////////

wire [15:0] init_data[82] = 
'{
	16'h9803,					// ADI required Write.

	{8'hD6, 8'b1100_0000},	// [7:6] HPD Control...
									// 00 = HPD is from both HPD pin or CDC HPD
									// 01 = HPD is from CDC HPD
									// 10 = HPD is from HPD pin
									// 11 = HPD is always high

	16'h4110,					// Power Down control
	16'h9A70,					// ADI required Write.
	16'h9C30,					// ADI required Write.
	{8'h9D, 8'b0110_0001},	// [7:4] must be b0110!.
									// [3:2] b00 = Input clock not divided. b01 = Clk divided by 2. b10 = Clk divided by 4. b11 = invalid!
									//	[1:0] must be b01!
	16'hA2A4,					// ADI required Write.
	16'hA3A4,					// ADI required Write.
	16'hE0D0,					// ADI required Write.


	16'h35_40,
	16'h36_D9,
	16'h37_0A,
	16'h38_00,
	16'h39_2D,
	16'h3A_00,

	{8'h16, 8'b0011_1000},	// Output Format 444 [7]=0.
									// [6] must be 0!
									// Colour Depth for Input Video data [5:4] b11 = 8-bit.
									// Input Style [3:2] b10 = Style 1 (ignored when using 444 input).
									// DDR Input Edge falling [1]=0 (not using DDR atm).
									// Output Colour Space RGB [0]=0.

	{8'h17, 8'b01100010},   // Aspect ratio 16:9 [1]=1, 4:3 [1]=0

	{8'h18, ypbpr ? 8'h86 : limited[0] ? 8'h8D : limited[1] ? 8'h8E : 8'h00},  // CSC Scaling Factors and Coefficients for RGB Full->Limited.
	{8'h19, ypbpr ? 8'hDF : limited[0] ? 8'hBC : 8'hFE},                     // Taken from table in ADV7513 Programming Guide.
	{8'h1A, ypbpr ? 8'h1A : 8'h00},         // CSC Channel A.
	{8'h1B, ypbpr ? 8'h3F : 8'h00},
	{8'h1C, ypbpr ? 8'h1E : 8'h00},
	{8'h1D, ypbpr ? 8'hE2 : 8'h00},
	{8'h1E, ypbpr ? 8'h07 : 8'h01},
	{8'h1F, ypbpr ? 8'hE7 : 8'h00},

	{8'h20, ypbpr ? 8'h04 : 8'h00},         // CSC Channel B.
	{8'h21, ypbpr ? 8'h1C : 8'h00},
	{8'h22, ypbpr ? 8'h08 : limited[0] ? 8'h0D : 8'h0E},
	{8'h23, ypbpr ? 8'h11 : limited[0] ? 8'hBC : 8'hFE},
	{8'h24, ypbpr ? 8'h01 : 8'h00},
	{8'h25, ypbpr ? 8'h91 : 8'h00},
	{8'h26, ypbpr ? 8'h01 : 8'h01},
	{8'h27, 8'h00},

	{8'h28, ypbpr ? 8'h1D : 8'h00},         // CSC Channel C.
	{8'h29, ypbpr ? 8'hAE : 8'h00},
	{8'h2A, ypbpr ? 8'h1B : 8'h00},
	{8'h2B, ypbpr ? 8'h73 : 8'h00},
	{8'h2C, ypbpr ? 8'h06 : limited[0] ? 8'h0D : 8'h0E},
	{8'h2D, ypbpr ? 8'hDF : limited[0] ? 8'hBC : 8'hFE},
	{8'h2E, ypbpr ? 8'h07 : 8'h01},
	{8'h2F, ypbpr ? 8'hE7 : 8'h00},

	{8'h3B, 8'b0000_0000},	// Pixel repetition [6:5] b00 AUTO. [4:3] b00 x1 mult of input clock. [2:1] b00 x1 pixel rep to send to HDMI Rx.

	16'h4000,					// General Control Packet Enable

	{8'h48, 8'b0000_1000},	// [6]=0 Normal bus order!
									// [5] DDR Alignment.
									// [4:3] b01 Data right justified (for YCbCr 422 input modes).

	16'h49A8,					// ADI required Write.
	16'h4C00,					// ADI required Write.

	{8'h55, 8'b0001_0000},	// [7] must be 0!. Set RGB444 in AVinfo Frame [6:5], Set active format [4].
									// AVI InfoFrame Valid [4].
									// Bar Info [3:2] b00 Bars invalid. b01 Bars vertical. b10 Bars horizontal. b11 Bars both.
									// Scan Info [1:0] b00 (No data). b01 TV. b10 PC. b11 None.

	{8'h57, 1'b0,           // [7] IT Content. 0 - No. 1 - Yes (type set in register h59).
	3'b000,                 // [6:4] Color space (ignored for RGB)
	(ypbpr | limited) ? 2'b01 : 2'b10, // [3:2] RGB Quantization range
	2'b00},                 // [1:0] Non-Uniform Scaled: 00 - None. 01 - Horiz. 10 - Vert. 11 - Both.

	16'h7301,

	{8'h94, 8'b1000_0000},	// [7]=1 HPD Interrupt ENabled.

	16'h9902,					// ADI required Write.
	16'h9B18,					// ADI required Write.

	16'h9F00,					// ADI required Write.

	{8'hA1, 8'b0000_0000},	// [6]=1 Monitor Sense Power Down DISabled.
	
	16'hA408,					// ADI required Write.
	16'hA504,					// ADI required Write.
	16'hA600,					// ADI required Write.
	16'hA700,					// ADI required Write.
	16'hA800,					// ADI required Write.
	16'hA900,					// ADI required Write.
	16'hAA00,					// ADI required Write.
	16'hAB40,					// ADI required Write.
	
	{8'hAF, 6'b0000_01,~dvi_mode,1'b0},	// [7]=0 HDCP Disabled.
									// [6:5] must be b00!
									// [4]=0 Current frame is unencrypted
									// [3:2] must be b01!
									//	[1]=1 HDMI Mode.
									// [0] must be b0!

	16'hB900,					// ADI required Write.

	{8'hBA, 8'b0110_0000},	// [7:5] Input Clock delay...
									// b000 = -1.2ns.
									// b001 = -0.8ns.
									// b010 = -0.4ns.
									// b011 = No delay.
									// b100 = 0.4ns.
									// b101 = 0.8ns.
									// b110 = 1.2ns.
									// b111 = 1.6ns.
					
	16'hBB00,					// ADI required Write.
	
	16'hDE9C,					// ADI required Write.
	16'hE460,					// ADI required Write.
	16'hFA7D,					// Nbr of times to search for good phase

	
									// (Audio stuff on Programming Guide, Page 66)...
	
	{8'h0A, 8'b0000_0000},	// [6:4] Audio Select. b000 = I2S.
									// [3:2] Audio Mode. (HBR stuff, leave at 00!).

	{8'h0B, 8'b0000_1110},	//
									
	{8'h0C, 8'b0000_0100},	// [7] 0 = Use sampling rate from I2S stream.   1 = Use samp rate from I2C Register.
									// [6] 0 = Use Channel Status bits from stream. 1 = Use Channel Status bits from I2C register.
									// [2] 1 = I2S0 Enable.
									// [1:0] I2S Format: 00 = Standard. 01 = Right Justified. 10 = Left Justified. 11 = AES.
									
	{8'h0D, 8'b0001_0000},	// [4:0] I2S Bit (Word) Width for Right-Justified.
	{8'h14, 8'b0000_0010},	// [3:0] Audio Word Length. b0010 = 16 bits.
	{8'h15, audio_96k, 7'b010_0000},	// I2S Sampling Rate [7:4]. b0000 = (44.1KHz). b0010 = 48KHz.
									// Input ID [3:1] b000 (0) = 24-bit RGB 444 or YCrCb 444 with Separate Syncs.

	// Audio Clock Config
	16'h0100,					//  
	audio_96k ? 16'h0230 : 16'h0218,	// Set N Value 12288/6144
	16'h0300,					//

	16'h0701,					//
	16'h0822,					// Set CTS Value 74250
	16'h090A,					//

	16'hFFFF 				   // END
};

////////////////////////////////////////////////////////////////////

endmodule