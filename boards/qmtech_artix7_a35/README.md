## QMTech Artix-7 A35

The QMTech Artix-7 A35 is a set of carrier and core boards manufactured by
QMTech and available at AliExpress.  The core board is compatible with other
core boards, such as the Artix-7 A100 and the Spartan-7 LX16, which is
available both in DDR and SDRAM setups.  As in the case of other QMTech
boards, the Artix-7 A35 lacks an on-board JTAG, so a cheap Chinese JTAG
adapter is also required.  However, although the core board also lacks an
USB/serial, the carrier board provides a cp2102, so no additional USB/serial
adapter is required.  Regarding the software, you will need Vivado for
Windows or Lnux to build and program the FPGA.  I am working here with
Vivado version 2018.2 and it requires 18GB of disk space.  Newer versions
will probably require more, but it is possible reduce the space when you
avoid the Zynq/ARM support.  Although the Vivado is huge, the operation is
less erratic when compared with ISE, in special regarding the USB/JTAG
support.

Regarding the board features, in the core board we can find:

- a XC7A35 FPGA w/ 256 pins
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

Instructions:

- open the darksocv.xpr in Vivado (see how to install Vivado [here](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2018_2/ug973-vivado-release-notes-install-license.pdf))
- build the FPGA bitstream (no need to build the ROM/RAM files)
- open the hardware manager
- connect to FPGA and program it with the generated bitstream
- connect to the UART with the speed of 115200 bps
- when programmed, you must see the darkriscv welcome banner
