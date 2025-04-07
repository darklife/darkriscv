`timescale 1ns / 1ps
`include "../../rtl/config.vh"

module dut (
    input rx,
    output tx,
`ifdef SPI
    output spi_csn,
    output spi_sck,
    inout spi_mosi,
    input spi_miso,
`endif
    inout [8:1] pio,
    output [31:0] leds,
    input reset,
    input clk
);
    wire [31:0] oport;
    wire [31:0] iport;
    darksocv soc0 (
        .UART_RXD(rx),  // UART receive line
        .UART_TXD(tx),  // UART transmit line
`ifdef SPI
        .SPI_SCK(spi_sck),      // SPI clock output
        .SPI_MOSI(spi_mosi),    // SPI master data output, slave data input;  or SDI/O (3-wire mode)
        .SPI_MISO(spi_miso),    // SPI master data input, slave data output
        .SPI_CSN(spi_csn),      // SPI CSN output (active LOW)
`endif
        .LED(leds),       // on-board leds
        .IPORT(iport),
        .OPORT(oport),

        .XCLK(clk),      // external clock
        .XRES(reset)      // external reset
    );
`ifndef SPIBB
    wire [3:0] pmbuttons;
    wire [3:0] pmleds;
    assign pmleds = oport[3:0];
    assign iport = {24'b0, pmbuttons};
    pmodbutled pmodbutled1(
        .pio(pio),
        .buttons(pmbuttons),
        .leds(pmleds)
    );
`endif

endmodule
