//-----------------------------------------------------------------
//                        SPDIF Transmitter
//                              V0.1
//                        Ultra-Embedded.com
//                          Copyright 2012
//
//                 Email: admin@ultra-embedded.com
//
//                         License: GPL
// If you would like a version with a more permissive license for
// use in closed source commercial applications please contact me
// for details.
//-----------------------------------------------------------------
//
// This file is open source HDL; you can redistribute it and/or 
// modify it under the terms of the GNU General Public License as 
// published by the Free Software Foundation; either version 2 of 
// the License, or (at your option) any later version.
//
// This file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public 
// License along with this file; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
//-----------------------------------------------------------------
// altera message_off 10762
// altera message_off 10240

module spdif
(
    input           clk_i,
    input           rst_i,

    // SPDIF bit output enable
    // Single cycle pulse synchronous to clk_i which drives
    // the output bit rate.
    // For 44.1KHz, 44100×32×2×2 = 5,644,800Hz
    // For 48KHz,   48000×32×2×2 = 6,144,000Hz
    input           bit_out_en_i,

    // Output
    output          spdif_o,

    // Audio interface (16-bit x 2 = RL)
    input [31:0]    sample_i,
    output reg      sample_req_o
);

//-----------------------------------------------------------------
// Registers
//-----------------------------------------------------------------
reg [15:0]  audio_sample_q;
reg [8:0]   subframe_count_q;

reg         load_subframe_q;
reg [7:0]   preamble_q;
wire [31:0] subframe_w;

reg [5:0]   bit_count_q;
reg         bit_toggle_q;

reg         spdif_out_q;

reg [5:0]   parity_count_q;

reg         channel_status_bit_q;

