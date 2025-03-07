set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEBA6U23I7
set_global_assignment -name DEVICE_FILTER_PACKAGE UFBGA
set_global_assignment -name DEVICE_FILTER_PIN_COUNT 672
set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 7

#============================================================
# ADC
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_CONVST
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_SCK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_SDI
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ADC_SDO
set_location_assignment PIN_U9 -to ADC_CONVST
set_location_assignment PIN_V10 -to ADC_SCK
set_location_assignment PIN_AC4 -to ADC_SDI
set_location_assignment PIN_AD4 -to ADC_SDO

#============================================================
# ARDUINO
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ARDUINO_IO[*]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to ARDUINO_IO[*]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to ARDUINO_IO[*]

#============================================================
# I2C LEDS/BUTTONS
#============================================================
set_location_assignment PIN_U14 -to IO_SCL
set_location_assignment PIN_AG9 -to IO_SDA
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to IO_S*
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to IO_S*
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to IO_S*

#============================================================
# USER PORT
#============================================================
set_location_assignment PIN_AF17 -to USER_IO[6]
set_location_assignment PIN_AF15 -to USER_IO[5]
set_location_assignment PIN_AG16 -to USER_IO[4]
set_location_assignment PIN_AH11 -to USER_IO[3]
set_location_assignment PIN_AH12 -to USER_IO[2]
set_location_assignment PIN_AH9 -to USER_IO[1]
set_location_assignment PIN_AG11 -to USER_IO[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to USER_IO[*]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to USER_IO[*]
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to USER_IO[*]

#============================================================
# SDIO_CD or SPDIF_OUT
#============================================================
set_location_assignment PIN_AH7 -to SDCD_SPDIF
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to SDCD_SPDIF
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDCD_SPDIF
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SDCD_SPDIF

#============================================================
# SDRAM
#============================================================
set_location_assignment PIN_Y11 -to SDRAM_A[0]
set_location_assignment PIN_AA26 -to SDRAM_A[1]
set_location_assignment PIN_AA13 -to SDRAM_A[2]
set_location_assignment PIN_AA11 -to SDRAM_A[3]
set_location_assignment PIN_W11 -to SDRAM_A[4]
set_location_assignment PIN_Y19 -to SDRAM_A[5]
set_location_assignment PIN_AB23 -to SDRAM_A[6]
set_location_assignment PIN_AC23 -to SDRAM_A[7]
set_location_assignment PIN_AC22 -to SDRAM_A[8]
set_location_assignment PIN_C12 -to SDRAM_A[9]
set_location_assignment PIN_AB26 -to SDRAM_A[10]
set_location_assignment PIN_AD17 -to SDRAM_A[11]
set_location_assignment PIN_D12 -to SDRAM_A[12]
set_location_assignment PIN_Y17 -to SDRAM_BA[0]
set_location_assignment PIN_AB25 -to SDRAM_BA[1]
set_location_assignment PIN_E8 -to SDRAM_DQ[0]
set_location_assignment PIN_V12 -to SDRAM_DQ[1]
set_location_assignment PIN_D11 -to SDRAM_DQ[2]
set_location_assignment PIN_W12 -to SDRAM_DQ[3]
set_location_assignment PIN_AH13 -to SDRAM_DQ[4]
set_location_assignment PIN_D8 -to SDRAM_DQ[5]
set_location_assignment PIN_AH14 -to SDRAM_DQ[6]
set_location_assignment PIN_AF7 -to SDRAM_DQ[7]
set_location_assignment PIN_AE24 -to SDRAM_DQ[8]
set_location_assignment PIN_AD23 -to SDRAM_DQ[9]
set_location_assignment PIN_AE6 -to SDRAM_DQ[10]
set_location_assignment PIN_AE23 -to SDRAM_DQ[11]
set_location_assignment PIN_AG14 -to SDRAM_DQ[12]
set_location_assignment PIN_AD5 -to SDRAM_DQ[13]
set_location_assignment PIN_AF4 -to SDRAM_DQ[14]
set_location_assignment PIN_AH3 -to SDRAM_DQ[15]
set_location_assignment PIN_AG13 -to SDRAM_DQML
set_location_assignment PIN_AF13 -to SDRAM_DQMH
set_location_assignment PIN_AD20 -to SDRAM_CLK
set_location_assignment PIN_AG10 -to SDRAM_CKE
set_location_assignment PIN_AA19 -to SDRAM_nWE
set_location_assignment PIN_AA18 -to SDRAM_nCAS
set_location_assignment PIN_Y18 -to SDRAM_nCS
set_location_assignment PIN_W14 -to SDRAM_nRAS

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM_*
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to SDRAM_*
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM_*
set_instance_assignment -name FAST_OUTPUT_ENABLE_REGISTER ON -to SDRAM_DQ[*]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to SDRAM_DQ[*]
set_instance_assignment -name ALLOW_SYNCH_CTRL_USAGE OFF -to *|SDRAM_*

#============================================================
# SPI SD
#============================================================
set_location_assignment PIN_AE15 -to SD_SPI_CS
set_location_assignment PIN_AH8  -to SD_SPI_MISO
set_location_assignment PIN_AG8  -to SD_SPI_CLK
set_location_assignment PIN_U13  -to SD_SPI_MOSI
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to SD_SPI*
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SD_SPI*
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SD_SPI*


#============================================================
# CLOCK
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FPGA_CLK1_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FPGA_CLK2_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to FPGA_CLK3_50
set_location_assignment PIN_V11 -to FPGA_CLK1_50
set_location_assignment PIN_Y13 -to FPGA_CLK2_50
set_location_assignment PIN_E11 -to FPGA_CLK3_50

#============================================================
# HDMI
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HDMI_I2C_*
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HDMI_I2S
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HDMI_LRCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HDMI_MCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HDMI_SCLK
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to HDMI_TX_*
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to HDMI_TX_D[*]
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to HDMI_TX_DE
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to HDMI_TX_HS
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to HDMI_TX_VS
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to HDMI_TX_CLK
set_location_assignment PIN_U10 -to HDMI_I2C_SCL
set_location_assignment PIN_AA4 -to HDMI_I2C_SDA
set_location_assignment PIN_T13 -to HDMI_I2S
set_location_assignment PIN_T11 -to HDMI_LRCLK
set_location_assignment PIN_U11 -to HDMI_MCLK
set_location_assignment PIN_T12 -to HDMI_SCLK
set_location_assignment PIN_AG5 -to HDMI_TX_CLK
set_location_assignment PIN_AD19 -to HDMI_TX_DE
set_location_assignment PIN_AD12 -to HDMI_TX_D[0]
set_location_assignment PIN_AE12 -to HDMI_TX_D[1]
set_location_assignment PIN_W8 -to HDMI_TX_D[2]
set_location_assignment PIN_Y8 -to HDMI_TX_D[3]
set_location_assignment PIN_AD11 -to HDMI_TX_D[4]
set_location_assignment PIN_AD10 -to HDMI_TX_D[5]
set_location_assignment PIN_AE11 -to HDMI_TX_D[6]
set_location_assignment PIN_Y5 -to HDMI_TX_D[7]
set_location_assignment PIN_AF10 -to HDMI_TX_D[8]
set_location_assignment PIN_Y4 -to HDMI_TX_D[9]
set_location_assignment PIN_AE9 -to HDMI_TX_D[10]
set_location_assignment PIN_AB4 -to HDMI_TX_D[11]
set_location_assignment PIN_AE7 -to HDMI_TX_D[12]
set_location_assignment PIN_AF6 -to HDMI_TX_D[13]
set_location_assignment PIN_AF8 -to HDMI_TX_D[14]
set_location_assignment PIN_AF5 -to HDMI_TX_D[15]
set_location_assignment PIN_AE4 -to HDMI_TX_D[16]
set_location_assignment PIN_AH2 -to HDMI_TX_D[17]
set_location_assignment PIN_AH4 -to HDMI_TX_D[18]
set_location_assignment PIN_AH5 -to HDMI_TX_D[19]
set_location_assignment PIN_AH6 -to HDMI_TX_D[20]
set_location_assignment PIN_AG6 -to HDMI_TX_D[21]
set_location_assignment PIN_AF9 -to HDMI_TX_D[22]
set_location_assignment PIN_AE8 -to HDMI_TX_D[23]
set_location_assignment PIN_T8 -to HDMI_TX_HS
set_location_assignment PIN_AF11 -to HDMI_TX_INT
set_location_assignment PIN_V13 -to HDMI_TX_VS

#============================================================
# KEY
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[1]
set_location_assignment PIN_AH17 -to KEY[0]
set_location_assignment PIN_AH16 -to KEY[1]

#============================================================
# LED
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[7]
set_location_assignment PIN_W15 -to LED[0]
set_location_assignment PIN_AA24 -to LED[1]
set_location_assignment PIN_V16 -to LED[2]
set_location_assignment PIN_V15 -to LED[3]
set_location_assignment PIN_AF26 -to LED[4]
set_location_assignment PIN_AE26 -to LED[5]
set_location_assignment PIN_Y16 -to LED[6]
set_location_assignment PIN_AA23 -to LED[7]

#============================================================
# SW
#============================================================
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[3]
set_location_assignment PIN_Y24 -to SW[0]
set_location_assignment PIN_W24 -to SW[1]
set_location_assignment PIN_W21 -to SW[2]
set_location_assignment PIN_W20 -to SW[3]

set_instance_assignment -name HPS_LOCATION HPSINTERFACEPERIPHERALSPIMASTER_X52_Y72_N111 -entity sys_top -to spi
set_instance_assignment -name HPS_LOCATION HPSINTERFACEPERIPHERALUART_X52_Y67_N111 -entity sys_top -to uart
set_instance_assignment -name HPS_LOCATION HPSINTERFACEPERIPHERALI2C_X52_Y60_N111 -entity sys_top -to hdmi_i2c

set_global_assignment -name PRE_FLOW_SCRIPT_FILE "quartus_sh:sys/build_id.tcl"

set_global_assignment -name CDF_FILE jtag.cdf
set_global_assignment -name QIP_FILE sys/sys.qip

