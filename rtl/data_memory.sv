`default_nettype none

module data_memory (
    input  wire               clk,
    input  wire               we,
    input  wire  [31:0]       address,
    input  wire  [ 3:0][31:0] data_in,
    output logic [ 3:0][31:0] data_out
);

  logic [ 3:0][31:0] sram       [256];
  logic [27:0]       word_index;

  assign word_index = address[31:4];

  initial begin
    for (int i = 0; i < 256; i++) begin
      sram[i] = '0;
    end
  end

  // synchronous writes on clock pos edge
  always_ff @(posedge clk) begin
    if (we && (word_index < 256)) begin
      sram[word_index] <= data_in;
    end
  end

  // asynchronous reads
  always_comb begin
    if (word_index < 256) begin
      data_out = sram[word_index];
    end else begin
      data_out = '0;
    end
  end

endmodule
