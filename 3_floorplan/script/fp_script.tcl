#########################setup#########################

set project_dir "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16"
set lib_path "/home/ICer/Downloads/Lib"
set dlib_dir "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16/pnr/2_design_lib/results/worst/outputs"
set design "mips_16"

set prev_stage "dlib"
set current_stage "floorplan"

########################open########################

open_block ${dlib_dir}/${design}.dlib:${design}_${prev_stage}.design
copy_block -from_block ${design}.dlib:${design}_${prev_stage}.design -to_block ${design}_${current_stage}.design
current_block ${design}_${current_stage}.design
start_gui

###########################floorplan########################

set_attribute [get_layers {M1 M3 M5 M7 M9}] routing_direction horizontal
set_attribute [get_layers {M2 M4 M6 M8}] routing_direction vertical

set name_unit [get_site_defs]

set_attribute $name_unit is_default true 
set_attribute $name_unit symmetry {Y} 

initialize_floorplan -control_type  core\
                     -core_utilization 0.6 \
                     -shape R \
                     -core_offset {10} \
                     -flip_first_row true \
                     -side_ratio {1 1}



          
create_net -power VDD
create_net -ground VSS
           
connect_pg_net -net VDD [get_pins -hierarchical */VDD]
connect_pg_net -net VSS [get_pins -hierarchical */VSS]

set_block_pin_constraints -self -allowed_layers {M3 M4}
place_pins -self -ports [get_ports *]

########################handel################################3

sh rm -rf ../results/worst
sh mkdir -p ../results/worst
sh mkdir -p ../results/worst/reports
sh mkdir -p ../results/worst/outputs

############################create_dlib########################

report_qor              > ../results/worst/reports/qor.rpt
report_utilization      > ../results/worst/reports/utilization.rpt

##################save##########################

save_block -as ${design}_${current_stage} ${design}.dlib:${design}_${current_stage}.design


#open_block ${dlib_dir}/${design}.dlib:${design}_${current_stage}.design
