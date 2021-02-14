# HPC 2x40GbE XCKU040 board

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CCLK_TRISTATE TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN PULLUP [current_design]

set_property -dict { PACKAGE_PIN D23 IOSTANDARD LVCMOS18 } [get_ports { XCLK }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { XCLK }];

set_property -dict { PACKAGE_PIN AP10  IOSTANDARD LVCMOS33 } [get_ports { XRES }];

set_property -dict { PACKAGE_PIN G27  IOSTANDARD LVCMOS33 } [get_ports { UART_RXD }];
set_property -dict { PACKAGE_PIN H27  IOSTANDARD LVCMOS33 } [get_ports { UART_TXD }];

set_property -dict { PACKAGE_PIN B25  IOSTANDARD LVCMOS18 } [get_ports { LED[3] }];
set_property -dict { PACKAGE_PIN C26  IOSTANDARD LVCMOS18 } [get_ports { LED[2] }];
set_property -dict { PACKAGE_PIN B26  IOSTANDARD LVCMOS18 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN A27  IOSTANDARD LVCMOS18 } [get_ports { LED[0] }];

set_property -dict { PACKAGE_PIN B27  IOSTANDARD LVCMOS18 } [get_ports { DEBUG[3] }];
set_property -dict { PACKAGE_PIN A28  IOSTANDARD LVCMOS18 } [get_ports { DEBUG[2] }];
set_property -dict { PACKAGE_PIN A29  IOSTANDARD LVCMOS18 } [get_ports { DEBUG[1] }];
set_property -dict { PACKAGE_PIN B29  IOSTANDARD LVCMOS18 } [get_ports { DEBUG[0] }];
