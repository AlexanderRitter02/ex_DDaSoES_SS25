// ALU opcodes from forum post
// https://ovidius.uni-tuebingen.de/ilias3/ilias.php?baseClass=ilrepositorygui&cmdNode=z5:o7&cmdClass=ilObjForumGUI&cmd=selectPost&ref_id=5059772&pos_pk=451249&thr_pk=127519#451249
package alu_package;

  typedef enum logic [1:0] {
    ADD = 2'd0,
    SUB = 2'd1,
    ENC = 2'd2,
    DEC = 2'd3
  } instruction_t;

endpackage

import alu_package::*;


module alu (
  input logic [15:0] a,
  input logic [15:0] b,
  input logic [1:0] instruction,
  output logic [15:0] alu_output
);

// Continous assignments (ALU always calculates everything)
logic [15:0] add, sub;
assign add = a + b;
assign sub = a - b;

logic enc_dec;
assign enc_dec = instruction == DEC;

// N=1, M=2
// a is the mssage (two one byte chunks)
// b contains the key in the lower 8 bits
wire [15:0] cbc_result;
cbc # (
  .n(1),
  .m(2)
) crypt_engine (
  .enc_dec(enc_dec),
  .message(a),
  .key(b[7:0]),
  .out(cbc_result)
);

// Multiplexer choosing result
always_comb begin
  case (instruction)
    ADD: alu_output = add;
    SUB: alu_output = sub;
    ENC: alu_output = cbc_result;
    DEC: alu_output = cbc_result;
  endcase
end


endmodule
