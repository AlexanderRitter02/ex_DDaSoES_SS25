database -open vcddb -into post_clocked_adder.vcd -vcd -default
if {"i_dut" != ""} {
  tcheck tb_adder.i_dut -on -type setup -depth all
  tcheck tb_adder.i_dut -on -type hold -depth all
}
probe -create -vcd -all -depth all -database vcddb
set pack_assert_off {std_logic_arith numeric_std}
