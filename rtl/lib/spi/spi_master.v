/*
    SPI Master (3/4-wire support, flexible divider coefficient)
    Copyright (C) 2025 Nicolas Sauzede (nicolas dot sauzede at gmail dot com)
    MAX10 Demos
    Copyright (C) 2016-2020 Victor Pecanins (vpecanins at gmail dot com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
`timescale 1ns / 1ps
/*
    SPI master
    - 3/4-wire mode support (4-wire by default)
    - configurable flexible divider coefficient
    Note that it is mainly targeting the STMicro LIS3DH sensor SPI protocol.
    In particular:
    - SPI clock polarity/phase
    - 3-wire mode (ie: tristate window)
    Maybe there are some specifics that should/could be reworked to make it more general..

    Divider coefficient (10000 by default when parameter DIV_COEF==0) can be changed:
    - set nbits=5'd0
    - set mosi_data[31:16]=16'h8080    `set divcoef as mosi_data[15:0]`
    - set mosi_data[15:0]=divider      (eg: 16'h4e20 (20000))
    - set request=1
    - then after some clocks:
     - set request=0

    Define `SPI3WIRE to implement 3-wire mode support. Must then be enabled (see below) to switch the SPI master to 3-wire mode.
    (SPI slave must also be set to 3-wire by some means accordingly of course)
    To enable the 3-wire mode (or disable it to standard/default 4-wire mode):
    - set nbits=5'd0
    - then either:
     - set mosi_data[31:0]=16'h81010000 `set 3-wire on`
    - or:
     - set mosi_data[31:0]=16'h81000000 `set 3-wire off (default 4-wire)`
    - set request=1
    - then after some clocks:
     - set request=0
*/
module spi_master #( parameter integer DIV_COEF = 0 ) (
    input               clk_in,         // Logic clock
    input               nrst,           // SPI is active when nreset is HIGH

    input               request,        // Request to start transfer: Active HIGH
    input   [4:0]       nbits,          // Number of bits (nbits=15 => 16; nbits=0 is reserved)
    input  [31:0]       mosi_data,      // Parallel FPGA data write to SPI
    output [31:0]       miso_data,      // Parallel FPGA data read from SPI
    output              ready,          // Active HIGH when transfer has finished

    output              spi_csn,        // SPI CSN output (active LOW)
    output              spi_sck,        // SPI clock output
    inout               spi_mosi,       // SPI master output slave input (default 4-wire); or m/s i/o (3-wire enabled)
    input               spi_miso        // SPI master data input, slave data output
);
`ifdef SPI_DIV_COEF
    localparam div_coef_ = `SPI_DIV_COEF;
`else
    localparam div_coef_ = (DIV_COEF == 0) ? 16'd10000 : DIV_COEF - 1;
`endif

    localparam
        STATE_Idle = 0,
        STATE_Run = 1,
        STATE_High = 2,
        STATE_Low = 3,
        STATE_Finish = 4,
        STATE_End = 5,
        STATE_Config = 6;
    reg [2:0] state = STATE_Idle;
    reg csnff = 1;
    reg sckff = 1;
    reg mosiff = 1;
    reg readyff = 0;
    reg [31:0] mosi_reg = 0;
    reg [31:0] miso_reg = 0;
    reg [4:0] nbits_reg = 0;
    reg [4:0] bit_counter = 0;
    reg oe = 1'b0;
    reg rd = 1'b0;
`ifdef SPI3WIRE
    reg spi3w = 1'b0;
    reg rd_tri = 1'b0;
//    assign spi_mosi = spi3w ? (oe ? mosiff : 1'bz) : mosiff;
    assign spi_mosi = !oe || (spi3w && rd_tri) ? 1'bz : mosiff;
//    assign spi_mosi = !oe ? 1'bz : mosiff;
`else
    reg rd_tri = 0;             // should remove
    reg spi3w = 0;              // should remove
    assign spi_mosi = oe ? mosiff : 1'bz;
