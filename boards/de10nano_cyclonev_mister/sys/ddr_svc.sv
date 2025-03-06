//
// Copyright (c) 2020 Alexey Melnikov
//
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version. 
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License 
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// ------------------------------------------
//

// 16-bit version

module ddr_svc
(
	input         clk,

	input         ram_waitrequest,
	output  [7:0] ram_burstcnt,
	output [28:0] ram_addr,
	input  [63:0] ram_readdata,
	input         ram_read_ready,
	output reg    ram_read,
	output [63:0] ram_writedata,
	output  [7:0] ram_byteenable,
	output reg    ram_write,

	output  [7:0] ram_bcnt,

	input  [31:3] ch0_addr,
	input   [7:0] ch0_burst,
	output [63:0] ch0_data,
	input         ch0_req,
	output        ch0_ready,
	
	input  [31:3] ch1_addr,
	input   [7:0] ch1_burst,
	output [63:0] ch1_data,
	input         ch1_req,
	output        ch1_ready
);

assign ram_burstcnt   = ram_burst;
assign ram_byteenable = 8'hFF;
assign ram_addr       = ram_address;
assign ram_writedata  = 0;

assign ch0_data  = ram_q[0];
assign ch1_data  = ram_q[1];
assign ch0_ready = ready[0];
assign ch1_ready = ready[1];

reg  [7:0] ram_burst;
reg [63:0] ram_q[2];
reg [31:3] ram_address;
reg  [1:0] ack = 0;
reg  [1:0] ready;
reg        state = 0;
reg        ch = 0;

always @(posedge clk) begin
	ready <= 0;
	
	if(!ram_waitrequest) begin
		ram_read  <= 0;
		ram_write <= 0;

		case(state)
			0: if(ch0_req != ack[0]) begin
					ack[0]      <= ch0_req;
					ram_address <= ch0_addr;
					ram_burst   <= ch0_burst;
					ram_read    <= 1;
					ch 			<= 0;
					ram_bcnt    <= 8'hFF;
					state       <= 1;
				end
				else if(ch1_req != ack[1]) begin
					ack[1]      <= ch1_req;
					ram_address <= ch1_addr;
					ram_burst   <= ch1_burst;
					ram_read    <= 1;
					ch 			<= 1;
					ram_bcnt    <= 8'hFF;
					state       <= 1;
				end 
			1: begin
					if(ram_read_ready) begin
						ram_bcnt  <= ram_bcnt + 1'd1;
						ram_q[ch] <= ram_readdata;
						ready[ch] <= 1;
						if ((ram_bcnt+2'd2) == ram_burst) state <= 0;
					end
				end
		endcase
	end
end

endmodule
