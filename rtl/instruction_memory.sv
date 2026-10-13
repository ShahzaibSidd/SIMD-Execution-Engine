`default_nettype none

module instruction_memory (
    input  wire  [31:0] addr,
    output logic [31:0] instr
);

  logic [31:0] rom[64];

  initial begin
    $readmemh("software/program.hex", rom);
  end

  always_comb begin
    logic [29:0] word_index;
    word_index = addr[31:2];
    if (word_index < 64) begin
      instr = rom[word_index];
    end else begin
      instr = 32'h0000_0000;
    end
  end

endmodule
