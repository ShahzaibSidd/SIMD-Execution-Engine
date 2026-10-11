`default_nettype none

module vector_regfile (
    input wire             clk,
    input wire [3:0]       lane_we,
    input wire [2:0]       rs1,
    input wire [2:0]       rs2,
    input wire [2:0]       rd,
    input wire [3:0][31:0] wd,

    output logic [3:0][31:0] rd1_data,
    output logic [3:0][31:0] rd2_data
);

  logic [3:0][31:0] v_reg[8];

  initial begin
    for (int i = 0; i < 8; i = i + 1) begin
      v_reg[i] = '0;
    end
  end

  always_ff @(posedge clk) begin
    for (int i = 0; i < 4; i = i + 1) begin
      if (lane_we[i]) v_reg[rd][i] <= wd[i];
    end
  end

  always_comb begin
    rd1_data = v_reg[rs1];
    rd2_data = v_reg[rs2];
  end

endmodule
