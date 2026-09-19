#############################set_libs##############################

set_app_var search_path "/home/ICer/Downloads/Lib/synopsys/models"
set_app_var target_library "saed90nm_max_hvt.db"
set_app_var link_library "* $target_library"

##############################handel###################################

sh rm -rf work
sh mkdir -p work
define_design_lib work -path ./work

##############################reuse_fm##################################

set design mips_16
set_svf ${design}.svf

########################analyze_elaborate###############################

analyze -library work -format verilog ../rtl/${design}.v
elaborate $design -lib work
current_design $design 
check_design

#####################################cons##############################

###

############################compile#####################################

set_fix_multiple_port_nets -all -buffer_constants
set compile_prefer_mux true
set hdlin_infer_mux all
compile -incremental_mapping -map_effort high
compile -incremental_mapping -map_effort high

#############################handel#######################################

sh rm -rf ../results/worst
sh mkdir -p ../results/worst
sh mkdir -p ../results/worst/reports
sh mkdir -p ../results/worst/outputs

########################reports############################################

report_clocks                                                   > ../results/worst/reports/clocks.rpt
report_area                                                     > ../results/worst/reports/area.rpt
report_power                                                    > ../results/worst/reports/power.rpt
report_qor                                                      > ../results/worst/reports/syn_qor.rpt
report_timing -delay_type max  -max_paths 2                     > ../results/worst/reports/setup.rpt
report_timing -delay_type min  -max_paths 2                     > ../results/worst/reports/hold.rpt
report_timing -delay_type max -slack_lesser_than 0 -max_paths 2 > ../results/worst/reports/setup_violated.rpt
report_constraint                                               > ../results/worst/reports/constraints.rpt
report_constraint -all_violators                                > ../results/worst/reports/constraints_violated.rpt

####################################outputs###########################################

set verilog_no_tri true
set verilog_equation false
change_names -rules verilog -hierarchy

write -f ddc -hierarchy -output ../results/worst/outputs/${design}.ddc
write -hierarchy -format verilog -output ../results/worst/outputs/${design}.v
write_sdf ../results/worst/outputs/${design}.sdf
write_sdc ../results/worst/outputs/${design}.sdc

set_svf -off
