module tb_moving_average;

logic clock_in;
logic reset_n_in;
logic [7 : 0] temperature;
logic [7 : 0] temperature_average;

avg u_avg (
    .rst_ni         (reset_n_in),
    .clk_i          (clock_in),
    .temperature    (temperature),
    .data_o         (temperature_average)
);

sequence average_after_three_vals;
  logic signed [7:0] temperature1, temperature2, temperature3;

  temperature1 = temperature ##1
  temperature2 = temperature ##1
  temperature3 = temperature ##1
  ##1 temperature_average == (temperature1 + temperature2 + temperature3) / 3;
endsequence

property average_out;
  @(posedge clock_in) disable iff (!reset_n_in)
  average_after_three_vals;
endproperty

always #(5ns) clock_in = ~clock_in;

//assert property (average_out);
assert property average_out;


initial begin

    reset_n_in = 'b1;
    temperature = 10;
    #(11ns);
    temperature = 50;
    #(5ns);
    temperature = -10;
    #(10ns);



end

endmodule