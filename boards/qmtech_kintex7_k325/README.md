## QMTech Kintex-7 K325

The QMTech Kintex-7 K325 is a set of carrier and core boards manufactured by
QMTech and available at AliExpress.  The core board is compatible with other
core boards, such as the Kintex-7 A100 and the Spartan-7 LX16, which is
available both in DDR and SDRAM setups.  As in the case of other QMTech
boards, the Kintex-7 K325 lacks an on-board JTAG, so a cheap Chinese JTAG
adapter is also required.  However, although the core board also lacks an
USB/serial, the carrier board provides a cp2102, so no additional USB/serial
adapter is required.  

Regarding the software, you will need ISE 14.7 or Vivado for Windows or
Linux to build and program the FPGA.  Also, you will need a temporary 30-day
licence in order to generate binaries to this FPGA (the default webpack free
versions does not support this device).

Regarding the board features, in the core board we can find:

- a XC7K325 FPGA w/ 676 pins
- 50MHz clock
- on-board SPI FLASH
- on-board DDR3
- one LED
- one switch (used as RESET)
- lots and lots of GPIO pins that are connected to the carrier board

You can find more documentation about this board here: http://www.chinaqmtech.com/download_fpga

In the carrier board we can find:

- USB/serial (cp2102)
- GMII PHY
- VGA interface w/ 12-bit DAC
- five LEDs
- five switches
- 3-digit x 7-segment disolay
- micro-SD card interface
- 2x PMOD connectors
- 1x digital camera connector

Currently, only the USB/serial adapter is supported.
