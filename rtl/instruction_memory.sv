`default_nettype none

module instruction_memory (
    input  wire  [31:0] addr,
    output logic [31:0] instr
);

  logic [31:0] rom[32];

  initial begin
    // 1. VLOAD V1, 0, 0 (Hex: 0x4080_0000)
    rom[0] = 32'b010000_001_000_000_00000000000000000;

    // 2. VLOAD V2, 0, 0 (Hex: 0x4100_0000)
    rom[1] = 32'b010000_010_000_000_00000000000000000;

    // 3. VADD V3, V1, V2 (Hex: 0x04C8_0000)
    rom[2] = 32'b000001_011_001_010_00000000000000000;

    // 4. VSUB V4, V3, V2 (Hex: 0x0908_0000)
    rom[3] = 32'b000010_100_011_010_00000000000000000;

    for (int i = 4; i < 64; i++) begin
      rom[i] = 32'h0000_0000;
    end
  end

  always_comb begin
    logic [29:0] word_index;
    word_index = addr[31:2];

    if (word_index < 64) begin
      instr = rom[word_index];
    end else begin
      instr = 32'd0;
    end
  end

endmodule
