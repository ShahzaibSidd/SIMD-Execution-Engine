`default_nettype none

module program_counter (
    input wire clk,
    input wire reset,

    input wire        branch,
    input wire [16:0] imm,
    input wire        is_zero,

    output logic [31:0] pc
);

  logic [31:0] extended_imm;
  assign extended_imm = {{15{imm[16]}}, imm};

  always_ff @(posedge clk) begin
    if (reset) begin
      pc <= 32'd0;
    end else begin
      if (branch && is_zero) begin
        pc <= pc + extended_imm;
      end else begin
        pc <= pc + 32'd4;
      end
    end
  end

endmodule

