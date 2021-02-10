## AliExpress HPC 40GbE K420 (Kintex-7 HPC V2)

The correct name for this board is "Kintex-7 HPC V2", but is more widely
know as "Aliexpress HPC 40GbE K420" board, since there are lots of HPC
boards in the Aliexpress site. In fact, this board is not manufactured
anymore, instead there is an updated Kintex-7 HPC V3 available.

The Kintex-7 HPC V2 board includes:

- a XC7K420 FPGA w/ 910 pins
- lots pf high-speed clocks: 100MHz, 125MHz, 133MHz and 156MHz
- on-board USB/serial (CH340)
- on-board SPI FLASH (N25Q256)
- on-board 2xSFP+ (for up to 2x10Gbps)
- on-board 2xQSFP (for up to 2x40Gbps)
- on-board dual-channel 1033MHz DDR3
- 16 LEDs (they appears to be reversed!)
- 2 swiches
- 4 SMA connectors
- SATA interface
- PCIe 8x
- 3x different JTAG connectors (you need an external JTAG adapter!)
- support for darkriscv running at 240MHz (single-thread) 
- multithread support up to 128 threads (120MHz)

Unfortunately, there is no information yet about the HPC V3, but I guess the
new board is more or less the same as the old board.
