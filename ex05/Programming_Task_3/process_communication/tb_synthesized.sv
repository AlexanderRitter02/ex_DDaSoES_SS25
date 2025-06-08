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

always #(5ns) clock_in = ~clock_in;


initial begin

    temperature = 10;

    reset_n_in = 'b0;
    clock_in   = 'b0;

    #(10ns)
    reset_n_in = 'b1;
    #(1ns);
    val1: assert ($signed(temperature_average) == 10);

    temperature = 50;
    #(5ns);
    val2: assert ($signed(temperature_average) == 23);

    temperature = -27;
    #(10ns);
    val3: assert ($signed(temperature_average) == 11);

    temperature = -32;
    #(10ns);
    val4: assert ($signed(temperature_average) == -3);

    // Dont change value from -36, see if average settles
    #(10ns);
    val5: assert ($signed(temperature_average) == -30);

    #(10ns);
    val6: assert ($signed(temperature_average) == -32);

    // Change temperature inside clock cycle, it should not do anything except the one set to before rising edge
    temperature = 90;
    #(6ns);
    nochange1: assert ($signed(temperature_average) == -32)
    temperature = 50;
    #(2ns);
    nochange2: assert ($signed(temperature_average) == -32)
    temperature = 0;
    #(2ns) // This goes over the rising clock edge
    val7: assert ($signed(temperature_average) == -21)

    #(10ns)
    val8: assert ($signed(temperature_average) == -10)

    temperature = 90;
    #(10ns)
    val9: assert ($signed(temperature_average) == 30);

    temperature = -30;
    #(10ns)
    val10: assert ($signed(temperature_average) == 20);

    temperature = 6;
    #(10ns)
    val11: assert ($signed(temperature_average) == 22);

    // Multiple cycles to settle on 6, then:
    // A somewhat realistic variation of +-2 around the actual value of 6 -> still fluctuating a lot with just 3 average values
    #(30ns)
    temperature = 5;
    #(10ns)
    val12:assert ($signed(temperature_average) == 5);

    temperature = 6;
    #(10ns)
    val13: assert ($signed(temperature_average) == 5);

    temperature = 7;
    #(10ns)
    val14: assert ($signed(temperature_average) == 6);

    temperature = 8;
    #(10ns)
    val15: assert ($signed(temperature_average) == 7);

    temperature = 5;
    #(10ns)
    val16: assert ($signed(temperature_average) == 6);


    $finish;

end

endmodule