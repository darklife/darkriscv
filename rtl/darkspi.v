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

/*
    Simple SPI Master wrapper for Darkriscv, based on Max1000 Tutorial spi_master.v
*/

`timescale 1ns / 1ps
//`include "../rtl/config.vh"

// SPI registers
// Only 16 (1 byte data) and 24 (2 bytes data) bits SPI transfers are supported
//    BE
// W 0011 command,data
// R 0001 data
// R 1000 STATUS
// W 1111 00,command,datalo,datahi
// R 0011 datalo,datahi
// R 1111 STATUS,00,datalo,datahi
// Where STATUS is: {6'b0, spi_ready, spi_busy} and can be polled for SPI transfer completion.
//
// Special internal 32 bit write, directing to custom spi_master reset-glitch
// W 1111 <MSB different from 0> (refer spi_master documentation)
//
// Examples below are for STMicro LIS3DH sensor SPI target.
//
// - One byte transfer:
// To read a single byte at address 0x0f (WHO_AM_I), initiate a 16 bits write:
// *((volatile short *)SPI_MMADDR) = 0x8f00; // 8f is addr with RnW=1, 00 is 8-bit resp placeholder
// Followed by a 8 bits read:
// char who_am_i = *((volatile char *)SPI_MMADDR) & 0xff;
//
// To write a single byte at address eg: 0x20 (CTRL_REG1), initiate a 16 bits write:
// *((volatile short *)SPI_MMADDR) = 0x2077; // 20 is addr, 77 is 8-bit data to write
//
// - Two bytes access (with automatic address increment):
// To read two bytes starting at address eg: 0x28 (OUT_X_L), initiate a 32 bits write:
// *((volatile int *)SPI_MMADDR) = 0x00e80000; // e8 is addr with RnW=1 & MnS=1, 0000 is 16-bit resp placeholder
// Followed by:
// -- a 16 bits read:
// short swapped_out_x = *((volatile short *)SPI_MMADDR); // Note that the returned value is byte-swapped: 0xLOHI

module darkspi #(parameter integer DIV_COEF = 0) (
    input         CLK,          // clock
    input         RES,          // reset

    input         RD,           // bus read
    input         WR,           // bus write
    input  [ 3:0] BE,           // byte enable
    input  [31:0] DATAI,        // data input
    output [31:0] DATAO,        // data output
    output        IRQ,          // interrupt req

    output        CSN,          // SPI CSN output (active LOW)
    output        SCK,          // SPI clock output
//`ifdef SPI3WIRE
    inout         MOSI,         // SPI master data output, slave data input; or SDI/O (3-wire mode)
//`else
//    output        MOSI,         // SPI master data output, slave data input
//`endif
    input         MISO,         // SPI master data input, slave data output

`ifdef SIMULATION
    output reg    ESIMREQ = 0,
    input         ESIMACK,
`endif

    output [3:0]  DEBUG         // osc debug
);

//    reg [8:0] NWR = 0;
    reg [31:0] spi_mosi_data = 0;
    wire [31:0] spi_miso_data;
    reg [4:0] spi_nbits = 0;
    reg spi_request = 0;
    wire spi_ready;
    wire [7:0] status;
//    wire spi_busy = ~CSN;
    wire spi_busy = 0;
    assign status = {6'b0, spi_ready & ~WR & ~spi_request, spi_busy};
    assign DATAO = {status, spi_miso_data[23:16], spi_miso_data[15:8], spi_miso_data[7:0]};
`ifdef NO_SPI_IRQ
    assign IRQ = 0;
`else
    assign IRQ = spi_busy;
`endif
    reg spimaster_nreset = 1'b1;
    always @(posedge CLK) begin
        if (RES) begin
            spi_mosi_data <= 0;
            spi_nbits <= 0;
            spi_request <= 0;
            spimaster_nreset <= 1'b1;
        end else begin
            if (WR) begin
//                NWR <= NWR + 1;
                spi_request <= 1;
                if (BE == 4'b1111) begin
                    spi_mosi_data <= DATAI;
                    if (DATAI[31:24] == 8'b0) begin
                        spi_nbits <= 5'd23;             // 24 bits
                    end else begin
                        spi_nbits <= 5'd31;             // 32 bits internal reset-glitch trick
                        spimaster_nreset <= 1'b0;
                    end
                end else if (BE == 4'b0011) begin
                    spi_nbits <= 5'd15;                 // 16 bits
                    spi_mosi_data <= DATAI[15:0];
                end else begin
                    spi_request <= 0;                   // ignore any other writes
                end
            end else begin
                spi_request <= 0;
                //spi_nbits <= 0;
                spimaster_nreset <= 1'b1;
            end
        end
    end

    spi_master #(.DIV_COEF(DIV_COEF)) spi_master1 (
        .clk_in(CLK),
        .nrst(~RES && spimaster_nreset),

        .spi_sck(SCK),
        .spi_mosi(MOSI),
        .spi_miso(MISO),
        .spi_csn(CSN),

        .mosi_data(spi_mosi_data),
        .miso_data(spi_miso_data),
        .nbits(spi_nbits),

        .request(spi_request),
        .ready(spi_ready)
    );

    assign DEBUG = 0;
endmodule
