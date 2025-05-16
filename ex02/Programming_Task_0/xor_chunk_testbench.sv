module xor_chunk_test;

logic [7:0] key_8bit;
logic [7:0] chunk_8bit;
logic [7:0] output_8bit;

logic [15:0] key_16bit;
logic [15:0] chunk_16bit;
logic [15:0] output_16bit;

xor_chunk # (
  .n(1)
) encrypter (
  .chunk(chunk_8bit),
  .key(key_8bit),
  .out(output_8bit)
);

xor_chunk # (
  .n(2)
) encrypter16 (
  .chunk(chunk_16bit),
  .key(key_16bit),
  .out(output_16bit)
);

initial begin
  $display("Testing of XOR chunk encryption/decryption");

  $display("8bit key");
  // Test on example
  key_8bit   = 'b11100111;
  chunk_8bit = 'b00010111;
  #10;
  encrypt_8bit_test: assert (output_8bit == 'b11110000);

  // A just zero key does not do anything to the message
  key_8bit   = 'b00000000;
  chunk_8bit = 'b10110110;
  #10;
  encrypt_8bit_key0: assert (output_8bit == 'b10110110);

  // A just 1 key inverts the message
  key_8bit   = 'b11111111;
  chunk_8bit = 'b10110110;
  #10;
  encrypt_8bit_key1: assert (output_8bit == 'b01001001);

  // Inverse key and message get just ones out
  key_8bit   = 'b10101010;
  chunk_8bit = 'b01010101;
  #10;
  encrypt_8bit_inverses: assert (output_8bit == 'b11111111);

  // Parameters work (n=2)
  $display("16bit key");
  key_16bit   = 'b1010101010101010;
  chunk_16bit = 'b1001111111111101;
  #10;
  encrypt_16bit: assert (output_16bit == 'b0011010101010111);

  // Same key and message cancel out to zero
  key_16bit   = 'b1001101100111101;
  chunk_16bit = 'b1001101100111101;
  #10;
  encrypt_16bit_same: assert (output_16bit == 'b0000000000000000);


 
end

endmodule
