`default_nettype none

module vector_alu (
    input  wire  [3:0][31:0] a,
    input  wire  [3:0][31:0] b,
    input  wire  [1:0]       alu_op,
    output logic [3:0][31:0] result
);

  genvar i;
  generate
    for (i = 0; i < 4; i = i + 1) begin : g_alu_lanes
      alu alu_inst (
          .a(a[i]),
          .b(b[i]),
          .alu_op(alu_op),
          .result(result[i])
      );
    end
  endgenerate

endmodule
