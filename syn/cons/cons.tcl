####################################clock##########################################

create_clock -name fun_clk -period 10 -waveform {0 5} [get_ports fun_clk]
#create_clock -name scan_clk -period 100 -waveform {0 50} [get_ports scan_clk]
set_clock_uncertainty -setup 0.45 [get_clocks fun_clk]
set_clock_uncertainty -hold 0.45 [get_clocks fun_clk]

###################################external#############################################

set_input_delay -clock fun_clk -max 1 [remove_from_collection [all_inputs] {fun_clk}]
set_output_delay -clock fun_clk -max 1 [all_outputs]
set_driving_cell -lib_cell IBUFFX2_HVT [remove_from_collection [all_inputs] {fun_clk}]
set_load 20 [all_outputs]

#################################optmization############################################

set_ideal_network [get_clocks fun_clk]
#set_ideal_network [get_clocks scan_clk]
set_ideal_network [get_ports fun_reset]
set_ideal_network [get_ports scan_reset]
set_ideal_network [get_ports test_mode]

set_max_transition 0.5 [current_design]
set_max_capacitance 300 [current_design]
set_max_fanout 5 [current_design]

###################################others#################################################

set_case_analysis 0 [get_ports test_mode]
set_dont_use [get_lib_cell */*AND3*]
