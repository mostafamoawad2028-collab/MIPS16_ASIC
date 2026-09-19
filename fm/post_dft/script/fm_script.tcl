##########################setup#########################

lappend search_path "/home/ICer/Downloads/Lib/synopsys/models"
lappend search_path "/mnt/hgfs/VM_shared/ITI/mips_16/syn/results/worst/outputs"

#########################setup##########################

set top_module mips_16
set synopsys_auto_setup true
set_svf "/mnt/hgfs/VM_shared/ITI/mips_16/dft/run/${top_module}.svf"

################################ref############################################

set SSLIB_HVT "saed90nm_max_hvt.db"
read_db -container ref [list $SSLIB_HVT]


rerefverilog -container ref -netlist "/mnt/hgfs/VM_shared/ITI/mips_16/syn/results/worst/outputs/${top_module}.v"


set_reference_design mips_16
set_top mips_16

################################imp##################

read_db -container imp [list $SSLIB_HVT]
read_verilog -container imp -netlist "/mnt/hgfs/VM_shared/ITI/mips_16/dft/results/worst/outputs/${top_module}.v"

set_implementation_design mips_16
set_top mips_16

###############################test#########################

set_constant ref:/WORK/*/test_mode 1
set_constant imp:/WORK/*/test_mode 1

match

set succ [verify]
if {!$succ} {
diagnose
analyze_points -failing
} else {
puts " successful "
}

report_passing_points > ../reports/p_p.rpt
report_failing_points > ../reports/f_p.rpt
report_aborted_points > ../reports/a_p.rpt
report_unverified_points > ../reports/un_p.rpt

###########################################################

start_gui

