module xor_chunk_test;

logic [8:0] key_8bit;
logic [8:0] chunk_8bit;
logic [8:0] output_8bit;


xor_chunk # (
  .N(1)
) encrypter (
  .chunk(chunk_8bit),
  .key(key_8bit),
  .out(output_8bit)
);	

initial begin
  key_8bit = 3'b111;
  chunk_8bit = 3'b011;
  #10;
  encrypt_8bit: assert (output_8bit == 'b110);
end


endmodule
