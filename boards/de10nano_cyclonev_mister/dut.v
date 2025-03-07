`timescale 1ns / 1ps
`include "../../rtl/config.vh"

module dut (
    input rx,
    output tx,
    output [7:0] leds,
    input reset,
    input clk
);

	 darksocv soc0 (
		.UART_RXD(rx),  // UART receive line
		.UART_TXD(tx),  // UART transmit line

		.LED(leds[3:0]),       // on-board leds
		.DEBUG(leds[7:4]),      // osciloscope

		.XCLK(clk),      // external clock
		.XRES(reset)      // external reset
	);
endmodule
