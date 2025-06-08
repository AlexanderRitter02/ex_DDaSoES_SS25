set_db source_verbose false
read_libs /nfs/wsi/es/eda/Nangate/stdc/si2/instances/latest/liberty/CCS/NangateOpenCellLibrary_typical_ccs.lib
foreach f {display_package.sv status_module.sv moving_average.sv pipeline.sv cdc.sv} {
  if { [string match *.vhd ${f}] } {
    read_hdl -language vhdl ${f} -define USE_CDC=1
  } elseif { [string match *.v ${f}] } {
    read_hdl -language v2001 ${f} -define USE_CDC=1
  } elseif { [string match *.svh ${f}] } {
    read_hdl -language sv ${f} -define USE_CDC=1
  } elseif { [string match *.sv ${f}] } {
    read_hdl -language sv ${f} -define USE_CDC=1
  }
}
set_dont_use "HA*" true
set_dont_use "FA*" true
elaborate pipeline
read_sdc ./synthesis/constraints.sdc
syn_generic
syn_map
syn_opt
report_power  > ./synthesis/report_power.rpt
report_gates  > ./synthesis/report_gate.rpt
report_area   > ./synthesis/report_area.rpt
foreach {clk} [list clock_slow clock_fast]  {
  report_timing -group ${clk} > ./synthesis/report_timing_${clk}.rpt
}
report_timing -unconstrained > ./synthesis/report_utiming.rpt
write_hdl pipeline > ./synthesis/syn_pipeline.v
exit
