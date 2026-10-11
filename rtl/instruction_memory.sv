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

    // [2] PC = 8: VCMP V1, V2 (Pushes mask to stack!)
    rom[2] = {6'b100000, 3'd0, 3'd1, 3'd2, 17'd0};

    // [3] PC = 12: VADD V4, V1, V2 (IF BLOCK - Only matching lanes write to V4)
    rom[3] = {6'b000001, 3'd4, 3'd1, 3'd2, 17'd0};

    // [4] PC = 16: VINV (ELSE - Inverts the active mask)
    rom[4] = {6'b100001, 3'd0, 3'd0, 3'd0, 17'd0};

    // [5] PC = 20: VSUB V4, V2, V1 (ELSE BLOCK - Only failing lanes write to V4)
    rom[5] = {6'b000010, 3'd4, 3'd2, 3'd1, 17'd0};

    // [6] PC = 24: VPOP (END IF - Restores all lanes to awake)
    rom[6] = {6'b100010, 3'd0, 3'd0, 3'd0, 17'd0};

    // [7] PC = 28: VSTR V4, Addr 32 (Store the hybrid result)
    rom[7] = {6'b010001, 3'd0, 3'd4, 3'd0, 17'd32};

    // [8] PC = 32: BEQ V0, V0, +0 (Halt loop)
    rom[8] = {6'b110000, 3'd0, 3'd0, 3'd0, 17'd0};

    for (int i = 9; i < 64; i++) begin
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
