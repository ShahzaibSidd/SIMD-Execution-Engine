`default_nettype none
`timescale 1ns / 1ps

// Portfolio showcase testbench: V1 vs V2 compare drives a two-branch
// divergence that applies two different ops to the accumulator V3, run
// twice. Every vector lane of V1, V2 and V3 is exposed so the full warp
// state is visible in GTKWave.
module simd_showcase_tb;
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

  // ---- Control / SIMT state ----
  wire [31:0] pc        = dut.pc;
  wire [31:0] instr     = dut.instr;
  wire [ 3:0] exec_mask = dut.datapath_inst.exec_mask;  // the divergence mask
  wire [ 1:0] stack_ptr = dut.datapath_inst.sp;         // divergence depth

  // ---- ALL vector lanes exposed (operands V1, V2 and accumulator V3) ----
  wire [31:0] v1_lane0 = dut.datapath_inst.reg_file_inst.v_reg[1][0];
  wire [31:0] v1_lane1 = dut.datapath_inst.reg_file_inst.v_reg[1][1];
  wire [31:0] v1_lane2 = dut.datapath_inst.reg_file_inst.v_reg[1][2];
  wire [31:0] v1_lane3 = dut.datapath_inst.reg_file_inst.v_reg[1][3];

  wire [31:0] v2_lane0 = dut.datapath_inst.reg_file_inst.v_reg[2][0];
  wire [31:0] v2_lane1 = dut.datapath_inst.reg_file_inst.v_reg[2][1];
  wire [31:0] v2_lane2 = dut.datapath_inst.reg_file_inst.v_reg[2][2];
  wire [31:0] v2_lane3 = dut.datapath_inst.reg_file_inst.v_reg[2][3];

  wire [31:0] v3_lane0 = dut.datapath_inst.reg_file_inst.v_reg[3][0];
  wire [31:0] v3_lane1 = dut.datapath_inst.reg_file_inst.v_reg[3][1];
  wire [31:0] v3_lane2 = dut.datapath_inst.reg_file_inst.v_reg[3][2];
  wire [31:0] v3_lane3 = dut.datapath_inst.reg_file_inst.v_reg[3][3];

  integer errors = 0;
  task automatic check_word(input int addr, input int e0, input int e1,
                            input int e2, input int e3);
    automatic int a0 = dut.ram_inst.sram[addr][0];
    automatic int a1 = dut.ram_inst.sram[addr][1];
    automatic int a2 = dut.ram_inst.sram[addr][2];
    automatic int a3 = dut.ram_inst.sram[addr][3];
    if (a0 === e0 && a1 === e1 && a2 === e2 && a3 === e3)
      $display("  PASS addr %0d = {%0d,%0d,%0d,%0d}", addr, a0, a1, a2, a3);
    else begin
      errors = errors + 1;
      $display("  FAIL addr %0d = {%0d,%0d,%0d,%0d}  expected {%0d,%0d,%0d,%0d}",
               addr, a0, a1, a2, a3, e0, e1, e2, e3);
    end
  endtask

  initial begin
    $dumpfile("sim/simd_showcase.vcd");
    $dumpvars(0, simd_showcase_tb);

    reset = 1'b1;

    // ---- Operands / accumulator init ----
    dut.ram_inst.sram[10][0] = 32'd5;  // V1 = {5,5,9,9}
    dut.ram_inst.sram[10][1] = 32'd5;
    dut.ram_inst.sram[10][2] = 32'd9;
    dut.ram_inst.sram[10][3] = 32'd9;

    dut.ram_inst.sram[11][0] = 32'd5;  // V2 = {5,0,9,0} -> V1==V2 in {0,2}
    dut.ram_inst.sram[11][1] = 32'd0;
    dut.ram_inst.sram[11][2] = 32'd9;
    dut.ram_inst.sram[11][3] = 32'd0;

    dut.ram_inst.sram[12][0] = 32'd10; // V3 = {10,10,10,10}
    dut.ram_inst.sram[12][1] = 32'd10;
    dut.ram_inst.sram[12][2] = 32'd10;
    dut.ram_inst.sram[12][3] = 32'd10;

    #20;
    @(negedge clk);
    reset = 1'b0;

    // Enough time for both rounds plus halt.
    #400;

    $display("\n==========================================");
    $display("COMPARE-AND-DIVERGE  --  RESULTS");
    $display("==========================================");
    // IF lanes {0,2}: V3 += V1 ;  ELSE lanes {1,3}: V3 *= V1
    // Round 1 from V3={10,10,10,10}:
    //   lane0: 10+5=15  lane1: 10*5=50  lane2: 10+9=19  lane3: 10*9=90
    $display("Round 1 (IF: +V1 on {0,2}, ELSE: *V1 on {1,3}):");
    check_word(20, 15, 50, 19, 90);
    // Round 2 from V3={15,50,19,90}:
    //   lane0: 15+5=20  lane1: 50*5=250 lane2: 19+9=28  lane3: 90*9=810
    $display("Round 2 (same compare, applied again):");
    check_word(21, 20, 250, 28, 810);

    $display("\n==========================================");
    if (errors == 0) $display("ALL RESULTS CORRECT");
    else $display("%0d MISMATCH(ES)", errors);
    $display("==========================================");

    $finish;
  end
endmodule
