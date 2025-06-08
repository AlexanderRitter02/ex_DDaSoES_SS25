module avg(
    input logic rst_ni,
    input logic clk_i,
    input logic  [7:0] temperature,
    output logic [7:0] data_o
);

// In this task, you will create a small process pipeline that reads the temperature from a model of an 8-bit signed
// temperature sensor, calculates the average of the last three measurements and passes this to a status process. The
// model of the temperature sensor outputs a new random temperature value each time the sample_in signal changes.
// The status process reacts to the measured temperature and outputs it on a 14-segment display (14SA) 1 . An overview
// of the pipeline can be seen in Figure 1.

logic [7:0] measurement_previous;
logic [7:0] measurement_pre_previous;

// What results if no average can be calculated (first three values?)
always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        // It makes sense to reset to the currently measured temperature instead of 0 bc it may immediately get read out
        // In testing though we should still wait 3 cycles after reset always
        measurement_previous     <= temperature;
        measurement_pre_previous <= temperature;
        data_o <= temperature;
    end else begin
        data_o <= (signed'(temperature) + signed'(measurement_previous) + signed'(measurement_pre_previous)) / 3;
        measurement_previous     <= temperature;
        measurement_pre_previous <= measurement_previous;
    end
end

endmodule