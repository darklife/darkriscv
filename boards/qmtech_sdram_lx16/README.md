## QMTech SDRAM LX16

Although the QMTech SDRAM LX16 lacks on-board JTAG and USB/serial, it is a
very cheap and interesting board.  In fact, is so cheap that is possible buy
lots of boards and connect them via high-speed links!  :)

With an external Xilinx JTAG cable and an external USB/serial converter, the
board works very well and provides lots of IO pins.

The board includes:

- a XC6SLX16 FPGA w/ 256 pins
- 50MHz clock
- on-board SPI FLASH
- on-board SDRAM (classical MT48LC16M16A2
- two LEDs
- lots and lots of GPIO pins

As long the QMTech SDRAM LX16 is compatible with the QMTech development kit
based in the Artix-7, I managed to adapt the board and use the same
peripherals:

- USB/serial
- GMII PHY
- VGA interface
- more LEDs
- more switchs
- more GPIOs

Currently, only the USB/serial adapter is supported.


