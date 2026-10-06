`default_nettype none

module simd_datapath (
    input wire       clk,
    input wire       we,
    input wire [2:0] rs1,
    input wire [2:0] rs2,
    input wire [2:0] rd,
    input wire [1:0] alu_op,

    input wire wb_sel,

    input  wire  [3:0][31:0] mem_data_out,  // data coming from sram
    output logic [3:0][31:0] mem_data_in,   // data going to sram

    output logic is_zero
);

  logic [3:0][31:0] alu_in_a;
  logic [3:0][31:0] alu_in_b;
  logic [3:0][31:0] alu_out;
  logic [3:0][31:0] write_back_data;

  assign mem_data_in = alu_in_a;

  always_comb begin
    if (wb_sel) begin
      write_back_data = mem_data_out;
    end else begin
      write_back_data = alu_out;
    end
  end

  vector_regfile reg_file_inst (
      .clk(clk),
      .we(we),
      .rs1(rs1),
      .rs2(rs2),
      .rd(rd),
      .wd(write_back_data),
      .rd1_data(alu_in_a),
      .rd2_data(alu_in_b)
  );

  vector_alu alu_inst (
      .a(alu_in_a),
      .b(alu_in_b),
      .alu_op(alu_op),
      .result(alu_out),
      .is_zero(is_zero)
  );

endmodule
