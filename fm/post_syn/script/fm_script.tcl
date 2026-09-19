##########################setup#########################

lappend search_path "/home/ICer/Downloads/Lib/synopsys/models"
lappend search_path "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16/syn/rtl"

#########################setup##########################

set top_module mips_16
set synopsys_auto_setup true
set_svf "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16/syn/run/${top_module}.svf"

################################ref############################################

set SSLIB_HVT "saed90nm_max_hvt.db"
read_db -container ref [list $SSLIB_HVT]
read_verilog -container ref "alu.v"
read_verilog -container ref "ALUControl.v"
read_verilog -container ref "control.v"
read_verilog -container ref "data_memory.v"
read_verilog -container ref "instr_mem.v"
read_verilog -container ref "JR_Control.v"
read_verilog -container ref "Mux2x1.v"
read_verilog -container ref "register_file.v"
read_verilog -container ref "mips_16.v"

set_reference_design mips_16
set_top mips_16

################################imp##################

read_db -container imp [list $SSLIB_HVT]
read_verilog -container imp -netlist "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16/syn/results/worst/outputs/${top_module}.v"

set_implementation_design mips_16
set_top mips_16

###############################test#########################

set_constant ref:/WORK/*/test_mode 0
set_constant imp:/WORK/*/test_mode 0

match

set succ [verify]
if {!$succ} {
diagnose
analyze_points -failing
} else {
puts " successful "
}

#############################handel#######################################

sh rm -rf ../results/worst
sh mkdir -p ../results/worst
sh mkdir -p ../results/worst/reports
sh mkdir -p ../results/worst/outputs

##############################REPORTS##############################

report_passing_points    > ../results/worst/reports/passing_points.rpt
report_failing_points    > ../results/worst/reports/failing_points.rpt
report_aborted_points    > ../results/worst/reports/aborted_points.rpt
report_unverified_points > ../results/worst/reports/unverified_points.rpt
 
###########################################################

start_gui

