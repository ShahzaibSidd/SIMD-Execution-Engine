`default_nettype none

module program_counter (
    input wire clk,
    input wire reset,

    input wire        branch,
    input wire        branch_ne,
    input wire [16:0] imm,
    input wire        branch_taken,

    output logic [31:0] pc
);

  logic [31:0] extended_imm;
  logic        take_branch;
  assign extended_imm = {{15{imm[16]}}, imm};

  // BEQ branches when the flag is set (equal); BNE when it is clear.
  assign take_branch  = branch & (branch_ne ? ~branch_taken : branch_taken);

  always_ff @(posedge clk) begin
    if (reset) begin
      pc <= 32'd0;
    end else begin
      if (take_branch) begin
        pc <= pc + extended_imm;
      end else begin
        pc <= pc + 32'd4;
      end
    end
  end

endmodule

