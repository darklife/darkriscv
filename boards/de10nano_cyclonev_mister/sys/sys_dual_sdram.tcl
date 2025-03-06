#============================================================
# Secondary SDRAM
#============================================================
set_location_assignment PIN_Y15  -to SDRAM2_DQ[0]
set_location_assignment PIN_AC24 -to SDRAM2_DQ[1]
set_location_assignment PIN_AA15 -to SDRAM2_DQ[2]
set_location_assignment PIN_AD26 -to SDRAM2_DQ[3]
set_location_assignment PIN_AG28 -to SDRAM2_DQ[4]
set_location_assignment PIN_AF28 -to SDRAM2_DQ[5]
set_location_assignment PIN_AE25 -to SDRAM2_DQ[6]
set_location_assignment PIN_AF27 -to SDRAM2_DQ[7]
set_location_assignment PIN_AG26 -to SDRAM2_DQ[14]
set_location_assignment PIN_AH27 -to SDRAM2_DQ[15]

set_location_assignment PIN_AG25 -to SDRAM2_DQ[13]
set_location_assignment PIN_AH26 -to SDRAM2_DQ[12]
set_location_assignment PIN_AH24 -to SDRAM2_DQ[11]
set_location_assignment PIN_AF25 -to SDRAM2_DQ[10]
set_location_assignment PIN_AG23 -to SDRAM2_DQ[9]
set_location_assignment PIN_AF23 -to SDRAM2_DQ[8]
set_location_assignment PIN_AG24 -to SDRAM2_A[12]
set_location_assignment PIN_AH22 -to SDRAM2_CLK
set_location_assignment PIN_AH21 -to SDRAM2_A[9]
set_location_assignment PIN_AG21 -to SDRAM2_A[11]
set_location_assignment PIN_AH23 -to SDRAM2_A[7]
set_location_assignment PIN_AA20 -to SDRAM2_A[8]
set_location_assignment PIN_AF22 -to SDRAM2_A[5]
set_location_assignment PIN_AE22 -to SDRAM2_A[6]
set_location_assignment PIN_AG20 -to SDRAM2_nWE
set_location_assignment PIN_AF21 -to SDRAM2_A[4]

set_location_assignment PIN_AG19 -to SDRAM2_nCAS
set_location_assignment PIN_AH19 -to SDRAM2_nRAS
set_location_assignment PIN_AG18 -to SDRAM2_nCS
set_location_assignment PIN_AH18 -to SDRAM2_BA[0]
set_location_assignment PIN_AF18 -to SDRAM2_BA[1]
set_location_assignment PIN_AF20 -to SDRAM2_A[10]
set_location_assignment PIN_AG15 -to SDRAM2_A[0]
set_location_assignment PIN_AE20 -to SDRAM2_A[1]
set_location_assignment PIN_AE19 -to SDRAM2_A[2]
set_location_assignment PIN_AE17 -to SDRAM2_A[3]

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SDRAM2_*
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to SDRAM2_*
set_instance_assignment -name FAST_OUTPUT_REGISTER ON -to SDRAM2_*
set_instance_assignment -name FAST_OUTPUT_ENABLE_REGISTER ON -to SDRAM2_DQ[*]
set_instance_assignment -name FAST_INPUT_REGISTER ON -to SDRAM2_DQ[*]
set_instance_assignment -name ALLOW_SYNCH_CTRL_USAGE OFF -to *|SDRAM2_*

set_global_assignment -name VERILOG_MACRO "DUAL_SDRAM=1"
