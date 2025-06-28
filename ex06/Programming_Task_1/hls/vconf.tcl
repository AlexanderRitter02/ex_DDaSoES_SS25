cd hls
open_project -reset vitis_hls
set_top crypt_message
add_files ../cbc.cpp
open_solution "solution1" -flow_target vivado
set_part {xc7vx485tffg1761-2}
create_clock -period 50ns
csynth_design
export_design -format ip_catalog -display_name "d37fa0eb34ee6115b71f12b7fe0b461f"
if {[file exist  vitis_hls/solution1/syn]} {
  file copy -force vitis_hls/solution1/syn ./
}
