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
`endif
    inout [8:1] pio,
    output [15:0] leds,
    input reset,
    input clk
);
    wire [15:0] gpio;
    wire [31:0] iport;
    darksocv soc0 (
        .UART_RXD(rx),  // UART receive line
        .UART_TXD(tx),  // UART transmit line
`ifdef SPI
        .SPI_SCK(spi_sck),      // SPI clock output
        .SPI_MOSI(spi_mosi),    // SPI master data output, slave data input
        .SPI_MISO(spi_miso),    // SPI master data input, slave data output
        .SPI_CSN(spi_csn),      // SPI CSN output (active LOW)
`endif
        .LED(leds),       // on-board leds
        .GPIO(gpio),
        .IPORT(iport),

        .XCLK(clk),      // external clock
        .XRES(reset)      // external reset
    );
    wire [3:0] pmbuttons;
    wire [3:0] pmleds;
    assign pmleds = gpio[3:0];
    assign iport = {24'b0, pmbuttons};
    pmodbutled pmodbutled1(
        .pio(pio),
        .buttons(pmbuttons),
        .leds(pmleds)
    );

endmodule
