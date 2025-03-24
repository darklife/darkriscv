# MAX1000 board (Trenz Electronic)

## General information
The Max1000 board is a small development board based on Intel/Altera Max10 family of FPGAs.\
It has a 10M08SAU169C8G chip and also includes the following peripherals:
* 64MBit SDRAM (16-bit data bus)
* 64Mbit Flash Memory
* Arrow USB Programmer2 on-board for programming; JTAG + Serial (FT2232H)
* 8 LEDs + 2 push-buttons
* 12 MHz MEMS Oscillator
* 3-axis accelerometer + thermal sensor
* Many headers: PMOD, Arduino MKR, JTAG, I/O..

For more detailed information, see here:\
https://wiki.trenz-electronic.de/display/PD/TEI0001+Getting+Started

The DarkRISCV/darksoc builds out-of-the box using Quartus command-line,
taking about ~40% of the on-chip logic for the SoC demo.
- It uses an altera pll QIP to transform 12=>32MHz (TODO: maybe integrate it into darkpll),
- and a simplified darkram based on altsyncram to properly infer BRAM (TODO: maybe integrate it into darkram).

## Instructions
Install Quartus with Max10 support, `srecord`, `awk`, `xxd`.\
Read/apply the Trenz Electronics docs to enable the max1000 support (eg: udev rules, ftdi driver etc..)\
Ensure that `QUARTUS` macro defined in `boards/max1000_max10/darksocv.mk` points to your Quartus install, then, from darkriscv root directory:\
Build the bitstream:
```
make all BOARD=max1000_max10
```
Program the device like this:
```
make install BOARD=max1000_max10
```
Finally connect at baudrate=115200 to the serial port (eg: /dev/ttyUSB0 or /dev/ttyUSB1) with `screen` (or any other terminal like Putty, etc..):
```shell
screen /dev/ttyUSB? 115200
```
and you should see DarkRISCV booting up:
```
...
board: max1000 max10 (id=19)
...
36253> led aa55
led = aa55
1>
```
You should see 0x55 on the 8 leds.

To clean the board-related objects:
```
make clean BOARD=max1000_max10
```

# SPI Support
Builtin SPI accelerometer sensor can be accessed by enabling the Verilog macro and selecting the spidemo application.
```shell
make clean all BOARD=max1000_max10 APPLICATION=spidemo
make install BOARD=max1000_max10
```
In putty:
```
...
       INSTRUCTION SETS WANT TO BE FREE

Welcome to DarkRISCV!

10335> sensor
out_x=0f10
out_x=0f10
out_x=0ef0
out_x=0ef0
out_x=0ef0
out_x=0f60
out_x=0f60
out_x=0ec0
out_x=0ec0
out_x=0e70
out_x=0e70
out_x=0e70
...
```
The sensor OUT_X reading is output on the serial port and drawn visually on the 8 leds.
