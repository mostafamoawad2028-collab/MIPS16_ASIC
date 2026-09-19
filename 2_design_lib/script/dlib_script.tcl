############################setup###########################

set project_dir "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16"
set lib_path "/home/ICer/Downloads/Lib"
set design "mips_16"
set target_library "saed90nm_max_hvt.db"
set_app_var search_path "/home/ICer/Downloads/Lib"
set_app_var link_library "* $target_library"

##########################handel###############################

sh rm -rf   ../results/worst
sh mkdir -p ../results/worst
sh mkdir -p ../results/worst/reports
sh mkdir -p ../results/worst/outputs

############################create_dlib########################

set tech_file $lib_path/process/astro/tech/astroTechFile.tf
set reference_library "/mnt/hgfs/VM_shared/ITI/ASIC_mips_16/pnr/1_ndm/ndm/saed90nm_max_hvt.ndm"

create_lib -technology $tech_file -ref_libs $reference_library ../results/worst/outputs/${design}.dlib

#####################################################################################3

read_verilog -top $design ${project_dir}/syn/results/worst/outputs/${design}.v
link_block

#########################################parasitics###################################

set tech "/home/ICer/Downloads/Lib/Technology_Kit/starrcxt"
read_parasitic_tech -layermap $tech/tech2itf.map                  \
-tlup $tech/tluplus/saed90nm_1p9m_1t_Cmax.tluplus -name tluplus_max

#read_parasitic_tech -layermap $tech/tech2itf.map                  \
#-tlup $tech/tluplus/saed90nm_1p9m_1t_Cmin.tluplus -name tluplus_min

#set_parasitic_parameters -early_spec tluplus_min -late_spec tluplus_max \
#-early_temperature 125 -late_temperature 125


#delete after if use berofe#

set_parasitic_parameters -early_spec tluplus_max -late_spec tluplus_max \
-early_temperature 125 -late_temperature 125

###########################################################################################

read_sdc ${project_dir}/syn/results/worst/outputs/${design}.sdc

##########################################reports############################################3

report_corners                            > ../results/worst/reports/corners.rpt
report_pvt                                > ../results/worst/reports/pvt.rpt

########################################save########################################################

save_block -as ${design}_dlib ${design}.dlib:${design}.design 

start_gui