`endif
    assign ready = readyff;
    assign miso_data = miso_reg;
    assign spi_csn = oe ? csnff : 1'bz;
    assign spi_sck = oe ? sckff : 1'bz;

    // Frequency divider
    reg divider_out = 0;
    reg [15:0] divider = 0;
    reg [15:0] div_coef = div_coef_;
    reg configure = 0;
    always @(posedge clk_in) begin
        if (!nrst || configure) begin
            divider <= 0;
            divider_out <= 0;
            if (nrst && configure) begin
                div_coef <= (nbits == 5'd0) && (mosi_data[31] && mosi_data[23]) ? mosi_data[15:0] : div_coef;
            end
        end else begin
            if (divider <= div_coef) begin
                divider <= divider + 16'd1;
                divider_out <= 0;
            end else begin
                divider <= 0;
                divider_out <= 1;
            end
        end
    end

    always @(posedge clk_in) begin
        if (!nrst) begin
`ifdef SPI3WIRE
            rd_tri <= 0;
`endif
            oe <= 0;
            rd <= 0;
            csnff <= 1;
            sckff <= 1;
            mosiff <= 1;
            readyff <= 0;
            mosi_reg <= 0;
            miso_reg <= 0;
            nbits_reg <= 0;
            bit_counter <= 0;
            state <= STATE_Idle;
        end else begin
            case (state)
                STATE_Idle: begin
                    configure <= 0;
                    if (request) begin
                        if (nbits == 5'd0) begin
`ifdef SPI3WIRE
                            spi3w <= (nbits == 5'd0) && (mosi_data[31] && mosi_data[24]) ? mosi_data[16] : spi3w;
`endif
                            configure <= 1;     // give divider process a chance to configure for one clock
                        end else begin
                            oe <= 1;
                            mosi_reg <= mosi_data;
                            nbits_reg <= nbits;
                            bit_counter <= nbits;
                            csnff <= 0;
                            readyff <= 0;
                            state <= STATE_Run;
                        end
                    end
                end
                STATE_Run: begin
                    if (nbits_reg == 5'd31) begin
                        rd <= mosi_reg[31];
                        state <= STATE_High;
                    end else begin
                        mosi_reg <= mosi_reg << 1;
                        nbits_reg <= nbits_reg + 5'd1;
                    end
                end
                STATE_High: if (divider_out) begin
                    sckff <= 0;
                    mosiff <= mosi_reg[31];
                    state <= STATE_Low;
`ifdef SPI3WIRE
                        if (bit_counter == (nbits - 5'd8)) begin
                            if (spi3w && rd) begin
                                rd_tri <= 1;
                            end
                        end
`endif
                end
                STATE_Low: if (divider_out) begin
                    sckff <= 1;
`ifdef SPI3WIRE
                    miso_reg <= {miso_reg[30:0], spi3w ? spi_mosi : rd ? spi_miso : 1'b0};
`else
                    miso_reg <= {miso_reg[30:0], spi_miso};
`endif
                    if (bit_counter == 5'd0) begin
                        state <= STATE_Finish;
                    end else begin
`ifdef SPI3WIRE_
                        if (bit_counter == (nbits - 5'd8)) begin
                            if (spi3w && rd) begin
                                rd_tri <= 1;
                            end
                        end
`endif
                        bit_counter <= bit_counter - 5'd1;
                        mosi_reg <= mosi_reg << 1;
                        state <= STATE_High;
                    end
                end
                STATE_Finish: if (divider_out) begin
                    csnff <= 1;
                    state <= STATE_End;
                end
                STATE_End: if (divider_out) begin
                    readyff <= 1;
                    rd <= 0;
                    oe <= 0;
`ifdef SPI3WIRE
                    rd_tri <= 0;
`endif
                    state <= STATE_Idle;
                end
            endcase
        end
    end
endmodule
