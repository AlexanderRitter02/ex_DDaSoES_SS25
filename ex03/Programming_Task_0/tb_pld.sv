module tb_pld;


  // ######## TEST-1 Start: {OR(AND(NOT(A), B)), OR(AND(A, B, C), AND(NOT(A), B))} ########

  localparam test1_NUM_PORTS_IN = 3;
  localparam test1_NUM_PORTS_OUT = 2;

  logic [test1_NUM_PORTS_IN - 1 : 0] test1_inputs;
  logic [(2**(test1_NUM_PORTS_IN + 2)) * (test1_NUM_PORTS_IN**2) - 1 : 0] test1_and_matrix_fuses_conf;
  logic [test1_NUM_PORTS_OUT * (2**(2*test1_NUM_PORTS_IN)) - 1 : 0] test1_or_matrix_fuses_conf;
  logic [test1_NUM_PORTS_OUT - 1 : 0] test1_outputs_pld;
  logic [test1_NUM_PORTS_OUT - 1 : 0] test1_outputs_clone;

  pld #(
    .NUM_PORTS_IN(test1_NUM_PORTS_IN),
    .NUM_PORTS_OUT(test1_NUM_PORTS_OUT)
  ) pld_test1 (
    .inputs_i(test1_inputs),
    .and_matrix_fuses_conf_i(test1_and_matrix_fuses_conf),
    .or_matrix_fuses_conf_i(test1_or_matrix_fuses_conf),
    .outputs_o(test1_outputs_pld)
  );
  test1_mirror_func test1_mirror (
    .in(test1_inputs),
    .out(test1_outputs_clone)
  );

  initial begin

    
    test1_and_matrix_fuses_conf = 'b000001000010000001000010000001000010000001000010000001000010000001000010000001000010000001000010000001000010000001000010000001000010000001000010000001000010000001000010000001000010000010000010000010000010000100000010000010000010000010000010000100000010000001000001000001010000000100000001;
    test1_or_matrix_fuses_conf  = 'b00000000000000000000000000000000000000000000000000000000000000000000000000000000111111110000000000000000010000000000000010111111;
    #(10ns)
    
    // Testbench Start
    #(10ns);
    test1_inputs = 'b000;
    #(10ns);
    assert (test1_outputs_clone == test1_outputs_pld);
    test1_inputs = 'b001;
    #(10ns);
    assert (test1_outputs_clone == test1_outputs_pld);
    test1_inputs = 'b010;
    #(10ns);
    assert (test1_outputs_clone == test1_outputs_pld);
    test1_inputs = 'b011;
    #(10ns);
    assert (test1_outputs_clone == test1_outputs_pld);
    test1_inputs = 'b100;
    #(10ns);
    assert (test1_outputs_clone == test1_outputs_pld);
    test1_inputs = 'b101;
    #(10ns);
    assert (test1_outputs_clone == test1_outputs_pld);
    test1_inputs = 'b110;
    #(10ns);
    assert (test1_outputs_clone == test1_outputs_pld);
    test1_inputs = 'b111;
    #(10ns);
    assert (test1_outputs_clone == test1_outputs_pld);
    // Testbench End
  end
  // ######## TEST-1 End ########






  // ######## TEST-2 Start: {OR(AND(NOT(A), NOT(B)))} ########
  // This is the test given on the exercise sheet and was manually verified by sketching it too

  localparam test2_NUM_PORTS_IN = 2;
  localparam test2_NUM_PORTS_OUT = 1;

  logic [test2_NUM_PORTS_IN - 1 : 0] test2_inputs;
  logic [(2**(test2_NUM_PORTS_IN + 2)) * (test2_NUM_PORTS_IN**2) - 1 : 0] test2_and_matrix_fuses_conf;
  logic [test2_NUM_PORTS_OUT * (2**(2*test2_NUM_PORTS_IN)) - 1 : 0] test2_or_matrix_fuses_conf;
  logic [test2_NUM_PORTS_OUT - 1 : 0] test2_outputs_pld;
  logic [test2_NUM_PORTS_OUT - 1 : 0] test2_outputs_clone;

  pld #(
    .NUM_PORTS_IN(test2_NUM_PORTS_IN),
    .NUM_PORTS_OUT(test2_NUM_PORTS_OUT)
  ) pld_test2 (
    .inputs_i(test2_inputs),
    .and_matrix_fuses_conf_i(test2_and_matrix_fuses_conf),
    .or_matrix_fuses_conf_i(test2_or_matrix_fuses_conf),
    .outputs_o(test2_outputs_pld)
  );
  test2_mirror_func test2_mirror (
    .in(test2_inputs),
    .out(test2_outputs_clone)
  );

  initial begin

    test2_and_matrix_fuses_conf = 'b0001001000010010000100100001001000010010000100100010001010000010;
    test2_or_matrix_fuses_conf  = 'b0000000000001111;
    #(10ns)
    
	// Testbench Start
	#(10ns) ;
	test2_inputs = 'b00;
	#(10ns) ;
        assert (test2_outputs_clone == test2_outputs_pld);
	test2_inputs = 'b01;
	#(10ns) ;
        assert (test2_outputs_clone == test2_outputs_pld);
	test2_inputs = 'b10;
	#(10ns) ;
        assert (test2_outputs_clone == test2_outputs_pld);
	test2_inputs = 'b11;
	#(10ns) ;
        assert (test2_outputs_clone == test2_outputs_pld);
	// Testbench End
  end
  // ######## TEST-2 End ########














endmodule
