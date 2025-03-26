/*
IMPORTANT:
Must place the Papilio wingbutled only on the rightmost PMOD PIO pins,
ie: avoid all 3.3V/GND pins!
Pmod    Wing    Out     In
PIO_08  GND     0
PIO_07  2V5     z
PIO_06  3V3     1
PIO_05  5V      z
PIO_04  LED4    leds[1]
PIO_03  PB4     z       buttons[1]
PIO_02  LED3    leds[0]
PIO_01  PB3     z       buttons[0]
*/
module pmodbutled (
    inout [8:1] pio,
    output [3:0] buttons,
    input [3:0] leds
);
    // Assign leds values to specific io pins
    assign pio[4] = leds[1];
    assign pio[2] = leds[0];

    assign pio[8] = 1'b0;       // GND
    assign pio[6] = 1'b1;       // 3V3

    // Set specific io pins to high impedance (Z)
    assign pio[7] = 1'bz;       // 2V5
    assign pio[5] = 1'bz;       // 5V
    assign pio[3] = 1'bz;
    assign pio[1] = 1'bz;

    // Assign io pin values to button outputs
    assign buttons[1] = pio[3];
    assign buttons[0] = pio[1];
endmodule

