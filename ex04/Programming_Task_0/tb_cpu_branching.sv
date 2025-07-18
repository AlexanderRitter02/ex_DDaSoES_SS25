import rriscv_pkg::*;

module tb_cpu;

  logic halt_i;
  logic clk_i;
  logic rst_n_i;

  logic [XLEN - 1 : 0] instr_data_i;
  logic [XLEN - 1 : 0] instr_mem_addr_o;
  logic instr_mem_addr_valid_o;

  logic [XLEN - 1 : 0] mem_data_i;
  logic mem_data_valid_i;
  logic mem_write_o;
  logic [XLEN - 1 : 0] mem_data_o;
  logic [XLEN - 1 : 0] mem_addr_o;
  logic error_o;

  cpu i_dut (
      .halt_i                (halt_i),
      .clk_i                 (clk_i),
      .rst_n_i               (rst_n_i),
      .instr_data_i          (instr_data_i),
      .instr_mem_addr_o      (instr_mem_addr_o),
      .instr_mem_addr_valid_o(instr_mem_addr_valid_o),
      .mem_data_i            (mem_data_i),
      .mem_data_valid_i      (mem_data_valid_i),
      .mem_write_o           (mem_write_o),
      .mem_data_o            (mem_data_o),
      .mem_addr_o            (mem_addr_o),
      .error_o               (error_o)
  );

  mem i_data_mem (
      .clk_i         (clk_i),
      .rst_n_i       (rst_n_i),
      .write_enable_i(mem_write_o),
      .data_i        (mem_data_o),
      .addr_i        (mem_addr_o),
      .data_o        (mem_data_i)
  );

  instr_mem i_rom (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .addr_i (instr_mem_addr_o),
      .addr_valid_i(instr_mem_addr_valid_o),
      .data_o (instr_data_i)
  );

  // Clock swap after 10ns -> Period 20ns
  always #(10ns) clk_i = ~clk_i;

  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) begin
      mem_data_valid_i <= 'b0;
    end else begin
      if (instr_data_i[6 : 0] == LW.opcode) begin
        mem_data_valid_i <= 'b1;
      end else begin
        mem_data_valid_i <= 'b0;
      end
    end
  end

  initial begin
    // Initial value
    clk_i   = 0;
    rst_n_i = 0;
    halt_i  = 1;
    #1;

    // Reset design
    rst_n_i = 0;
    halt_i  = 1;
    @(posedge clk_i);

    // Clear Reset before enabling CPU
    @(posedge clk_i);
    rst_n_i = 'b1;

    // Start CPU
    @(posedge clk_i);
    halt_i <= 'b0;
    

    // continue until done (or illegal instruction found)
    while (!error_o) begin
      @(posedge clk_i);
    end

    //--------------------------------------------
    // Assertions für das Testprogramm
    // Wir asserten jeweils nach den Werten, die wir dort reinschreiben (z.B. 10,20) ob Sprung genommen oder nicht)

    // addi x1, x0, 5
    // addi x2, x0, 5
    // bne x1, x2, +8

    // addi x3, x0, 10
    // addi x4, x0, 20

    // addi x10, x0, 7
    // addi x11, x0, 7
    // beq x10, x11, +8 (genommen -> berspring x12, x13)

    // addi x12, x0, 99
    // addi x13, x0, 123
    //--------------------------------------------

   
    assert (i_dut.register_file_m.reg_file[1] == 5)

    assert (i_dut.register_file_m.reg_file[2] == 5)

    // BNE wurde NICHT genommen → x3 und x4 gesetzt
    assert (i_dut.register_file_m.reg_file[3] == 10)

    assert (i_dut.register_file_m.reg_file[4] == 20)

    // Register für BEQ
    assert (i_dut.register_file_m.reg_file[10] == 7)

    assert (i_dut.register_file_m.reg_file[11] == 7)

    // BEQ wurde genommen → x12 und x13 werden übersprungen, bleiben 0
    assert (i_dut.register_file_m.reg_file[12] == 0)

    assert (i_dut.register_file_m.reg_file[13] == 0)

    $finish;
  end
endmodule