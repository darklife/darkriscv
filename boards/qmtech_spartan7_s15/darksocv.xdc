# QMTech Spartan-7 board

set_property CFGBVS VCCO                        [current_design]
set_property CONFIG_VOLTAGE 3.3                 [current_design]

set_property -dict { PACKAGE_PIN H11 IOSTANDARD LVCMOS33 } [get_ports { XCLK }];
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports { XCLK }];

set_property -dict { PACKAGE_PIN B6  IOSTANDARD LVCMOS33 } [get_ports { XRES }];

set_property -dict { PACKAGE_PIN N4  IOSTANDARD LVCMOS33 } [get_ports { UART_RXD }];
set_property -dict { PACKAGE_PIN P5  IOSTANDARD LVCMOS33 } [get_ports { UART_TXD }];

set_property -dict { PACKAGE_PIN E4  IOSTANDARD LVCMOS33 } [get_ports { LED[3] }];
set_property -dict { PACKAGE_PIN B1  IOSTANDARD LVCMOS33 } [get_ports { LED[2] }];
set_property -dict { PACKAGE_PIN L5  IOSTANDARD LVCMOS33 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN C4  IOSTANDARD LVCMOS33 } [get_ports { LED[0] }];

set_property -dict { PACKAGE_PIN B5  IOSTANDARD LVCMOS33 } [get_ports { DEBUG[3] }];
set_property -dict { PACKAGE_PIN D3  IOSTANDARD LVCMOS33 } [get_ports { DEBUG[2] }];
set_property -dict { PACKAGE_PIN A3  IOSTANDARD LVCMOS33 } [get_ports { DEBUG[1] }];
set_property -dict { PACKAGE_PIN A2  IOSTANDARD LVCMOS33 } [get_ports { DEBUG[0] }];
