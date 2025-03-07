`timescale 1ns / 1ps
`include "../../rtl/config.vh"

module top (
        input CLK12M,
        input USER_BTN,
        output [7:0] LED,
        inout [8:1] PIO,
        inout [5:0] BDBUS,
        inout [14:0] D
);
    wire clk;
    pll pll0 (
        .inclk0(CLK12M),
        .c0(clk)
    );
    wire [15:0] leds;
    assign LED = leds[7:0];
    dut dut1 (
        .rx(BDBUS[0]),          // BDBUS[0] is USB UART TX (FPGA RX)
        .tx(BDBUS[1]),          // BDBUS[1] is USB UART RX (FPGA TX)
        .leds(leds),
        .reset(~USER_BTN),
        .clk(clk)
    );
endmodule
