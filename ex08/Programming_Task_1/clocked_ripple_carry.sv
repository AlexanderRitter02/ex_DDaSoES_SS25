module clocked_ripple_carry (
    input logic [7 : 0] a_i,
    input logic [7 : 0] b_i,
    input logic clock_i,
    input logic reset_ni,
    output logic carry_out_register,
    output logic [7 : 0] out_register
);

logic c_o;
logic [7:0] o_o;

ripple_carry #(
  .N(8)
) i_dut (
  .a_i(a_i),
  .b_i(b_i),
  .c_i('b0),
  .c_o(c_o),
  .o_o(o_o)
);

always_ff @(posedge clock_i) begin
    if(!reset_ni) begin
        out_register = 'b0;
        carry_out_register = 'b0;
    end else begin
        out_register = o_o;
        carry_out_register = c_o;
    end
end

endmodule