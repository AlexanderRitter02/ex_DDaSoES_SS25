module tb_pld;

  localparam NUM_PORTS_IN = 3;
  localparam NUM_PORTS_OUT = 8;

  logic [NUM_PORTS_IN - 1 : 0] inputs;
  logic [(2**(NUM_PORTS_IN + 2)) * (NUM_PORTS_IN**2) - 1 : 0] and_matrix_fuses_conf;
  logic [NUM_PORTS_OUT * (2**(2*NUM_PORTS_IN)) - 1 : 0] or_matrix_fuses_conf;
  logic [NUM_PORTS_OUT - 1 : 0] outputs;

  pld #(
    // TODO
  ) i_dut (
    // TODO
  );

  initial begin

    // TODO

  end
endmodule
