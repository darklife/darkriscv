
// A simple system-on-a-chip (SoC) for the MiST
// (c) 2015 Till Harbaum

// VGA controller generating 160x100 pixles. The VGA mode ised is 640x400
// combining every 4 row and column

// http://tinyvga.com/vga-timing/640x400@70Hz

module vga (
   input [7:0] color,
   // pixel clock
   input  pclk,
   // VGA output
   output reg	hs,
   output reg 	vs,
   output [7:0] r,
   output [7:0] g,
   output [7:0] b,
	output VGA_DE
);
					
// 640x400 70HZ VESA according to  http://tinyvga.com/vga-timing/640x400@70Hz

parameter H   = 640;    // width of visible area
parameter HFP = 16;     // unused time before hsync
parameter HS  = 96;     // width of hsync
parameter HBP = 48;     // unused time after hsync

parameter V   = 400;    // height of visible area
parameter VFP = 12;     // unused time before vsync
parameter VS  = 2;      // width of vsync
parameter VBP = 35;     // unused time after vsync


reg[9:0]  h_cnt;        // horizontal pixel counter
reg[9:0]  v_cnt;        // vertical pixel counter

reg hblank;
reg vblank;

// both counters count from the begin of the visibla area

// horizontal pixel counter
always@(posedge pclk) begin
	if(h_cnt==H+HFP+HS+HBP-1)   h_cnt <= 10'b0;
	else                        h_cnt <= h_cnt + 10'b1;

	// generate negative hsync signal
	if(h_cnt == H+HFP)    hs <= 1'b0;
	if(h_cnt == H+HFP+HS) hs <= 1'b1;
	if(h_cnt == H+HFP+HS) hblank <= 1'b1; else hblank<=1'b0;

	end

// veritical pixel counter
always@(posedge pclk) begin
	// the vertical counter is processed at the begin of each hsync
	if(h_cnt == H+HFP) begin
		if(v_cnt==VS+VBP+V+VFP-1)  v_cnt <= 10'b0; 
		else							   v_cnt <= v_cnt + 10'b1;

	        // generate positive vsync signal
		if(v_cnt == V+VFP)    vs <= 1'b1;
		if(v_cnt == V+VFP+VS) vs <= 1'b0;
		if(v_cnt == V+VFP+VS) vblank <= 1'b1; else vblank<=1'b0;
	end
end

// read VRAM
reg [13:0] video_counter;
reg [7:0] pixel;
reg de;

always@(posedge pclk) begin
        // The video counter is being reset at the begin of each vsync.
        // Otherwise it's increased every fourth pixel in the visible area.
        // At the end of the first three of four lines the counter is
        // decreased by the total line length to display the same contents
        // for four lines so 100 different lines are displayed on the 400
        // VGA lines.

	// visible area?
	if((v_cnt < V) && (h_cnt < H)) begin
		if(h_cnt[1:0] == 2'b11)
			video_counter <= video_counter + 14'd1;
		
		pixel <= (v_cnt[2] ^ h_cnt[2])?8'h00:color;    // checkboard
		// pixel <= video_counter[7:0];                // color pattern
		de<=1;
	end else begin
		if(h_cnt == H+HFP) begin
			if(v_cnt == V+VFP)
				video_counter <= 14'd0;
			else if((v_cnt < V) && (v_cnt[1:0] != 2'b11))
				video_counter <= video_counter - 14'd160;
		de<=0;
		end
			
		pixel <= 8'h00;   // black
	end
end

// seperate 8 bits into three colors (332)
assign r = { pixel[7:5], pixel[7:5], pixel[7:6] };
assign g = { pixel[4:2], pixel[4:2], pixel[4:3] };
assign b = { pixel[1:0], pixel[1:0], pixel[1:0], pixel[1:0] };

//assign VGA_DE  = ~(hblank | vblank);
assign VGA_DE = de;

endmodule
