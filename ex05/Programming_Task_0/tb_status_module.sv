import fourteen_segment_display::*;
module tb_status_module;

logic  [7 : 0] temperature;
logic rst_ni;
logic clk_i;
logic [14:0] fourteen_seg_out;

seg_display status_mod (
    .data_i(temperature),
    .rst_ni(rst_ni),
    .clk_i(clk_i),
    .fourteen_seg_out(fourteen_seg_out)
);


// We go for a manual clock to better control it here before deciding to do it differently in the other tasks
initial begin

    // #### START-1: Single-State Transitions from Reset ####
    rst_ni = 'b1;
    #(5ns)

    // R -> C
    rst_ni = 'b0;
    #(1ns);
    rst_ni = 'b1;
    clk_i = 'b0;
    temperature = -16;
    #(1ns);
    clk_i = ~clk_i;
    #(1ns);
    reset_to_cold: assert (fourteen_seg_out == C);

    // R -> O
    rst_ni = 'b0;
    #(1ns);
    rst_ni = 'b1;
    clk_i = 'b0;
    temperature = -15;
    #(1ns);
    clk_i = ~clk_i;
    #(1ns);
    reset_to_okay_lower_bound: assert (fourteen_seg_out == O);

    rst_ni = 'b0;
    #(1ns);
    rst_ni = 'b1;
    clk_i = 'b0;
    temperature = 45;
    #(1ns);
    clk_i = ~clk_i;
    #(1ns);
    reset_to_okay_upper_bound: assert (fourteen_seg_out == O);

     // R -> W
    rst_ni = 'b0;
    #(1ns);
    rst_ni = 'b1;
    clk_i = 'b0;
    temperature = 46;
    #(1ns);
    clk_i = ~clk_i;
    #(1ns);
    reset_to_warm: assert (fourteen_seg_out == W);

    // #### END-1 ####



    // #### START-2: Transitions from start into too hot / too cold with reset following ####

    // R -> C -> C. -> R
    rst_ni = 'b0;
    #(1ns);
    rst_ni = 'b1;
    clk_i = 'b0;
    temperature = -60;
    #(1ns);
    clk_i = ~clk_i;
    #(1ns);
    reset_to_cold2: assert (fourteen_seg_out == C);
    clk_i = ~clk_i; // 1 -> 0
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    too_cold: assert (fourteen_seg_out == C_dot)
    clk_i = ~clk_i; // 1 -> 0
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    reset_after_too_cold: assert (fourteen_seg_out == R);


     // R -> W -> W. -> R
    rst_ni = 'b0;
    #(1ns);
    rst_ni = 'b1;
    clk_i = 'b0;
    temperature = 61;
    #(1ns);
    clk_i = ~clk_i;
    #(1ns);
    reset_to_warm2: assert (fourteen_seg_out == W);
    clk_i = ~clk_i; // 1 -> 0
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    too_warm: assert (fourteen_seg_out == W_dot)
    clk_i = ~clk_i; // 1 -> 0
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    reset_after_too_warm: assert (fourteen_seg_out == R);

    // #### END-2 ####


    // START-3: From (COLD, WARM, OKAY) to (COLD, WARM, OKAY) (some tests)

    rst_ni = 'b0;
    #(1ns);
    rst_ni = 'b1;
    clk_i = 'b0;
    temperature = 15;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    stay_okay: assert (fourteen_seg_out == O);


    // (OKAY) -> (WARM); (stay in warm); (WARM) -> (OKAY)
    clk_i = ~clk_i; // 1 -> 0
    temperature = 50;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    okay_to_warm: assert (fourteen_seg_out == W);
    clk_i = ~clk_i; // 1 -> 0
    temperature = 47;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    stay_warm: assert (fourteen_seg_out == W);
    clk_i = ~clk_i; // 1 -> 0
    temperature = 20;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    warm_to_okay: assert (fourteen_seg_out == O);

    // (OKAY) -> (COLD); (stay cold); (COLD) -> (WARM); (WARM) -> (COLD); (COLD) -> (OKAY)
    clk_i = ~clk_i; // 1 -> 0
    temperature = -30;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    okay_to_cold: assert (fourteen_seg_out == C);
    clk_i = ~clk_i; // 1 -> 0
    temperature = -31;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    stay_cold: assert (fourteen_seg_out == C);
    temperature = 100;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    cold_to_warm: assert (fourteen_seg_out == W);
    clk_i = ~clk_i; // 1 -> 0
    temperature = -20;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    warm_to_cold: assert (fourteen_seg_out == C);
    clk_i = ~clk_i; // 1 -> 0
    temperature = 0;
    #(1ns);
    clk_i = ~clk_i; // 0 -> 1
    #(1ns);
    cold_to_okay: assert (fourteen_seg_out == O);

    // #### END-3 ####

    
    
    // #### START-4 Make sure the asynchronous reset is asynchronous ####
    rst_ni = 'b0;
    #(1ns);
    reset: assert (fourteen_seg_out == R);
    #(1ns);
    // #### END-4 ####
    

end

endmodule
