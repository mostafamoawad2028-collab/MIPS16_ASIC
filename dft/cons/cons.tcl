#################################configration############################

set_scan_configuration -style multiplexed_flip_flop \
                       -replace true \
                       -clock_mixing no_mix \
                       -chain_count 1

####################################new_ports##########################################

create_port -direction in Scan_Data_In 
create_port -direction in Scan_En
create_port -direction out Scan_Data_Out

#set_ideal_network [get_ports Scan_En]

###################################others#################################################

set_case_analysis 1 [get_port test_mode]

###################################set_dft############################################

set_dft_signal -port [get_ports scan_clk]      -type ScanClock   -view existing_dft -timing {45 55}
set_dft_signal -port [get_ports scan_reset]    -type Reset       -view existing_dft -active 1
set_dft_signal -port [get_ports test_mode]     -type Constant    -view existing_dft -active 1
set_dft_signal -port [get_ports test_mode]     -type TestMode    -view spec         -active 1
set_dft_signal -port [get_ports Scan_Data_In]  -type ScanDataIn  -view spec 
set_dft_signal -port [get_ports Scan_En]       -type ScanEnable  -view spec         -active 1 -usage scan
set_dft_signal -port [get_ports Scan_Data_Out] -type ScanDataOut -view spec   
