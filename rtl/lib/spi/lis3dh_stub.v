/*
 * Copyright (c) 2025, Nicolas Sauzede <nicolas.sauzede@gmail.com>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 *
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
`timescale 1ns / 1ps
`include "../rtl/config.vh"

/*
    Simple LIS3DH SPI stub (STMicroelectronics LIS3DH accelerometer)
*/

module lis3dh_stub (
    output reg out_x_l_flag,
    input [15:0] out_x_l_response,
    input wire clk,        // System clock
    input wire sck,        // SPI clock
    input wire cs,         // SPI chip select (active low)
    input wire mosi,       // SPI master out slave in
    output reg miso        // SPI master in slave out
);

localparam
    IDLE = 0,
    RECEIVING = 1,
    PROCESSING = 2,
    RESPONDING = 3;
    reg [1:0] state = IDLE;
    reg [7:0] shift_reg = 8'b0;   // Shift register for received data
    reg [7:0] response = 8'b0;    // Response register
    wire [15:0] out_x_l_response_ = out_x_l_response;
//    reg out_x_l_flag = 0;
    reg [3:0] bit_count = 4'b0;   // Bit counter
    reg sck_d, sck_prev;          // Synchronized and previous SCK values
    reg cs_d, cs_prev;            // Synchronized and previous CS values
    reg mosi_d;                   // Synchronized MOSI

    always @(posedge clk) begin
        // Synchronize inputs to system clock
        sck_prev <= sck_d;
        sck_d <= sck;
        cs_prev <= cs_d;
        cs_d <= cs;
        mosi_d <= mosi;
        case (state)
            IDLE: begin
                if (!cs_d) begin
                    state <= RECEIVING;
                    bit_count <= 0;
                    shift_reg <= 8'b0;
                end
                miso <= 1'bZ;
                out_x_l_flag <= 0;
            end
            RECEIVING: begin
                if (!sck_d && sck_prev) begin // Falling edge of SCK
                    shift_reg <= {shift_reg[6:0], mosi_d};
                    bit_count <= bit_count + 1;
                    if (bit_count == 7) begin
                        state <= PROCESSING;
                    end
                end
            end
            PROCESSING: begin
                if (shift_reg[5:0] == 6'h0F) begin // WHOAMI command (ignore RnW & MnS bits)
                    response <= 8'h33; // LIS3DH WHOAMI response
                end else if (shift_reg[5:0] == 6'h28) begin // OUT_X_L command
                    response <= out_x_l_response_[7:0];
                    //response <= out_x_l_response[15:8];
                    out_x_l_flag <= 1;
                end else begin
                    response <= 8'h00; // Default response
                end
                state <= RESPONDING;
                bit_count <= 0;
            end
            RESPONDING: begin
                if (cs_d) begin
                    state <= IDLE;
                    if (out_x_l_flag) begin
                        //out_x_l_response <= out_x_l_response + 2;//16
                        //out_x_l_response <= out_x_l_response + 4;//8
                        //out_x_l_response <= out_x_l_response + 8;//4
                        //out_x_l_response <= out_x_l_response + 16;//2
                        //out_x_l_response <= out_x_l_response + 32;//
                    end
                    out_x_l_flag = 0;
                end else if (!sck_prev && sck_d) begin // Rising edge of SCK
                    miso <= response[7];
                    response <= {response[6:0], 1'b0};
                    bit_count <= bit_count + 1;
                    if (bit_count == 7) begin
                        if (out_x_l_flag) begin
                            response <= out_x_l_response_[15:8];
                            //response <= out_x_l_response[7:0];
                        end else begin
                            response <= 8'h00; // Default response
                        end
                    end
                end
            end
        endcase
    end

endmodule
