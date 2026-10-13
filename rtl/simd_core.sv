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

  logic              ctrl_any_active;
  logic              ctrl_branch;
  logic              ctrl_branch_ne;
  logic              ctrl_cmp_set;
  logic              ctrl_branch_taken;

  logic              ctrl_mem_we;
  logic              ctrl_mem_addr_sel;
  logic [ 1:0]       ctrl_mask_op;

  logic [31:0]       pc;
  logic [31:0]       instr;

  logic [16:0]       imm;

  logic [ 3:0][31:0] mem_to_datapath;
  logic [ 3:0][31:0] datapath_to_mem;
  logic [31:0]       datapath_mem_ptr;

  logic [31:0]       final_mem_addr;

  assign final_mem_addr = ctrl_mem_addr_sel ? datapath_mem_ptr : {15'b0, imm};

  program_counter pc_inst (
      .clk(clk),
      .reset(reset),
      .pc(pc),
      .branch(ctrl_branch),
      .branch_ne(ctrl_branch_ne),
      .imm(imm),
      .branch_taken(ctrl_branch_taken)
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
      .branch_ne(ctrl_branch_ne),
      .imm(imm),
      .cmp_set(ctrl_cmp_set),
      .mem_we(ctrl_mem_we),
      .mem_addr_sel(ctrl_mem_addr_sel),
      .mask_op(ctrl_mask_op)
  );

  simd_datapath datapath_inst (
      .clk(clk),
      .reset(reset),
      .ctrl_we(ctrl_we),
      .rs1(ctrl_rs1),
      .rs2(ctrl_rs2),
      .rd(ctrl_rd),
      .alu_op(ctrl_alu_op),
      .mask_op(ctrl_mask_op),
      .cmp_set(ctrl_cmp_set),
      .mem_data_out(mem_to_datapath),
      .mem_data_in(datapath_to_mem),
      .mem_ptr_out(datapath_mem_ptr),
      .wb_sel(ctrl_wb_sel),
      .any_active(ctrl_any_active),
      .branch_taken(ctrl_branch_taken)
  );

  data_memory ram_inst (
      .clk(clk),
      .we(ctrl_mem_we),
      .address(final_mem_addr),
      .data_in(datapath_to_mem),
      .data_out(mem_to_datapath)
  );

endmodule
