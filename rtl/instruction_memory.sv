`default_nettype none

module instruction_memory (
    input  wire  [31:0] addr,
    output logic [31:0] instr
);

  logic [31:0] rom[64];

  initial begin
    // [0] PC = 0: VLOAD V1, Addr 0
    rom[0] = {6'b010000, 3'd1, 3'd0, 3'd0, 17'd0};

    // [1] PC = 4: VLOAD V2, Addr 16
    rom[1] = {6'b010000, 3'd2, 3'd0, 3'd0, 17'd16};

    // [2] PC = 8: VADD V3, V1, V2
    rom[2] = {6'b000001, 3'd3, 3'd1, 3'd2, 17'd0};

    // [3] PC = 12: VSTR V3, Addr 32 (Source data is in rs1)
    rom[3] = {6'b010001, 3'd0, 3'd3, 3'd0, 17'd32};

    // [4] PC = 16: BEQ V1, V1, +0 (Infinite loop / Halt)
    rom[4] = {6'b110000, 3'd0, 3'd1, 3'd1, 17'd0};

    // Pad remaining slots
    for (int i = 5; i < 64; i++) begin
      rom[i] = 32'h0000_0000;
    end
  end

  logic [29:0] word_index;
  assign word_index = addr[31:2];

  always_comb begin
    if (word_index < 64) begin
      instr = rom[word_index];
    end else begin
      instr = 32'h0000_0000;
    end
  end

endmodule
