module cbc # (
  parameter n = 1,
  parameter m = 3
) (
  input logic  [n*m*8-1:0] message,
  input logic  [n*8-1:0] key,
  output logic [n*m*8-1:0] out
);

// First message chunk uses key and only generate if message is not of 0 length
if (m != 0) begin
  xor_chunk # (
    .n(n)
  ) chunk_first (
    .chunk(message[n*8-1:0]),
    .key(key),
    .out(out[n*8-1:0])
  );
end


// Generate remaining chunks
for (genvar chunk = 1; chunk < m; chunk++) begin: gen_chunk_xors

  xor_chunk # (
    .n(n)
  ) chunk_after (
    .chunk(message[(chunk+1)*n*8-1:chunk*n*8]),
    .key(out[(chunk)*n*8-1:(chunk-1)*n*8]),  // Output of previous chunk is key for the next chunk
    .out(out[(chunk+1)*n*8-1:chunk*n*8])
  );

end


endmodule

