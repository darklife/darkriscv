set sdc_version 2.0

set clk_name CLK
set clk_port_name CLK
set clk_period 2000

set clk_port [get_ports $clk_port_name]
create_clock -period $clk_period -waveform [list 0 [expr $clk_period / 2]] -name $clk_name $clk_port

set non_clk_inputs  [lsearch -inline -all -not -exact [all_inputs] $clk_port]
set all_register_outputs [get_pins -of_objects [all_registers] -filter {direction == output}]
set_max_delay [expr {[info exists in2reg_max] ? $in2reg_max : 80}] -from $non_clk_inputs -to [all_registers]
set_max_delay [expr {[info exists reg2out_max] ? $reg2out_max : 80}] -from $all_register_outputs -to [all_outputs]
set_max_delay [expr {[info exists in2out_max] ? $in2out_max : 80}] -from $non_clk_inputs -to [all_outputs]
# group_path -name in2reg -from $non_clk_inputs -to [all_registers]
# group_path -name reg2out -from [all_registers] -to [all_outputs]
# group_path -name in2out -from $non_clk_inputs -to [all_outputs]
