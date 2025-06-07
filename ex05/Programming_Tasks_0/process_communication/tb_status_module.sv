module tb_cdc

typedef logic [14 : 0] pins_out;

localparam pins_out R = 'b001110001001101;
localparam pins_out O = 'b001010100010101;
localparam pins_out C = 'b001010100000001;
localparam pins_out W = 'b001011001010100;
localparam pins_out C_dot = 'b001010100100001;
localparam pins_out W_dot = 'b001011001110100;

logic  [7 : 0] temperature_in,
logic reset_n_in,
logic clock_in,
logic [14:0] display_pins_out

status_module status_mod (
    .temperature_intemperature_in
    .reset_n_in(reset_n_in),
    .clock_in(clock_in),
    .display_pins_out(display_pins_out)
);


initial begin

    // #### START-1: Single-State Transitions from Reset ####
    

    // R -> C
    reset_n_in = 'b0;
    clock_in = 'b0;
    temperature = -16;
    #(1ns);
    clock_in = ~clock_in;
    reset_to_cold: assert (display_pins_out == C)

     // R -> O
    reset_n_in = 'b0;
    clock_in = 'b0;
    temperature = -15;
    #(1ns);
    clock_in = ~clock_in;
    reset_to_okay_lower_bound: assert (display_pins_out == O)
    reset_n_in = 'b0;
    clock_in = 'b0;
    temperature = -45;
    #(1ns);
    clock_in = ~clock_in;
    reset_to_okay_upper_bound: assert (display_pins_out == O)

     // R -> W
    reset_n_in = 'b0;
    clock_in = 'b0;
    temperature = 46;
    #(1ns);
    clock_in = ~clock_in;
    reset_to_warm: assert (display_pins_out == W)

    // #### END-1 ####



    // #### START-2: Transitions from start into too hot / too cold with reset following ####

     // R -> C
    rst_ni = 'b0;
    temperature = -60;
    #(1ns);
    clock_in = ~clock_in;
    reset_to_cold2: assert (display_pins_out == C)
    clock_in = ~clock_in;
    clock_in = ~clock_in;
    too_cold: assert (display_pins_out == C_dot)

    // #### END-2 ####

end

endmodule
