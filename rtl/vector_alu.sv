`default_nettype none

module vector_alu (
    input  wire  [3:0][31:0] a,
    input  wire  [3:0][31:0] b,
    input  wire  [1:0]       alu_op,
    output logic [3:0][31:0] result,
    output logic [3:0]       cmp_mask,
    output logic             all_zero
);

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : g_alu_lanes
      alu alu_inst (
          .a(a[i]),
          .b(b[i]),
          .alu_op(alu_op[1:0]),
          .result(result[i])
      );
    end
  endgenerate

  always_comb begin
    cmp_mask = 4'b0000;
    for (int j = 0; j < 4; j = j + 1) begin
      if (result[j] == 32'd0) begin
        cmp_mask[j] = 1'b1;
      end else begin
        cmp_mask[j] = 1'b0;
      end
    end
  end

  // Scalar equality: asserted when every lane's result is zero
  // (i.e. operand A == operand B in all lanes). Used by the branch unit.
  assign all_zero = &cmp_mask;
endmodule
