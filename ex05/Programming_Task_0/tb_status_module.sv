import fourteen_segment_display::*;
module tb_status_module;

logic  [7 : 0] temperature;
logic reset_n_in;
logic clock_in;
logic [14:0] display_pins_out;

status_module status_mod (
    .temperature_in(temperature),
    .reset_n_in(reset_n_in),
    .clock_in(clock_in),
    .display_pins_out(display_pins_out)
);

//always #(10ns) clk_i = ~clk_i;



initial begin

    // #### START-1: Single-State Transitions from Reset ####
    reset_n_in = 'b1;
    #(5ns)

    // R -> C
    reset_n_in = 'b0;
    #(1ns);
    reset_n_in = 'b1;
    clock_in = 'b0;
    temperature = -16;
    #(1ns);
    clock_in = ~clock_in;
    #(1ns);
    reset_to_cold: assert (display_pins_out == C);

    // R -> O
    reset_n_in = 'b0;
    #(1ns);
    reset_n_in = 'b1;
    clock_in = 'b0;
    temperature = -15;
    #(1ns);
    clock_in = ~clock_in;
    #(1ns);
    reset_to_okay_lower_bound: assert (display_pins_out == O);

    reset_n_in = 'b0;
    #(1ns);
    reset_n_in = 'b1;
    clock_in = 'b0;
    temperature = 45;
    #(1ns);
    clock_in = ~clock_in;
    #(1ns);
    reset_to_okay_upper_bound: assert (display_pins_out == O);

     // R -> W
    reset_n_in = 'b0;
    #(1ns);
    reset_n_in = 'b1;
    clock_in = 'b0;
    temperature = 46;
    #(1ns);
    clock_in = ~clock_in;
    #(1ns);
    reset_to_warm: assert (display_pins_out == W);

    // #### END-1 ####



    // #### START-2: Transitions from start into too hot / too cold with reset following ####

    // R -> C -> C. -> R
    reset_n_in = 'b0;
    #(1ns);
    reset_n_in = 'b1;
    clock_in = 'b0;
    temperature = -60;
    #(1ns);
    clock_in = ~clock_in;
    #(1ns);
    reset_to_cold2: assert (display_pins_out == C);
    clock_in = ~clock_in; // 1 -> 0
    #(1ns);
    clock_in = ~clock_in; // 0 -> 1
    #(1ns);
    too_cold: assert (display_pins_out == C_dot)
    clock_in = ~clock_in; // 1 -> 0
    #(1ns);
    clock_in = ~clock_in; // 0 -> 1
    #(1ns);
    reset_after_too_cold: assert (display_pins_out == R);


     // R -> W -> W. -> R
    reset_n_in = 'b0;
    #(1ns);
    reset_n_in = 'b1;
    clock_in = 'b0;
    temperature = 61;
    #(1ns);
    clock_in = ~clock_in;
    #(1ns);
    reset_to_warm2: assert (display_pins_out == W);
    clock_in = ~clock_in; // 1 -> 0
    #(1ns);
    clock_in = ~clock_in; // 0 -> 1
    #(1ns);
    too_warm: assert (display_pins_out == W_dot)
    clock_in = ~clock_in; // 1 -> 0
    #(1ns);
    clock_in = ~clock_in; // 0 -> 1
    #(1ns);
    reset_after_too_warm: assert (display_pins_out == R);

    // #### END-2 ####


    // START-3: From (COLD, WARM, OKAY) to (COLD, WARM, OKAY)



    

end

endmodule
