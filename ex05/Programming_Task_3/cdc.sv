module n_bit_cdc (
  input logic rst_ni,
  input logic clk_0_i,
  input logic [7:0] data_i,
  input logic clk_1_i,
  output logic [7:0] data_o
);

//  The output is the data that is forwarded to the status module.
//  1. The input data is written to a register/memory on a positive clock edge of the fast clock.
// The following two registers/memories read the data at their data inputs (D) on a positive clock edge of the slow clock. Pay attention to the correct bit width.


logic [7:0] register_fast;

logic [7:0] register_slow_1;
logic [7:0] register_slow_2;

assign data_o = register_slow_2;

always_ff @(posedge clk_0_i or negedge rst_ni) begin
  if(!rst_ni) begin
    register_fast <= 'b0;
  end else begin
    register_fast <= data_i;
  end
end

always_ff @(posedge clk_1_i or negedge rst_ni) begin
  if(!rst_ni) begin
    register_slow_1 <= 'b0;
    //register_slow_2 <= 'b0;
  end else begin
    register_slow_1 <= register_fast;
    //register_slow_2 <= register_slow_1;
  end
end

always_ff @(posedge clk_1_i or negedge rst_ni) begin
  if(!rst_ni) begin
    //register_slow_1 <= 'b0;
    register_slow_2 <= 'b0;
  end else begin
    //register_slow_1 <= register_fast;
    register_slow_2 <= register_slow_1;
  end
end



endmodule