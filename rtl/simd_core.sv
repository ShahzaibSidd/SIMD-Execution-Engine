`default_nettype none

module simd_core (
    input wire             clk,
    input wire             reset,
    input wire [3:0][31:0] ext_data_in
);

  logic        ctrl_we;
  logic [ 2:0] ctrl_rs1;
  logic [ 2:0] ctrl_rs2;
  logic [ 2:0] ctrl_rd;
  logic [ 2:0] ctrl_alu_op;
  logic        ctrl_wb_sel;

  logic [31:0] pc;
  logic [31:0] instr;

  program_counter pc_inst (
      .clk(clk),
      .reset(reset),
      .pc(pc)
  );

  instruction_memory rom_inst (
      .addr (pc),
      .instr(instr)
  );

  instruction_decoder id_inst (
      .instr(instr),
      .we(ctrl_we),
      .rs1(ctrl_rs1),
      .rs2(ctrl_rs2),
      .rd(ctrl_rd),
      .alu_op(ctrl_alu_op),
      .wb_sel(ctrl_wb_sel)
  );

  simd_datapath datapath_inst (
      .clk(clk),
      .we(ctrl_we),
      .rs1(ctrl_rs1),
      .rs2(ctrl_rs2),
      .rd(ctrl_rd),
      .alu_op(ctrl_alu_op),
      .wb_sel(ctrl_wb_sel),
      .ext_data_in(ext_data_in)
  );

endmodule
