module cbc_testbench;

// m = 4, n = 2
logic encrypt_decrypt;
logic [15:0] key;
logic [63:0] message;
logic [63:0] result;
logic [63:0] result_exercise2;

logic clock = 'b0;
logic reset = 'b0;
logic start = 'b0;

// Other outputs
logic done;
logic idle;
logic ready;

// CBC from exercise 2
cbc # (
  .n(2),
  .m(4)
) crypter_exercise2 (
  .enc_dec(encrypt_decrypt),
  .message(message),
  .key(key),
  .out(result_exercise2)
);


// HLS unroll CBC
crypt_message cbc (
        .ap_start(start),
        .ap_done(done),
        .ap_idle(idle),
        .ap_ready(ready),
        .encrypt_decrypt(encrypt_decrypt),
        .message(message),
        .key(key),
        .ap_return(result)
);


// We still keep a clock for property checking even though not needed
always #(55ns) clock = ~clock;

// Check whether on all positive clock edges the outputs are the same
property mirror_check;
  disable iff (reset)
  @(posedge clock) result === result_exercise2;
endproperty

assert property (mirror_check);	


// Here we first have a few manual test cases
// and afterwards simulate 50 random encryptions and 50 decryptions
// We rely on the property to check whether the our outputs are the same as the CBC from exercise02,
// which works correctly
initial begin
  reset = 'b0;
  encrypt_decrypt = 'b0;
  start = 'b0;
  #(56ns)


  // 2 simple encryption tests
  start = 'b1;
  message = 'h0;
  key     = 'b11100111; // 00E7
  // Result will be 00E7_00E7_00E7_00E7, key just gets copied
  #(550ns);
  encrypt1: assert (result == 'h00E7_00E7_00E7_00E7);

  start = 'b1;
  message = 'h1111_1234_1100_11E7;
  key     = 'b11100111; // 00E7
  // Result of first chunk (lsbs) will be (11E7 ^ 00E7) = 1100
  // with 2nd: 1100 ^ 1100 = 0000
  // with 3rd: 0000 ^ 1234 = 1234
  // with 4th: 1111 ^ 1234 = 0325
  // 1100_1100_1100_1100
  #(550ns);
  encrypt2: assert (result == 'h0325_1234_0000_1100);

  // 2 simple decryption tests
  encrypt_decrypt = 'b1;
  message = 'h0325_1234_0000_1100;
  key     = 'b11100111; // 00E7
  #(550ns);
  decrypt1: assert (result == 'h1111_1234_1100_11E7);

  encrypt_decrypt = 'b1;
  message = 'h00E7_00E7_00E7_00E7;
  key     = 'b11100111; // 00E7
  #(550ns);
  decrypt2: assert (result == 'h0);

  // Randomness!
  // Encryption
  encrypt_decrypt = 'b0;
  for (int i=0; i<50; i++) begin
    message = $random;
    key = $random;
    #(550ns);
  end

  // Decryption
  encrypt_decrypt = 'b1;
  #(55ns)
  for (int i=0; i<50; i++) begin
    message = $random;
    key = $random;
    #(550ns);
  end

  $finish;

end





endmodule
