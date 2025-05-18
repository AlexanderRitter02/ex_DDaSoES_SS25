module alu_testbench;

logic [15:0] a;
logic [15:0] b;
logic [1:0] instruction;
logic [15:0] alu_output;

alu ALU (
  .a(a),
  .b(b),
  .instruction(instruction),
  .alu_output(alu_output)
);


initial begin

  // ######## ADDITION AND SUBSTRACTION TESTS ########

  a = 'd1210;
  b = 'd2790;
  instruction = ADD;
  #1;
  add_to_4000: assert (alu_output == 'd4000);
  a = 'd9;
  b = 'd2;
  instruction = ADD;
  #1;
  add_simple_nine_plus_two: assert (alu_output == 'd11);
  instruction = SUB;
  #1;
  sub_simple_nine_minus_two: assert (alu_output == 'd7);
  a = 'd511;
  b = 'd567;
  #1;
  sub_into_negative: assert (alu_output == 'b1111111111001000); // -56 in 16bit twos complement
  a = 'd367;
  b = 'd367;
  #1;
  sub_to_zero: assert (alu_output == 'd0);
  a = 'd65534;
  b = 'd65535;
  #1
  sub_overflow: assert (alu_output == 'd65535);

  // 65 535 is the 16bit limit (unsigned numbers). Addition overflow should just circle back like a modulo group (mod 65 536).
  instruction = ADD;
  a = 'd65000;
  b = 'd537;
  #1;
  add_overflow: assert (alu_output == 'd1);


  // ######## CBC ENCRYPTION/DECRYPTION ########
  // Decryption always mirrors encryption to make sure "dec(enc(msg)) = msg" holds

  // Simple zero key and second chunk of message zero so the output corresponds to just a repetition of the first message chunk
  instruction = ENC;
  a = 'b0000000011010010;
  b = 'b00000000;
  #1;
  encryption_zero_key: assert (alu_output == 'b1101001011010010);
  instruction = DEC;
  a = 'b1101001011010010;
  #1;
  decryption_zero_key: assert (alu_output == 'b0000000011010010);

  // Test case 2 for encryption/decryption
  instruction = ENC;
  a = 'hC4BB;
  b = 'h00A9;
  #1;
  $display("%h", alu_output);
  encryption_case2: assert (alu_output == 'hD612);
  instruction = DEC;
  a = 'hD612;
  #1;
  decryption_case2: assert (alu_output == 'hC4BB);
  

end

endmodule