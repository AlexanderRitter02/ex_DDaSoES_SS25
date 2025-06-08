import fourteen_segment_display::*;
module status_module(
  input logic  [7 : 0] temperature_in,
  input logic reset_n_in,
  input logic clock_in,
  output logic [14:0] display_pins_out
);

typedef enum {
    RESET,
    OKAY,
    COLD,
    WARM,
    TOO_COLD,
    TOO_WARM
} state_t;

state_t current_state, next_state; 


// State transitions on positive clock edge and reset
always_ff @(posedge clock_in or negedge reset_n_in) begin
    if(!reset_n_in) begin
        current_state <= RESET;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    case(current_state)
      COLD: begin
        display_pins_out = C;
      end
      WARM: begin
        display_pins_out = W;
      end
      OKAY: begin
        display_pins_out = O;
      end
      TOO_COLD: begin
        display_pins_out = C_dot;
      end
      TOO_WARM: begin
        display_pins_out = W_dot;
      end
      default: begin
        display_pins_out = R;
      end
    endcase
end

// State transitions
always_comb begin
    case (current_state) inside
        RESET, OKAY: begin
            if($signed(temperature_in) <= -16) begin
                next_state = COLD;
            end else if($signed(temperature_in) > 45) begin
                next_state = WARM;
            end else begin
                next_state = OKAY;
            end
        end
        COLD: begin
            // Additional case <-45° (check first!)
            if($signed(temperature_in) < -45) begin
                next_state = TOO_COLD;
            end else if($signed(temperature_in) <= -16) begin
                next_state = COLD;
            end else if($signed(temperature_in) > 45) begin
                next_state = WARM;
            end else begin
                next_state = OKAY;
            end
        end
        WARM: begin
            // Additional case >60° (check first!)
            if($signed(temperature_in) > 60) begin
                next_state = TOO_WARM;
            end else if($signed(temperature_in) <= -16) begin
                next_state = COLD;
            end else if($signed(temperature_in) > 45) begin
                next_state = WARM;
            end else begin
                next_state = OKAY;
            end
        end
        TOO_WARM: begin
            next_state = RESET;
        end
        TOO_COLD: begin
            next_state = RESET;
        end
        default: begin
            next_state = RESET;
        end
    endcase
end

endmodule