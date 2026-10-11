`default_nettype none

module simd_core (
    input wire clk,
    input wire reset
);

  logic              ctrl_we;
  logic [ 2:0]       ctrl_rs1;
  logic [ 2:0]       ctrl_rs2;
  logic [ 2:0]       ctrl_rd;
  logic [ 1:0]       ctrl_alu_op;
  logic              ctrl_wb_sel;

  logic              ctrl_is_zero;
  logic              ctrl_branch;

  logic              ctrl_mem_we;
  logic [ 1:0]       ctrl_mask_op;

  logic [31:0]       pc;
  logic [31:0]       instr;

  logic [16:0]       imm;

  logic [ 3:0][31:0] mem_to_datapath;
  logic [ 3:0][31:0] datapath_to_mem;

  program_counter pc_inst (
      .clk(clk),
      .reset(reset),
      .pc(pc),
      .branch(ctrl_branch),
      .imm(imm),
      .is_zero(ctrl_is_zero)
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
      .wb_sel(ctrl_wb_sel),
      .branch(ctrl_branch),
      .imm(imm),
      .mem_we(ctrl_mem_we),
      .mask_op(ctrl_mask_op)
  );

  simd_datapath datapath_inst (
      .clk(clk),
      .reset(reset),
      .we(ctrl_we),
      .rs1(ctrl_rs1),
      .rs2(ctrl_rs2),
      .rd(ctrl_rd),
      .alu_op(ctrl_alu_op),
      .mask_op(ctrl_mask_op),
      .mem_data_out(mem_to_datapath),
      .mem_data_in(datapath_to_mem),
      .wb_sel(ctrl_wb_sel),
      .is_zero(ctrl_is_zero)
  );

  data_memory ram_inst (
      .clk(clk),
      .we(ctrl_mem_we),
      .address({15'b0, imm}),
      .data_in(datapath_to_mem),
      .data_out(mem_to_datapath)
  );

endmodule
