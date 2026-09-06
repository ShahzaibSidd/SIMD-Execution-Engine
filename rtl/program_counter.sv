`default_nettype none

module program_counter (
    input  wire         clk,
    input  wire         reset,
    output logic [31:0] pc
);

always_ff @(posedge clk) begin
  if (reset) begin
    pc <= 32'd0;
  end else begin
    pc <= pc + 32'd4;
  end
end

endmodule

