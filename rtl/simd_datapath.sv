`default_nettype none

module simd_datapath (
    input wire       clk,
    input wire       reset,
    input wire       ctrl_we,
    input wire [2:0] rs1,
    input wire [2:0] rs2,
    input wire [2:0] rd,
    input wire [1:0] alu_op,

    input wire [1:0] mask_op,

    input wire wb_sel,

    input  wire  [3:0][31:0] mem_data_out,  // data coming from sram
    output logic [3:0][31:0] mem_data_in    // data going to sram

);

  logic [3:0][31:0] alu_in_a;
  logic [3:0][31:0] alu_in_b;
  logic [3:0][31:0] alu_out;
  logic [3:0][31:0] write_back_data;
  logic [3:0]       cmp_mask;

  assign mem_data_in = alu_in_a;

  logic [3:0] exec_mask;
  logic [3:0] mask_stack[4];
  logic [1:0] sp;
  logic [3:0] lane_we;

  always_comb begin
    for (int i = 0; i < 4; i = i + 1) begin
      lane_we[i] = ctrl_we & exec_mask[i];
    end
  end

  always_ff @(posedge clk) begin
    if (reset) begin
      exec_mask <= 4'b1111;
      sp        <= 2'b00;
    end else begin
      case (mask_op)
        // 01: PUSH (Start of an IF block)
        2'b01: begin
          mask_stack[sp] <= exec_mask;
          sp             <= sp + 1'b1;
          exec_mask      <= exec_mask & cmp_mask;
        end

        // 10: INV (The ELSE block)
        2'b10: begin
          // Flip the bits, but only within the bounds of the parent scope
          exec_mask <= mask_stack[sp-1'b1] ^ exec_mask;
        end

        // 11: POP (End of IF/ELSE block)
        2'b11: begin
          sp        <= sp - 1'b1;
          exec_mask <= mask_stack[sp-1'b1];  // Restore the parent mask
        end

        // 00: NOP (Normal math execution, keep current mask)
        default: ;
      endcase
    end
  end

  always_comb begin
    if (wb_sel) begin
      write_back_data = mem_data_out;
    end else begin
      write_back_data = alu_out;
    end
  end

  vector_regfile reg_file_inst (
      .clk(clk),
      .lane_we(lane_we),
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
      .cmp_mask(cmp_mask)
  );

endmodule