//-----------------------------------------------------------------
// Subframe Counter
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
    if (rst_i == 1'b1)
        subframe_count_q    <= 9'd0;
    else if (load_subframe_q)
    begin
        // 192 frames (384 subframes) in an audio block
        if (subframe_count_q == 9'd383)
            subframe_count_q <= 9'd0;
        else
            subframe_count_q <= subframe_count_q + 9'd1;
    end
end

//-----------------------------------------------------------------
// Sample capture
//-----------------------------------------------------------------
reg [15:0] sample_buf_q;

always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        audio_sample_q      <= 16'h0000;
        sample_buf_q        <= 16'h0000;
        sample_req_o        <= 1'b0;
   end
   else if (load_subframe_q)
   begin
        // Start of frame (first subframe)?
        if (subframe_count_q[0] == 1'b0)
        begin
            // Use left sample
            audio_sample_q <= sample_i[15:0];

            // Store right sample
            sample_buf_q <= sample_i[31:16];

            // Request next sample
            sample_req_o <= 1'b1;
        end
        else
        begin
            // Use right sample
            audio_sample_q <= sample_buf_q;

            sample_req_o <= 1'b0;
        end
   end
   else
        sample_req_o <= 1'b0;
end

// Timeslots 3 - 0 = Preamble
assign subframe_w[3:0] = 4'b0000;

// Timeslots 7 - 4 = 24-bit audio LSB
assign subframe_w[7:4] = 4'b0000;

// Timeslots 11 - 8 = 20-bit audio LSB
assign subframe_w[11:8] = 4'b0000;

// Timeslots 27 - 12 = 16-bit audio
assign subframe_w[27:12] = audio_sample_q;

// Timeslots 28 = Validity
assign subframe_w[28] = 1'b0; // Valid

// Timeslots 29 = User bit
assign subframe_w[29] = 1'b0;

// Timeslots 30 = Channel status bit
assign subframe_w[30] = channel_status_bit_q ; //was constant 1'b0 enabling copy-bit;

// Timeslots 31 = Even Parity bit (31:4)
assign subframe_w[31] = 1'b0;

//-----------------------------------------------------------------
// Preamble and Channel status bit
//-----------------------------------------------------------------
localparam PREAMBLE_Z = 8'b00010111; // "B" channel A data at start of block
localparam PREAMBLE_Y = 8'b00100111; // "W" channel B data
localparam PREAMBLE_X = 8'b01000111; // "M" channel A data not at start of block

reg [7:0] preamble_r;
reg       channel_status_bit_r;

always @ *
begin
    // Start of audio block?
    // Z(B) - Left channel
    if (subframe_count_q == 9'd0)
        preamble_r = PREAMBLE_Z; // Z(B)
    // Right Channel?
    else if (subframe_count_q[0] == 1'b1)
        preamble_r = PREAMBLE_Y; // Y(W)
    // Left Channel (but not start of block)?
    else
        preamble_r = PREAMBLE_X; // X(M)

    if (subframe_count_q[8:1] == 8'd2) // frame 2 => subframes 4 and 5 => 0 = copy inhibited, 1 = copy permitted
        channel_status_bit_r = 1'b1;
    else if (subframe_count_q[8:1] == 8'd15) // frame 15 => 0 = no indication, 1 = original media
        channel_status_bit_r = 1'b1;
    else if (subframe_count_q[8:1] == 8'd25) // frame 24 to 27 => sample frequency, 0100 = 48kHz, 0000 = 44kHz (l2r)
        channel_status_bit_r = 1'b1;
    else
        channel_status_bit_r = 1'b0; // everything else defaults to 0        
end

always @ (posedge rst_i or posedge clk_i )
begin
    if (rst_i == 1'b1)
    begin
        preamble_q  <= 8'h00;
        channel_status_bit_q <= 1'b0;
    end
    else if (load_subframe_q)
    begin
        preamble_q  <= preamble_r;
        channel_status_bit_q <= channel_status_bit_r;
    end
end

//-----------------------------------------------------------------
// Parity Counter
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i )
begin
   if (rst_i == 1'b1)
   begin
        parity_count_q  <= 6'd0;
   end
   // Time to output a bit?
   else if (bit_out_en_i)
   begin
        // Preamble bits?
        if (bit_count_q < 6'd8)
        begin
            parity_count_q  <= 6'd0;
        end
        // Normal timeslots
        else if (bit_count_q < 6'd62)
        begin
            // On first pass through this timeslot, count number of high bits
            if (bit_count_q[0] == 0 && subframe_w[bit_count_q / 2] == 1'b1)
                parity_count_q <= parity_count_q + 6'd1;
        end
   end
end

//-----------------------------------------------------------------
// Bit Counter
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i)
begin
    if (rst_i == 1'b1)
    begin
        bit_count_q     <= 6'b0;
        load_subframe_q <= 1'b1;
    end
    // Time to output a bit?
    else if (bit_out_en_i)
    begin
        // 32 timeslots (x2 for double frequency)
        if (bit_count_q == 6'd63)
        begin
            bit_count_q     <= 6'd0;
            load_subframe_q <= 1'b1;
        end
        else
        begin
            bit_count_q     <= bit_count_q + 6'd1;
            load_subframe_q <= 1'b0;
        end
    end
    else
        load_subframe_q <= 1'b0;
end

//-----------------------------------------------------------------
// Bit half toggle
//-----------------------------------------------------------------
always @ (posedge rst_i or posedge clk_i)
if (rst_i == 1'b1)
    bit_toggle_q    <= 1'b0;
// Time to output a bit?
else if (bit_out_en_i)
    bit_toggle_q <= ~bit_toggle_q;

//-----------------------------------------------------------------
// Output bit (BMC encoded)
//-----------------------------------------------------------------
reg bit_r;

always @ *
begin
    bit_r = spdif_out_q;

    // Time to output a bit?
    if (bit_out_en_i)
    begin
        // Preamble bits?
        if (bit_count_q < 6'd8)
        begin
            bit_r = preamble_q[bit_count_q[2:0]];
        end
        // Normal timeslots
        else if (bit_count_q < 6'd62)
        begin
            if (subframe_w[bit_count_q / 2] == 1'b0)
            begin
                if (bit_toggle_q == 1'b0)
                    bit_r = ~spdif_out_q;
                else
                    bit_r = spdif_out_q;
            end
            else
                bit_r = ~spdif_out_q;
        end
        // Parity timeslot
        else
        begin
            // Even number of high bits, make odd
            if (parity_count_q[0] == 1'b0)
            begin
                if (bit_toggle_q == 1'b0)
                    bit_r = ~spdif_out_q;
                else
                    bit_r = spdif_out_q;
            end
            else
                bit_r = ~spdif_out_q;
        end
    end
end

always @ (posedge rst_i or posedge clk_i )
if (rst_i == 1'b1)
    spdif_out_q <= 1'b0;
else
    spdif_out_q <= bit_r;

assign spdif_o  = spdif_out_q;

endmodule
