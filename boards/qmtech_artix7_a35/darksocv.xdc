# QMTech Spartan-7 board

set_property CFGBVS VCCO                        [current_design]
set_property CONFIG_VOLTAGE 3.3                 [current_design]

set_property -dict { PACKAGE_PIN N11 IOSTANDARD LVCMOS33 } [get_ports { XCLK }];
create_clock -add -name sys_clk_pin -period 20.00 -waveform {0 10} [get_ports { XCLK }];

set_property -dict { PACKAGE_PIN K5  IOSTANDARD LVCMOS33 } [get_ports { XRES }];

set_property -dict { PACKAGE_PIN T15  IOSTANDARD LVCMOS33 } [get_ports { UART_RXD }];
set_property -dict { PACKAGE_PIN T14  IOSTANDARD LVCMOS33 } [get_ports { UART_TXD }]; 

set_property -dict { PACKAGE_PIN M1  IOSTANDARD LVCMOS33 } [get_ports { LED[3] }];
set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports { LED[2] }];
set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports { LED[1] }];
set_property -dict { PACKAGE_PIN E6  IOSTANDARD LVCMOS33 } [get_ports { LED[0] }];

set_property -dict { PACKAGE_PIN N4  IOSTANDARD LVCMOS33 } [get_ports { DEBUG[3] }];
set_property -dict { PACKAGE_PIN R1  IOSTANDARD LVCMOS33 } [get_ports { DEBUG[2] }];
set_property -dict { PACKAGE_PIN T2  IOSTANDARD LVCMOS33 } [get_ports { DEBUG[1] }];
set_property -dict { PACKAGE_PIN T3  IOSTANDARD LVCMOS33 } [get_ports { DEBUG[0] }];
