module tb_adder;
  // wait time
  localparam WT = 30ps;

  logic [7 : 0] a, b, o;
  logic c_o;
  logic clock_in = 'b0;
  logic reset_ni = 'b0;

  clocked_ripple_carry i_dut (
      .a_i(a),
      .b_i(b),
      .clock_i(clock_in),
      .reset_ni(reset_ni),
      .carry_out_register(c_o),
      .out_register(o)
  );

  always #(WT) clock_in = ~clock_in;

  initial begin

    // Reset
    reset_ni = 'b0;
    a = 'b0;
    b = 'b0;
    @(posedge clock_in);
    reset_ni = 'b1;

    @(posedge clock_in);


    // We have two posedges after setting the output bc we can't assert at the same time
    // where the output changes to the result

    a   = 'b110;
    b   = 'b110;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b1100 && c_o == 'b0);

    a   = 'b10000000;
    b   = 'b10000000;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b00000000 && c_o == 'b1);

    a   = 'b0;
    b   = 'b11111111;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b11111111 && c_o == 'b0);

    // Overflows
    a   = 'b1;
    b   = 'b11111111;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b00000000 && c_o == 'b1);

    a   = 'b10;
    b   = 'b11111111;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b00000001 && c_o == 'b1);

    a   = 'b10111101;
    b   = 'b10111101;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b01111010 && c_o == 'b1);

    // More normal examples
    a   = 'b11;
    b   = 'b100;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b111 && c_o == 'b0);

    a   = 'b0;
    b   = 'b0;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b0 && c_o == 'b0);

    a   = 'b11111110;
    b   = 'b1;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b11111111 && c_o == 'b0);

    a   = 'b1;
    b   = 'b11111110;
    @(posedge clock_in);
    @(posedge clock_in);
    assert(o == 'b11111111 && c_o == 'b0);

    $finish;
  end
endmodule
