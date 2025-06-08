module tb_modulo;

logic [31:0] input_a;
logic [31:0] input_b;
logic [31:0] result;

logic clock = 'b0;
logic reset = 'b0;
logic start = 'b0;

// Other outputs
logic done;
logic idle;
logic ready;

modulo mod (
	.ap_clk(clock),
	.ap_rst(reset),
	.ap_start(start),
	.ap_done(done),
	.ap_idle(idle),
	.ap_ready(ready),
	.a(input_a),
	.b(input_b),
	.ap_return(result)
);

always #(1ns) clock = ~clock;


initial begin

  // Reset is already disabled, set inputs
  #(20ns);

  // Test case a)
  input_a = 32;
  input_b = 3;
  #(20ns);

  start = 'b1;
  #(5ns);
  start = 'b0;
  #(60ns);
  result_a: assert (result == 2);
  #(30ns);
  
  // Are done, is idle set back at any point?
  
  // Maybe a reset (also a test case)
  reset = 'b1;
  #(100ns);
  reset = 'b0;
  #(100ns);
  
  // Test case b)
  input_a = 255;
  input_b = 250;
  start = 'b1;
  #(100ns);
  start = 'b0;
  result_b: assert (result == 5);
  
  // c) Third (do reset in the middle of the calculation)
  input_a = 2147483647;
  input_b = 2147483646;
  start = 'b1;
  #(5ns);
  start = 'b0;
  #(30ns);
  reset = 'b1;
  #(30ns);
  start = 'b0;
  #(30ns);
  result_c: assert (result == 1);
  reset = 'b0;
  #(70ns);

  $finish;

end


endmodule