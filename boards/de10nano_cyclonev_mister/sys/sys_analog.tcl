#============================================================
# SDIO
#============================================================
set_location_assignment PIN_AF25 -to SDIO_DAT[0]
set_location_assignment PIN_AF23 -to SDIO_DAT[1]
set_location_assignment PIN_AD26 -to SDIO_DAT[2]
set_location_assignment PIN_AF28 -to SDIO_DAT[3]
set_location_assignment PIN_AF27 -to SDIO_CMD
set_location_assignment PIN_AH26 -to SDIO_CLK
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to SDIO_*

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDIO_*
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SDIO_DAT[*]
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to SDIO_CMD

#============================================================
# VGA
#============================================================
set_location_assignment PIN_AE17 -to VGA_R[0]
set_location_assignment PIN_AE20 -to VGA_R[1]
set_location_assignment PIN_AF20 -to VGA_R[2]
set_location_assignment PIN_AH18 -to VGA_R[3]
set_location_assignment PIN_AH19 -to VGA_R[4]
set_location_assignment PIN_AF21 -to VGA_R[5]

set_location_assignment PIN_AE19 -to VGA_G[0]
set_location_assignment PIN_AG15 -to VGA_G[1]
set_location_assignment PIN_AF18 -to VGA_G[2]
set_location_assignment PIN_AG18 -to VGA_G[3]
set_location_assignment PIN_AG19 -to VGA_G[4]
set_location_assignment PIN_AG20 -to VGA_G[5]

set_location_assignment PIN_AG21 -to VGA_B[0]
set_location_assignment PIN_AA20 -to VGA_B[1]
set_location_assignment PIN_AE22 -to VGA_B[2]
set_location_assignment PIN_AF22 -to VGA_B[3]
set_location_assignment PIN_AH23 -to VGA_B[4]
set_location_assignment PIN_AH21 -to VGA_B[5]

set_location_assignment PIN_AH22 -to VGA_HS
set_location_assignment PIN_AG24 -to VGA_VS

set_location_assignment PIN_AH27 -to VGA_EN
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to VGA_EN

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to VGA_*
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to VGA_*

#============================================================
# AUDIO
#============================================================
set_location_assignment PIN_AC24 -to AUDIO_L
set_location_assignment PIN_AE25 -to AUDIO_R
set_location_assignment PIN_AG26 -to AUDIO_SPDIF
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to AUDIO_*
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to AUDIO_*

#============================================================
# I/O #1
#============================================================
set_location_assignment PIN_Y15 -to LED_USER
set_location_assignment PIN_AA15 -to LED_HDD
set_location_assignment PIN_AG28 -to LED_POWER

set_location_assignment PIN_AH24 -to BTN_USER
set_location_assignment PIN_AG25 -to BTN_OSD
set_location_assignment PIN_AG23 -to BTN_RESET

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED_*
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to BTN_*
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to BTN_*
