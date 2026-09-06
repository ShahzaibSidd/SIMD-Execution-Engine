`default_nettype none

module instruction_memory (
    input  wire  [31:0] addr,
    output logic [31:0] instr
);

  logic [31:0] rom[64];

  initial begin
    // Bit layout: {opcode[5:0], rd[2:0], rs1[2:0], rs2[2:0], imm[16:0]}
    // Opcodes: VADD=000001, VSUB=000010, VLOAD=010000, BEQ=110000

    // [0] PC = 0: VLOAD V1
    rom[0] = {6'b010000, 3'd1, 3'd0, 3'd0, 17'd0};

    // [1] PC = 4: VLOAD V2
    rom[1] = {6'b010000, 3'd2, 3'd0, 3'd0, 17'd0};

    // [2] PC = 8: BEQ V1, V2, +12 bytes
    // If V1 == V2, Next PC = 8 + 12 = 20 (rom index 5)
    rom[2] = {6'b110000, 3'd0, 3'd1, 3'd2, 17'd12};

    // [3] PC = 12: VADD V3, V1, V2 (SKIPPED if branch is taken)
    rom[3] = {6'b000001, 3'd3, 3'd1, 3'd2, 17'd0};

    // [4] PC = 16: NOP
    rom[4] = 32'h0000_0000;

    // [5] PC = 20: VSUB V4, V1, V2 (BRANCH TARGET)
    rom[5] = {6'b000010, 3'd4, 3'd1, 3'd2, 17'd0};

    // Pad remaining slots with NOPs
    for (int i = 6; i < 64; i++) begin
      rom[i] = 32'h0000_0000;
    end
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
