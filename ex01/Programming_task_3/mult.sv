`include "and.sv"
`include "fulladder.sv"

module mult(
  input  logic a0, a1, a2, b0, b1, b2
  output logic s0, s1, s2, s3, s4, s5
)

// Partial products for 1st bit of B
// ppBA (bit B from B, bit A from A)
and pp_00 (b0, a0)
and pp_01 (b0, a1)
and pp_02 (b0, a2)

// Partial products for 2nd bit of B
and pp_10 (b1, a0)
and pp_11 (b1, a1)
and pp_12 (b1, a2)

// Partial products for 3rd bit of B
and pp_20 (b2, a0)
and pp_21 (b2, a1)
and pp_22 (b2, a2)

buf(s0, a0) // buf(out, in) just propagates the same value

// Summations: Row 1
// Full-Adder names: fXY (X=row, Y=number of the adder from left)
fulladder f11 (
  .a(pp_01),
  .b(pp_10),
  .c_in(0),
  .s(s1),
  .c_out(carry_for_f12)
);

fulladder f12 (
  .a(pp_02),
  .b(pp_11),
  .c_in(carry_for_f12),
  .s(sum_for_f21),
  .c_out(carry_for_f13)
);

fulladder f13 (
  .a(pp_12),
  .b(0),
  .c_in(0),
  .s(sum_for_f22),
  .c_out(b_for_f23)
);

// Row 2
fulladder f21 (
  .a(pp_20),
  .b(sum_for_f21),
  .c_in(0),
  .s(s2),
  .c_out(carry_for_f22)
);

fulladder f22 (
  .a(pp_21),
  .b(sum_for_f22),
  .c_in(carry_for_f22),
  .s(sum_for_f31),
  .c_out(carry_for_f23)
);

fulladder f23 (
  .a(pp_22),
  .b(b_for_f23),
  .c_in(carry_for_f23),
  .s(sum_for_f32),
  .c_out(b_for_f33)
);

// Row 3
fulladder f31 (
  .a(pp_30),
  .b(sum_for_f31),
  .c_in(0),
  .s(s3),
  .c_out(carry_for_f32)
);

fulladder f32 (
  .a(pp_31),
  .b(sum_for_f32),
  .c_in(carry_for_f32),
  .s(s4),
  .c_out(carry_for_f33)
);

fulladder f33 (
  .a(pp_32),
  .b(b_for_f33),
  .c_in(carry_for_f33),
  .s(s5),
  .c_out(s6)
);

endmodule
