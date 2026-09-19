#########################setup#########################

set project_dir "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16"
set lib_path "/home/ICer/Downloads/Lib"
set dlib_dir "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16/pnr/2_design_lib/results/worst/outputs"
set design "mips_16"

set prev_stage    "floorplan"
set current_stage "powerplan"

########################open########################

open_block ${dlib_dir}/${design}.dlib:${design}_${prev_stage}.design
copy_block -from_block ${design}.dlib:${design}_${prev_stage}.design -to_block ${design}_${current_stage}.design
current_block ${design}_${current_stage}.design
start_gui

#############################initialize########################

remove_pg_via_master_rules     -all
remove_pg_patterns             -all
remove_pg_strategies           -all
remove_pg_strategy             -all

##########################powerplan########################

set roffset 1
set rhorz_layer M9
set rvert_layer M8
set rhorz_width 3
set rvert_width 3
set rhorz_spacing 4
set rvert_spacing 4
set rstrategy_name "core_ring"

#########################ring########################

create_pg_region power_ring_region -core -expand_by_edge \
                                  " {{side : 1} {offset : ${roffset}}}
                                    {{side : 2} {offset : ${roffset}}} 
                                    {{side : 3} {offset : ${roffset}}} 
                                    {{side : 4} {offset : ${roffset}}}"

#"

create_pg_ring_pattern ring_pattern -horizontal_layer ${rhorz_layer} -vertical_layer ${rvert_layer}\
                                    -horizontal_width ${rhorz_width} -vertical_width ${rvert_width} \
                                    -horizontal_spacing ${rhorz_spacing} -vertical_spacing ${rvert_spacing}

set_pg_strategy ${rstrategy_name} \
    -pg_regions {power_ring_region} \
    -pattern {{name : ring_pattern} {nets : {VDD VSS}}}

compile_pg -strategies ${rstrategy_name}

#######################################missing_vias####################################

create_pg_mesh_pattern straps_vddvss -layers {
{{horizontal_layer : M9}{width : 3}{pitch : 20}{spacing : interleaving}{offset : 1}}
{{vertical_layer : M8}{width : 3}{pitch : 20}{spacing : interleaving}{offset : 1}}}


set_pg_strategy mesh_vddvss -core \
                                -pattern {{name : straps_vddvss}{nets : {VDD VSS}}} \
                                -extension {{stop:design_boundary_and_generate_pin}}

compile_pg -strategies mesh_vddvss

###############################rail####################################


connect_pg_net -net VDD [get_pins -hierarchical */VDD]
connect_pg_net -net VSS [get_pins -hierarchical */VSS]

set rail_startegie rails_M1
set rail_pattern   std_cell_rail
set rail_layer     M1
set rail_width     0.16

create_pg_std_cell_conn_pattern $rail_pattern -layers $rail_layer \
                                  -rail_width $rail_width

set_pg_strategy $rail_startegie -core   -pattern {{name : std_cell_rail}{nets : {VDD VSS}}} 


compile_pg  -strategies $rail_startegie


############################CHECK####################################


check_pg_drc
check_pg_connectivity
check_pg_missing_vias

########################handel################################3

sh rm -rf ../results/worst
sh mkdir -p ../results/worst
sh mkdir -p ../results/worst/reports
sh mkdir -p ../results/worst/outputs

############################create_dlib########################

check_pg_drc            > ../results/worst/reports/drc.rpt
check_pg_connectivity   > ../results/worst/reports/connectivity.rpt
check_pg_missing_vias   > ../results/worst/reports/missing_vias.rpt


##################save##########################

write_def                        ../results/worst/outputs/${design}_${current_stage}.def
write_verilog     -include {all} ../results/worst/outputs/${design}_${current_stage}.v

save_block -as ${design}_${current_stage} ${design}.dlib:${design}_${current_stage}.design


#open_block ${dlib_dir}/${design}.dlib:${design}_${current_stage}.design
