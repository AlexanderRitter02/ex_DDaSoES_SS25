database -open vcddb -into post_synthesized_with_cdc.vcd -vcd -default
if {"i_dut" != ""} {
  tcheck tb_cdc.i_dut -on -type setup -depth all
  tcheck tb_cdc.i_dut -on -type hold -depth all
}
probe -create -vcd -all -depth all -database vcddb
set pack_assert_off {std_logic_arith numeric_std}
run
exit
