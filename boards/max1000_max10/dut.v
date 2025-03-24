`timescale 1ns / 1ps
`include "../../rtl/config.vh"

module dut (
    input rx,
    output tx,
`ifdef SPI
    input spi_miso,
    output spi_mosi,
    output spi_csn,
    output spi_sck,
    inout [15:0] gpio,
`endif
    output [15:0] leds,
    input reset,
    input clk
);
    input [31:0] iport;
    darksocv soc0 (
        .UART_RXD(rx),  // UART receive line
        .UART_TXD(tx),  // UART transmit line
`ifdef SPI
        .SPI_SCK(spi_sck),      // SPI clock output
        .SPI_MOSI(spi_mosi),    // SPI master data output, slave data input
        .SPI_MISO(spi_miso),    // SPI master data input, slave data output
        .SPI_CSN(spi_csn),      // SPI CSN output (active LOW)
`else
        .GPIO(gpio),
        .IPORT(iport),
`endif
        .LED(leds),       // on-board leds

        .XCLK(clk),      // external clock
        .XRES(reset)      // external reset
    );
endmodule
