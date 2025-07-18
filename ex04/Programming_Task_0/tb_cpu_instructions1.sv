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

    // Ergebnis-Operationen (add, mul, xor)
    // Wir haben ein Programm geschrieben (in "instr_instructions1.mem"), in dem die Instruktionen auf Registern unabhaengig voneinander getestet werden

    // addi x1, x0, 15
    // addi x2, x0, -16
    // add x3, x1, x2 # -1
    assert ($signed(i_dut.register_file_m.reg_file[3]) == -1)

    // addi x4, x0, 8
    // addi x5, x0, 32
    // mul x6, x4, x5 # 256
    // x6 = x4 * x5 = 8*32 = 256
    assert (i_dut.register_file_m.reg_file[6] == 256)

    // addi x7, x0, 0xFFFFFF08
    // addi x8, x0, 0xEA9
    // xor x9, x7, x8 # 0x1A1
    assert (i_dut.register_file_m.reg_file[9] == 'hFFFFF1A1)

    // # Writing and reading to memory, by testing if the read values are okay
    // sw x3, 0(x0)
    // sw x6, 4(x0)
    // lw x10, 0(x0) # -1
    // lw x11, 4(x0) # 256
    assert ($signed(i_dut.register_file_m.reg_file[10]) == -1)
    assert (i_dut.register_file_m.reg_file[11] == 256)

    $finish;
  end
endmodule
