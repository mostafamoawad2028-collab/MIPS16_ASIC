##########################setup#########################

set project_dir "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16"
set lib_path "/home/ICer/Downloads/Lib"
set dlib_dir "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16/pnr/2_design_lib/results/worst/outputs"
set design "mips_16"

set prev_stage    "cts"
set current_stage "route"

########################open########################

open_block ${dlib_dir}/${design}.dlib:${design}_${prev_stage}.design
copy_block -from_block ${design}.dlib:${design}_${prev_stage}.design -to_block ${design}_${current_stage}.design
current_block ${design}_${current_stage}.design
start_gui

###########################ROUTING#################################

set_host_option -max_cores 4

###############pre-routing#################

check_routability 
#check_design -checks pre_route_stage

set_ignored_layers -max M9 -min M2


set_app_options -name route.detail.eco_max_number_of_iterations -value 10
set_app_options -name opt.common.user_instance_name_prefix -value "ROUTE_"

######################optimization############

route_opt

check_routes
check_lvs -max_errors 0
check_pg_drc

sizeof_collection [get_cells "*ROUTE_*"]
sizeof_collection [get_cells -hierarchical  "*ROUTE_*"]


connect_pg_net -net "VDD" [get_pins -hierarchical */VDD]
connect_pg_net -net "VSS" [get_pins -hierarchical */VSS]

##########################################################################
##############################prime_time####################################
###########################################################################


###############################filar and dcap###########################

set dcap_filers [get_lib_cells */*DCAP*]

create_stdcell_fillers  -lib_cell [get_lib_cells */*DCAP*] \
                        -utilization 30 \
                        -prefix "DECAP_" \
                        -post_eco

sizeof_collection [get_cells -hierarchical  "*DECAP_*"]


connect_pg_net -net "VDD" [get_pins -hierarchical */VDD]
connect_pg_net -net "VSS" [get_pins -hierarchical */VSS]

connect_pg_net -automatic

check_routes

remove_stdcell_fillers_with_violation

check_routes


set std_filers [get_lib_cells */*SHFILL*]
set_attribute  [get_lib_cells */*SHFILL*] dont_touch false
set_attribute  [get_lib_cells */*SHFILL*] dont_use false

set std_filers_128 "saed90nm_max_hvt/SHFILL128_HVT"
set std_filers_64 "saed90nm_max_hvt/SHFILL64_HVT"
set std_filers_3 "saed90nm_max_hvt/SHFILL3_HVT"
set std_filers_2 "saed90nm_max_hvt/SHFILL2_HVT"
set std_filers_1 "saed90nm_max_hvt/SHFILL1_HVT"

set_attribute [get_lib_cells */*SHFILL*] is_filler true

create_stdcell_fillers  -lib_cell $std_filers_128 \
                        -prefix "FILLER128_" \
                        -post_eco \
                        -continue_on_error


create_stdcell_fillers  -lib_cell $std_filers_64 \
                        -prefix "FILLER64_" \
                        -post_eco \
                        -continue_on_error


create_stdcell_fillers  -lib_cell $std_filers_3 \
                        -prefix "FILLER3_" \
                        -post_eco \
                        -continue_on_error


create_stdcell_fillers  -lib_cell $std_filers_2 \
                        -prefix "FILLER2_" \
                        -post_eco \
                        -continue_on_error \
                        -rules no_1x -utilization 100

create_stdcell_fillers  -lib_cell $std_filers_1 \
                        -prefix "FILLER1_" \
                        -post_eco \
                        -continue_on_error \
                        -rules no_1x -utilization 100

check_routes


route_eco
check_routes


connect_pg_net -net "VDD" [get_pins -hierarchical */VDD]
connect_pg_net -net "VSS" [get_pins -hierarchical */VSS]


remove_stdcell_fillers_with_violations




change_selection [get_cells  "*FILLER*"]

sizeof_collection [get_cells -hierarchical  "*FILLER*"]

check_lvs -max_errors 0
check_pg_drc
check_legality


########################handel################################

sh rm -rf ../results/worst
sh mkdir -p ../results/worst
sh mkdir -p ../results/worst/reports
sh mkdir -p ../results/worst/outputs

###############################reports#####################

report_timing -delay_type max  -max_paths 10                    > ../results/worst/reports/setup.rpt
report_timing -delay_type min  -max_paths 10                    > ../results/worst/reports/hold.rpt
report_constraints -all_violators                                > ../results/worst/reports/constraints_violated.rpt
report_qor                                                      > ../results/worst/reports/syn_qor.rpt



write_def                        ../results/worst/outputs/${design}_${current_stage}.def
write_verilog     -include {all} ../results/worst/outputs/${design}_${current_stage}.v
write_sdc         -output     ../results/worst/outputs/${design}_${current_stage}.sdc


##################save####################################

save_block -as ${design}_${current_stage} ${design}.dlib:${design}_${current_stage}.design

#open_block ${dlib_dir}/${design}.dlib:${design}_${current_stage}.design

