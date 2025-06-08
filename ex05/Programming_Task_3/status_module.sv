import fourteen_segment_display::*;
module seg_display(
  input logic  [7 : 0] data_i,
  input logic rst_ni,
  input logic clk_i,
  output logic [14:0] fourteen_seg_out
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
always_ff @(posedge clk_i or negedge rst_ni) begin
    if(!rst_ni) begin
        current_state <= RESET;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    case(current_state)
      COLD: begin
        fourteen_seg_out = C;
      end
      WARM: begin
        fourteen_seg_out = W;
      end
      OKAY: begin
        fourteen_seg_out = O;
      end
      TOO_COLD: begin
        fourteen_seg_out = C_dot;
      end
      TOO_WARM: begin
        fourteen_seg_out = W_dot;
      end
      default: begin
        fourteen_seg_out = R;
      end
    endcase
end

// State transitions
always_comb begin
    case (current_state) inside
        RESET, OKAY: begin
            if($signed(data_i) <= -16) begin
                next_state = COLD;
            end else if($signed(data_i) > 45) begin
                next_state = WARM;
            end else begin
                next_state = OKAY;
            end
        end
        COLD: begin
            // Additional case <-45° (check first!)
            if($signed(data_i) < -45) begin
                next_state = TOO_COLD;
            end else if($signed(data_i) <= -16) begin
                next_state = COLD;
            end else if($signed(data_i) > 45) begin
                next_state = WARM;
            end else begin
                next_state = OKAY;
            end
        end
        WARM: begin
            // Additional case >60° (check first!)
            if($signed(data_i) > 60) begin
                next_state = TOO_WARM;
            end else if($signed(data_i) <= -16) begin
                next_state = COLD;
            end else if($signed(data_i) > 45) begin
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