`include "halfadder.sv"

module fulladder(
  input logic a, b, c_in,
  output logic s, c_out
);

wire sum1, carry1, carry2;

halfadder first ( a, b, sum1, carry1);
halfadder second(sum1, c_in, s, carry2);

or carryOr(c_out, carry1, carry2);

endmodule