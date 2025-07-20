set clks_def [list  clk_i 500]
foreach {clk period} ${clks_def}  {
  if {[get_port -quiet ${clk}] != ""} {
    set_units -time 1ns -capacitance 1fF
    create_clock -name ${clk} -period ${period} [get_port ${clk}]
    set_input_delay -clock ${clk} -max 2 [remove_from_collection [all_inputs] ${clk}]
    set_input_delay -clock ${clk} -min 1 [remove_from_collection [all_inputs] ${clk}]
    set_output_delay -clock ${clk} -max 2 [remove_from_collection [all_outputs] ${clk}]
    set_output_delay -clock ${clk} -min -1 [remove_from_collection [all_outputs] ${clk}]
    if {"" != "" && [get_port -quiet ] != ""} {
      set_false_path -from [get_port ]
    } else {
      info "Design might require reset port"
    }
  }
}
if {[llength ${clks_def}] > 2} {
  set_clock_groups  -group {clk_i}
}
