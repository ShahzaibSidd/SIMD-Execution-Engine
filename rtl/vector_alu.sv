`default_nettype none

module vector_alu (
    input  wire  [3:0][31:0] a,
    input  wire  [3:0][31:0] b,
    input  wire  [1:0]       alu_op,
    output logic [3:0][31:0] result,
    output logic             is_zero
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
    if (result == 128'd0) begin
      is_zero = 1'b1;
    end else begin
      is_zero = 1'b0;
    end
  end
endmodule
