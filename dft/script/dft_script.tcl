#############################set_libs##############################

set_app_var search_path "/home/ICer/Downloads/Lib/synopsys/models"
set_app_var target_library "saed90nm_max_hvt.db"
set_app_var link_library "* $target_library"

##############################handel###################################

sh rm -rf work
sh mkdir -p work
define_design_lib work -path ./work

##############################reuse_fm#########################################

set design mips_16
set_svf ${design}.svf

########################read_ddc_and_sdc_sff###############################

read_ddc ../../syn/results/worst/outputs/${design}.ddc
current_design $design
read_sdc ../../syn/results/worst/outputs/${design}.sdc
current_design $design

set_fix_multiple_port_nets -all -buffer_constants
set_dp_smartgen_options -optimize_for speed
set_critical_range 1 $design
compile -map_effort high -scan 

#####################################cons##############################
###
############################start##########################

create_test_protocol
dft_drc -coverage_estimate
preview_dft
insert_dft

compile -map_effort high -scan -incremental_mapping
dft_drc -coverage_estimate 

############################setup#######################################

sh rm -rf   ../results/worst
sh mkdir -p ../results/worst
sh mkdir -p ../results/worst/reports
sh mkdir -p ../results/worst/outputs

########################reports############################################
report_clocks                                                   > ../results/worst/reports/dft_clocks.rpt
report_area                                                     > ../results/worst/reports/dft_area.rpt
report_power                                                    > ../results/worst/reports/dft_power.rpt
report_net_fanout -threshold 50                                 > ../results/worst/reports/dft_rhigh_fanout.rpt
report_timing -delay_type max  -max_paths 3                     > ../results/worst/reports/dft_setup.rpt
report_timing -delay_type min  -max_paths 3                     > ../results/worst/reports/dft_hold.rpt
report_timing -delay_type max -slack_lesser_than 0              > ../results/worst/reports/dft_setup_violated.rpt
report_timing -delay_type min -slack_lesser_than 0              > ../results/worst/reports/dft_hold_violated.rpt
dft_drc -verbose                                                > ../results/worst/reports/drc.rpt
dft_drc -coverage_estimate                                      > ../results/worst/reports/drc_coverage_estimate.rpt
report_qor                                                      > ../results/worst/reports/dft_qor.rpt
report_constraint -all_violators                                > ../results/worst/reports/dft_constraints_violated.rpt
report_scan_path -chain all                                     > ../results/worst/reports/scan_chains.rpt
report_dft_signal -view  existing_dft                           > ../results/worst/reports/dft_existing.rpt
report_dft_signal -view  spec                                   > ../results/worst/reports/dft_spec.rpt
report_test_mode                                                > ../results/worst/reports/test_mode.rpt

####################################outputs###########################################

set verilog_no_tri true
set verilog_equation false
change_names -rule verilog

write -format ddc -hierarchy -output ../results/worst/outputs/${design}.ddc
write -format verilog -hierarchy -output ../results/worst/outputs/${design}.v
write_sdf ../results/worst/outputs/${design}.sdf
write_sdc ../results/worst/outputs/${design}.sdc
write_test_model -output ../results/worst/outputs/${design}.ctl
write_test_protocol -out ../results/worst/outputs/${design}.spf
write_scan_def -output ../results/worst/outputs/${design}.def

set_svf -off
