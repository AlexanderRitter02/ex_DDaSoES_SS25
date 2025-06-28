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

crypt_message cbc (
	.ap_clk(clock),
	.ap_rst(reset),
	.ap_start(start),
	.ap_done(done),
	.ap_idle(idle),
	.ap_ready(ready),
	.encrypt_decrypt(encrypt_decrypt),
	.message(message),
	.key(key),
  .ap_return(result)
);

always #(55ns) clock = ~clock;

// Check whether on the next clock rising edge after done rising the cbc's have the same output
property mirror_check;
  disable iff (reset)
  @(posedge done)
    ##1 @(posedge clock) (result === result_exercise2);
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

  // Randomness!
  // Encryption
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
