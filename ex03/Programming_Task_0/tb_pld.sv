module tb_pld;

  localparam NUM_PORTS_IN = 2;
  localparam NUM_PORTS_OUT = 1;

  logic [NUM_PORTS_IN - 1 : 0] inputs;
  logic [(2**(NUM_PORTS_IN + 2)) * (NUM_PORTS_IN**2) - 1 : 0] and_matrix_fuses_conf;
  logic [NUM_PORTS_OUT * (2**(2*NUM_PORTS_IN)) - 1 : 0] or_matrix_fuses_conf;
  logic [NUM_PORTS_OUT - 1 : 0] outputs;

  pld #(
    .NUM_PORTS_IN(NUM_PORTS_IN),
    .NUM_PORTS_OUT(NUM_PORTS_OUT)
  ) i_dut (
    .inputs_i(inputs),
    .and_matrix_fuses_conf_i(and_matrix_fuses_conf),
    .or_matrix_fuses_conf_i(or_matrix_fuses_conf),
    .outputs_o(outputs)
  );

  initial begin

    and_matrix_fuses_conf = 'b0001001000010010000100100001001000010010000100100010001010000010;
    or_matrix_fuses_conf  = 'b0000000000001111;
    #(10ns)
    
	// Testbench Start
	#(10ns) ;
	inputs = 'b00;
	#(10ns) ;
	inputs = 'b01;
	#(10ns) ;
	inputs = 'b10;
	#(10ns) ;
	inputs = 'b11;
	#(10ns) ;
	// Testbench End

  end
endmodule
