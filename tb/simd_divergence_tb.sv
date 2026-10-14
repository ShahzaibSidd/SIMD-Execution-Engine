`default_nettype none
`timescale 1ns / 1ps

module simd_divergence_tb;
  logic clk;
  logic reset;

  simd_core dut (
      .clk  (clk),
      .reset(reset)
  );

  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Convenience handle to the lane execution mask for tracing.
  wire [3:0] exec_mask = dut.datapath_inst.exec_mask;

  // Running error count and a helper to check a 4-lane result word.
  integer errors = 0;
  task automatic check_word(input int addr, input int e0, input int e1,
                            input int e2, input int e3);
    automatic int a0 = dut.ram_inst.sram[addr][0];
    automatic int a1 = dut.ram_inst.sram[addr][1];
    automatic int a2 = dut.ram_inst.sram[addr][2];
    automatic int a3 = dut.ram_inst.sram[addr][3];
    if (a0 === e0 && a1 === e1 && a2 === e2 && a3 === e3) begin
      $display("  PASS addr %0d = {%0d,%0d,%0d,%0d}", addr, a0, a1, a2, a3);
    end else begin
      errors = errors + 1;
      $display("  FAIL addr %0d = {%0d,%0d,%0d,%0d}  expected {%0d,%0d,%0d,%0d}",
               addr, a0, a1, a2, a3, e0, e1, e2, e3);
    end
  endtask

  initial begin
    $dumpfile("sim/simd_divergence.vcd");
    $dumpvars(0, simd_divergence_tb);

    reset = 1'b1;

    // ---- Preload input constants (word-addressed data memory) ----
    dut.ram_inst.sram[20][0] = 32'd7;   // A1 = {7,7,7,7}
    dut.ram_inst.sram[20][1] = 32'd7;
    dut.ram_inst.sram[20][2] = 32'd7;
    dut.ram_inst.sram[20][3] = 32'd7;

    dut.ram_inst.sram[21][0] = 32'd7;   // B1 = {7,0,7,0} -> match {0,2}
    dut.ram_inst.sram[21][1] = 32'd0;
    dut.ram_inst.sram[21][2] = 32'd7;
    dut.ram_inst.sram[21][3] = 32'd0;

    dut.ram_inst.sram[22][0] = 32'd100; // IF_VAL = {100,...}
    dut.ram_inst.sram[22][1] = 32'd100;
    dut.ram_inst.sram[22][2] = 32'd100;
    dut.ram_inst.sram[22][3] = 32'd100;

    dut.ram_inst.sram[23][0] = 32'd200; // ELSE_VAL = {200,...}
    dut.ram_inst.sram[23][1] = 32'd200;
    dut.ram_inst.sram[23][2] = 32'd200;
    dut.ram_inst.sram[23][3] = 32'd200;

    dut.ram_inst.sram[24][0] = 32'd9;   // C = {9,9,9,9}
    dut.ram_inst.sram[24][1] = 32'd9;
    dut.ram_inst.sram[24][2] = 32'd9;
    dut.ram_inst.sram[24][3] = 32'd9;

    dut.ram_inst.sram[25][0] = 32'd9;   // D = {9,9,0,0} -> match {0,1}
    dut.ram_inst.sram[25][1] = 32'd9;
    dut.ram_inst.sram[25][2] = 32'd0;
    dut.ram_inst.sram[25][3] = 32'd0;

    dut.ram_inst.sram[26][0] = 32'd5;   // ALLSAME = {5,5,5,5}
    dut.ram_inst.sram[26][1] = 32'd5;
    dut.ram_inst.sram[26][2] = 32'd5;
    dut.ram_inst.sram[26][3] = 32'd5;

    dut.ram_inst.sram[27][0] = 32'd1;   // NONESAME = {1,2,3,4}
    dut.ram_inst.sram[27][1] = 32'd2;
    dut.ram_inst.sram[27][2] = 32'd3;
    dut.ram_inst.sram[27][3] = 32'd4;

    dut.ram_inst.sram[28][0] = 32'd5;   // FIVES = {5,5,5,5}
    dut.ram_inst.sram[28][1] = 32'd5;
    dut.ram_inst.sram[28][2] = 32'd5;
    dut.ram_inst.sram[28][3] = 32'd5;

    dut.ram_inst.sram[29][0] = 32'd55;  // FIFTYFIVES = {55,55,55,55}
    dut.ram_inst.sram[29][1] = 32'd55;
    dut.ram_inst.sram[29][2] = 32'd55;
    dut.ram_inst.sram[29][3] = 32'd55;

    #20;
    @(negedge clk);
    reset = 1'b0;

    // ---- Trace PC and lane mask so divergence is visible ----
    $display("cycle | pc  | instr    | exec_mask");
    for (int c = 0; c < 60; c++) begin
      @(negedge clk);
      $display("%4d  | %3d | %08h | %b", c, dut.pc, dut.instr, exec_mask);
    end

    $display("\n==========================================");
    $display("DIVERGENCE TEST RESULTS");
    $display("==========================================");
    $display("TEST 1 (IF/ELSE, active {0,2}):");
    check_word(40, 100, 200, 100, 200);
    $display("TEST 2 (all lanes match):");
    check_word(41, 100, 100, 100, 100);
    $display("TEST 3 (no lane matches, IF writes nothing):");
    check_word(42, 55, 55, 55, 55);
    $display("TEST 4 (nested VIF):");
    check_word(43, 200, 0, 200, 0);

    $display("\n==========================================");
    if (errors == 0) $display("ALL TESTS PASSED");
    else $display("%0d TEST(S) FAILED", errors);
    $display("==========================================");

    $finish;
  end
endmodule
