module fuse (
    input  logic a,
    input  logic set,
    output logic b
);

  // b->in, set->control, a->out
  // Mind high impedance state

  always_comb begin

    // If the control input of the fuse is set to logic-0, the output should be high-impedance.
    if(set == 'b0) begin
      b = 1'bz;
    //  If the control input is set to logic-1, the input is connected to the output.
    end else begin
      b = a;
    end
  end



endmodule
