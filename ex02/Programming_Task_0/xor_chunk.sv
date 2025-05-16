module xor_chunk # (
  parameter n = 1
) (
  input logic  [n*8-1:0] chunk,
  input logic  [n*8-1:0] key,
  output logic [n*8-1:0] out
);

  assign out = chunk ^ key;

endmodule

