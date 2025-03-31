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
//`include "../../../rtl/config.vh"

module spi_master_bb (
    input               CLK,    // clock
    input               RES,    // reset

    inout [31:0]        IPORT,
    input [31:0]        OPORT,

    inout               CSN,    // SPI CSN output (active LOW)
    inout               SCK,    // SPI clock output
    inout               MOSI,   // SPI master data output, slave data input
    inout               MISO    // SPI master data input, slave data output
);

    wire spibb_ena;
    reg [15:0] out_x_resp = 16'bz;
    reg [31:0] IPORTFF = 32'bz;
    assign spibb_ena = OPORT[3];
    assign IPORT = spibb_ena ? IPORTFF : 32'bz;
    assign CSN = spibb_ena ? OPORT[2] : 1'bz;
    assign SCK = spibb_ena ? OPORT[1] : 1'bz;
    assign MOSI = spibb_ena ? OPORT[0] : 1'bz;
    always@(posedge CLK) begin
        if (RES) begin
            out_x_resp <= 16'bz;
        end else if (spibb_ena) begin
            out_x_resp <= OPORT[31:16];
        end
    end
    always@(posedge CLK) begin
        if (RES) begin
            IPORTFF <= 32'b0;
        end else if (spibb_ena & !CSN) begin
            IPORTFF <= {out_x_resp, 11'b0, MISO, spibb_ena, CSN, SCK, MOSI};
        end
    end
endmodule
