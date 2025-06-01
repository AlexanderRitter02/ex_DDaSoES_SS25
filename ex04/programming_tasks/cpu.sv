import rriscv_pkg::*;

module cpu (
    input logic halt_i,
    input logic clk_i,
    input logic rst_n_i,

    input logic [XLEN - 1 : 0] instr_data_i,
    output logic [XLEN - 1 : 0] instr_mem_addr_o,
    output logic instr_mem_addr_valid_o,

    input logic [XLEN - 1 : 0] mem_data_i,
    input logic mem_data_valid_i,
    output logic mem_write_o,
    output logic [XLEN - 1 : 0] mem_data_o,
    output logic [XLEN - 1 : 0] mem_addr_o,
    output logic error_o
);


  // Simple implementation of halt
  logic halt_w;

  // Error Signal
  logic error_w;

  // Programm counter
  logic [XLEN - 1 : 0] programm_counter_r;
  // Next PC value
  logic [XLEN - 1 : 0] next_programm_counter_w;
  // Next regular programm counter value
  logic [XLEN - 1 : 0] next_program_counter_regular_w;
  // Next program counter if a jump happened
  logic [XLEN - 1 : 0] next_program_counter_jmp_w;
  // Select next program counter value
  logic next_program_counter_sel_w;

  // Instruction decoding
  logic [6 : 0] id_opcode;
  logic [4 : 0] id_rs1;
  logic [4 : 0] id_rs2;
  logic [2 : 0] id_funct3;
  logic [6 : 0] id_funct7;
  logic [4 : 0] id_rd;
  logic id_rf_rw;
  logic [XLEN - 1 : 0] id_immediate;

  // Register File
  logic [XLEN - 1 : 0] rf_data;
  logic [XLEN - 1 : 0] rf_data_a;
  logic [XLEN - 1 : 0] rf_data_b;

  // Alu
  logic [XLEN - 1 : 0] alu_value_b;
  logic alu_zero;
  logic [XLEN - 1 : 0] alu_result;

  // Halt when halt is issued or the datum that is loaded is not yet ready
  assign halt_w = (halt_i | ((id_opcode == LW.opcode) & (mem_data_valid_i == 'b0)));

  // Connect error out
  assign error_o = error_w;

  // Connect Instruction Memory
  assign instr_mem_addr_o = rst_n_i ? next_programm_counter_w : '0;
  assign instr_mem_addr_valid_o = rst_n_i ? ~halt_w : '1;

  // Commpute next programm counter
  assign next_program_counter_regular_w = programm_counter_r + 4;

  //Commpute Jump address
  assign next_program_counter_jmp_w = programm_counter_r + (id_immediate * 2);

  // Next programm counter selector
  assign next_program_counter_sel_w = ((id_opcode == JAL.opcode) & alu_zero) | ((id_opcode == BNE.opcode) & ~alu_zero);

  // Assign next PC value
  assign next_programm_counter_w = next_program_counter_sel_w ? next_program_counter_jmp_w : next_program_counter_regular_w;

  // Programm Counter Process
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      programm_counter_r <= '0;
    end else begin
      if (~halt_w) begin
        programm_counter_r <= next_programm_counter_w;
      end
    end
  end

  // Instruction Decoding Instance
  instruction_decoder instruction_decoder_m ( /* TODO */ );

  // Register File
  // Create data input for RF
  assign rf_data = // TODO

  // Register File Instance
  register_file register_file_m ( /* TODO */ );

  // ALU
  // Create input B for alu
  assign alu_value_b = (id_opcode == ADDI.opcode) ? id_immediate : rf_data_b;

  // ALU Instance
  alu alu_m ( /* TODO */ );

  // write back to memory
  assign mem_write_o = (halt_w | ~rst_n_i) ? '0 : (id_opcode == SW.opcode);
  assign mem_addr_o  = alu_result;
  assign mem_data_o  = rf_data_b;
endmodule
