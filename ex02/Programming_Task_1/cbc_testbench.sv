module cbc_testbench;

logic enc_dec_8bit;
logic [7:0] key_8bit;
logic [7:0] message_len1_8bit;
logic [7:0] output_cbc_8bit;
logic [7:0] output_xor_8bit;

logic enc_dec_len2;
logic [15:0] message_len2;
logic [15:0] output_len2;

logic enc_dec_complex;
logic [63:0] key_16bit;
logic [63:0] message_len4;
logic [63:0] output_len4;

cbc # (
  .n(1),
  .m(1)
) encrypter_1chunk_8bit (
  .enc_dec(enc_dec_8bit),
  .message(message_len1_8bit),
  .key(key_8bit),
  .out(output_cbc_8bit)
);
xor_chunk # (
  .n(1)
) xor_8bit (
  .chunk(message_len1_8bit),
  .key(key_8bit),
  .out(output_xor_8bit)
);

cbc # (
  .n(1),
  .m(2)
) encrypter_2chunk_8bit (
  .enc_dec(enc_dec_len2),
  .message(message_len2),
  .key(key_8bit),
  .out(output_len2)
);

cbc # (
  .n(2),
  .m(4)
) encrypter_5chunk_16bit (
  .enc_dec(enc_dec_complex),
  .message(message_len4),
  .key(key_16bit),
  .out(output_len4)
);

// m=1 should behave exactly like the XOR chunk
//message_len1_equals_xor_chunk: assert property ( @(posedge clk) (output_cbc_8bit == output_xor_8bit));


initial begin

  enc_dec_8bit = 'b0;
  key_8bit          = 'b11100111;
  message_len1_8bit = 'b00010111;
  #1;
  same1: assert (output_cbc_8bit == output_xor_8bit);

  key_8bit          = 'b11100111;
  message_len1_8bit = 'b11111111;
  #1;
  same2: assert (output_cbc_8bit == output_xor_8bit);


  // ######## TESTS-2: Encryption of m=2, n=1 ########
  enc_dec_len2 = 'b0;

  // Test case 2.1: A zero message just replicates the key in the output
  message_len2 = 'b0000000000000000;
  key_8bit     = 'b11100111;
  #1;
  message_zero_copies_key: assert(output_len2 == 'b1110011111100111);

  // Test case 2.2: An explicit manual example with a random key and random message
  message_len2 = 'b1001101001110011;
  key_8bit     =         'b01011001;
  // First chunk:          00101010; 
  //               10011010
  //               00101010
  // Second chunk: 10110000
  #1;
  random_manual_encryption_chunk1: assert(output_len2[7:0] ==  'b00101010);
  random_manual_encryption_chunk2: assert(output_len2[15:8] == 'b10110000);
  random_manual_encryption: assert(output_len2 == 'b1011000000101010);

  // ######## TEST-3: More complex encryption module with 5 message length (m=5) and 16-bit chunks (n=2) ########
  enc_dec_complex = 'b0;
  key_16bit    = 'h0AFB;
  message_len4 = 'h8BCDA2591123FF54;

  // Manual test result using https://xor.pw/
  // chunk1: FF54 ^ FF54 = F5AF
  // chunk2: F5AF ^ 1123 = E48C
  // chunk3: E48C ^ A259 = 46D5
  // chunk4: 46D5 ^ 8BCD = CD18
  #1;
  complex_encryption_1: assert(output_len4 ==  'hCD1846D5E48CF5AF);

  key_16bit    = 'h1234;
  message_len4 = 'h0123456789ABCDEF;
  
  // chunk1: DFDB
  // chunk2: 5670
  // chunk3: 1317
  // chunk4: 1234
  #1;
  $display("0x%h", output_len4);
  complex_encryption_2: assert(output_len4 ==  'h123413175670DFDB);

  // ######## TESTS-4: Decryption for m=2, n=1 ########
  enc_dec_len2 = 'b1;
  enc_dec_complex = 'b1;

  // Test cases: Decryption test of the previous test cases
  message_len2 = 'b1110011111100111;
  key_8bit     =         'b11100111;
  #1;
  decryption_1: assert(output_len2 == 'b0000000000000000);

  message_len2 = 'b1011000000101010;
  key_8bit     =         'b01011001;
  #1;
  decryption_2: assert(output_len2 == 'b1001101001110011);

  message_len4 = 'hCD1846D5E48CF5AF;
  key_16bit    = 'h0AFB;
  #1
  decryption_complex_1: assert(output_len4 == 'h8BCDA2591123FF54);

  message_len4 = 'h123413175670DFDB;
  key_16bit    = 'h1234;
  #1
  decryption_complex_2: assert(output_len4 == 'h0123456789ABCDEF);

  
  
  
  

end


endmodule