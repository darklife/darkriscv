
module i2c
(
	input        CLK,

	input        START,
	input        READ,
	input  [6:0] I2C_ADDR,
	input        I2C_WLEN,   // 0 - one byte, 1 - two bytes
	input  [7:0] I2C_WDATA1,
	input  [7:0] I2C_WDATA2,
	output [7:0] I2C_RDATA,
	output reg   END = 1,
	output reg   ACK = 0,

	//I2C bus
	output       I2C_SCL,
 	inout        I2C_SDA
);


//	Clock Setting
parameter CLK_Freq = 50_000_000;	//	50 MHz
parameter I2C_Freq = 400_000;		//	400 KHz

localparam I2C_FreqX2 = I2C_Freq*2;

reg         I2C_CLOCK;
reg  [31:0] cnt;
wire [31:0] cnt_next = cnt + I2C_FreqX2;

always @(posedge CLK) begin
	cnt <= cnt_next;
	if(cnt_next >= CLK_Freq) begin
		cnt <= cnt_next - CLK_Freq;
		I2C_CLOCK <= ~I2C_CLOCK;
	end
end

assign I2C_SCL = (SCLK | I2C_CLOCK) ? 1'bZ : 1'b0;
assign I2C_SDA = SDO[3] ? 1'bz : 1'b0;

reg       SCLK;
reg [3:0] SDO;
reg [0:7] rdata;

reg  [5:0] SD_COUNTER;
reg [0:31] SD;

initial begin
	SD_COUNTER = 'b111111;
	SD   = 'hFFFF;
	SCLK = 1;
	SDO  = 4'b1111;
end

assign I2C_RDATA = rdata;

always @(posedge CLK) begin
	reg old_clk;
	reg old_st;
	reg rd,len;

	old_clk <= I2C_CLOCK;
	old_st  <= START;
	
	// delay to make sure SDA changed while SCL is stabilized at low
	if(old_clk && ~I2C_CLOCK && ~SD_COUNTER[5]) SDO[0] <= SD[SD_COUNTER[4:0]];
	SDO[3:1] <= SDO[2:0];

	if(~old_st && START) begin
		SCLK <= 1;
		SDO  <= 4'b1111;
		ACK  <= 0;
		END  <= 0;
		rd   <= READ;
		len  <= I2C_WLEN;
		if(READ) SD <= {2'b10, I2C_ADDR, 1'b1, 1'b1, 8'b11111111, 1'b0, 3'b011, 9'b111111111};
			else  SD <= {2'b10, I2C_ADDR, 1'b0, 1'b1, I2C_WDATA1,  1'b1, I2C_WDATA2,  4'b1011};
		SD_COUNTER <= 0;
	end else begin
		if(~old_clk && I2C_CLOCK && ~&SD_COUNTER) begin
			SD_COUNTER <= SD_COUNTER + 6'd1;	
			case(SD_COUNTER)
			      01: SCLK <= 0;
			      10: ACK  <= ACK | I2C_SDA;
			      19: if(~rd) begin
							ACK <= ACK | I2C_SDA;
							if(~len) SD_COUNTER <= 29;
						 end
					20: if(rd)  SCLK <= 1;
					23: if(rd)  END  <= 1;
			      28: if(~rd) ACK  <= ACK | I2C_SDA;
			      29: if(~rd) SCLK <= 1;
			      32: if(~rd) END  <= 1;
			endcase

			if(SD_COUNTER >= 11 && SD_COUNTER <= 18) rdata[SD_COUNTER[4:0]-11] <= I2C_SDA;
		end
	end
end

endmodule
