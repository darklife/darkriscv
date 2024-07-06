## Verilog Sources

Description of current Verilog files:

- darkriscv.v: the DarkRISCV core
- darksocv.v: a primitive system on-chip w/ the DarkRISCV core wired to ROM and RAM memories and IO
- darkuart.v: a small full-duplex UART w/ programmable baud-rate
- darkpll.v: different PLLs for different FPGAs
- config.vh: configuration file!

- lib: 3rd party modules:
  - SDRAM controller: from kianRiscV
    https://github.com/splinedrive/kianRiscV/blob/master/linux_socs/kianv_harris_mcycle_edition/sdram/mt48lc16m16a2_ctrl.v

TODO:

- add a cache controller
- add a SPI controller 
- add a GbE controller
