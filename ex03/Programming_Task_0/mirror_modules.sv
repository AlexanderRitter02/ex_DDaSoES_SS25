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

// TEST-3
// OR(AND(A, B, C)), OR(AND(NOT(A), NOT(B), NOT(C))), OR(AND(NOT(A), B, C)), OR(AND(A, NOT(B), C)),
//  OR(AND(NOT(A), NOT(B), C)), OR(AND(A, B, NOT(C))), OR(AND(NOT(A), B, NOT(C))), OR(AND(A, NOT(B), NOT(C)))}

module test3_mirror_func(
  input logic [2:0] in, // 3 inputs
  output logic [7:0] out // 8 outs
);

  wire A = in[0];
  wire B = in[1];
  wire C = in[2];

  assign out[7] = A && B && C;
  assign out[6] = ~A && ~B && ~C;
  assign out[5] = ~A && B && C; // OR(AND(NOT(A), B, C))
  assign out[4] = A && ~B && C; // OR(AND(A, NOT(B), C))
  assign out[3] = ~A && ~B && C; // OR(AND(NOT(A), NOT(B), C))
  assign out[2] = A && B && ~C; // OR(AND(A, B, NOT(C)))
  assign out[1] = ~A && B && ~C; // OR(AND(NOT(A), B, NOT(C)))
  assign out[0] = A && ~B && ~C; // OR(AND(A, NOT(B), NOT(C)))


endmodule

