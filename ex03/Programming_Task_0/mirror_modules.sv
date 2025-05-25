// TEST-1: Module implements "{OR(AND(NOT(A), B)), OR(AND(A, B, C), AND(NOT(A), B))}"
module test1_mirror_func(
  input logic [2:0] in,
  output logic [1:0] out
);

  assign out[1] = ~in[0] & in[1];
  assign out[0] = (in[0] & in[1] & in[2]) | (~in[0] & in[1]);

endmodule


// TEST-2: Module for NOT A and NOT B
module test2_mirror_func(
  input logic [1:0] in,
  output logic out
);

  assign out = ~in[0] & ~in[1];

endmodule

// TEST-3: TODO
module test3_mirror_func(
  input logic [1:0] in,
  output logic out
);

  assign out = ~in[0] & ~in[1];

endmodule

