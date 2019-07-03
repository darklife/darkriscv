## Xilinx AC701 A200

The AC701 from Xilinx is a very complete and expensive board based in the
Artix-7 A200.  Unfortunately, the board was not mine and I borrowed from a
friend for a short time only in order to make a quick test, in a way that
the DarkRISCV worked at 90MHz in the board.  Later, after the board was
already returned, I made a better clock scheme in order to generate 180MHz
and the image was built w/ a timing score zero, which means that the build
is probably working, althrough there is no way to test it at this moment.

The board includes:

- a XC7A200 FPGA w/ 676 pins
- lots of clock references, but I found only the 90MHz clock
- on-board SPI FLASH
- on-board DDR3
- on-board 1Gbps PHY
- lots and lots of other features!
