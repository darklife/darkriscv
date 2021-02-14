## AliExpress HPC 40GbE XCKKU040 (Kintex Ultrascape HPC)

This board is widely know as "Aliexpress HPC 40GbE XCKU040" board, from the
same source as the K420 board. Although the FPGA is more powerful, the board
is cheaper when compaared to the more complete board and, in fact, is
probable the cheaper ultrascale board.

The Kintex Ultrascale HPC board includes:

- a XCKU040 FPGA w/ 1156 pins
- not sure about the speed grade, guessing it is -2!
- high-speed clocks: 100MHz 156MHz
- on-board USB/serial (CH340)
- on-board SPI FLASH (N25QL256)
- on-board 2xQSFP (for up to 2x40Gbps)
- 8 LEDs 
- 1 swiches
- PCIe 8x
- TAG connector (you need an external JTAG adapter!)
- support for darkriscv running at 250MHz (single-thread)
- tested up to 300MHz w/ overclock 
- 2x I2C setup memories (AT24C04), probably one for each QSFP?!

Unfortunately, there is no scheatic for this board, just an Excel with the
pins, with some labels in chinese and some small errors, but not bad at all.

This board appears to work well when overclocked and, in fact, it exceeds
the darkriscv frequency register, so the frequencies above 250MHz will
appears weird! 

For example, when working at 400MHz::

    boot0: text@0 data@6268 stack@8192 (1924 bytes free)
    board: aliexpress hpc/40gbe ku040 (id=10)
    build: Mon, 01 Feb 2021 04:06:48 -0300 for rv32e
    core0/thread0: darkriscv@144.00MHz rv32e <- frequency reg overflow
    uart0: 115200 bps (div=2314)
    timr0: frequency=40075Hz (io.timer=399) <-- 400M/(399+1)=1us

Finally, be careful that the Ultrascale needs TWO boot images, so you need
generate the primary and secondary MCS file (just select in Vivado the
option to generate the FLASH image and the wizard will generate them).
