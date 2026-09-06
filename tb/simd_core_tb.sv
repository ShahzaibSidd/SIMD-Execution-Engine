`default_nettype none
`timescale 1ns / 1ps

module simd_core_tb;

  logic             clk;
  logic             reset;
  logic [3:0][31:0] ext_data_in;

  simd_core dut (
      .clk(clk),
      .reset(reset),
      .ext_data_in(ext_data_in)
  );

  // 100 MHz clock (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("sim/simd_core.vcd");
    $dumpvars(0, simd_core_tb);

    // Dump register file values for GTKWave inspection
    for (int k = 0; k < 8; k++) begin
      $dumpvars(0, dut.datapath_inst.reg_file_inst.v_reg[k]);
    end

    // =========================================================================
    // TEST CASE 1: BRANCH TAKEN (V1 == V2)
    // =========================================================================
    $display("\n==========================================");
    $display("TEST 1: Branch Taken (V1 == V2)");
    $display("==========================================");

    reset       = 1'b1;
    ext_data_in = '0;
    #20;

    @(negedge clk);
    reset          = 1'b0;

    // Cycle 0 (PC = 0): Load V1 with {10, 20, 30, 40}
    ext_data_in[0] = 32'd10;
    ext_data_in[1] = 32'd20;
    ext_data_in[2] = 32'd30;
    ext_data_in[3] = 32'd40;

    // Cycle 1 (PC = 4): Load V2 with {10, 20, 30, 40} (EQUAL to V1)
    @(negedge clk);
    ext_data_in[0] = 32'd10;
    ext_data_in[1] = 32'd20;
    ext_data_in[2] = 32'd30;
    ext_data_in[3] = 32'd40;

    // Cycle 2 (PC = 8): BEQ evaluates V1 - V2 == 0 -> is_zero should be 1
    @(negedge clk);
    ext_data_in = '0;

    // Wait a few cycles for branch execution and landing
    #40;

    $display("Test 1 Inspection:");
    $display("V3 (Add Result at PC=12) Expected: 0, 0, 0, 0 (SKIPPED)");
    $display("V3 Actual: %0d, %0d, %0d, %0d", dut.datapath_inst.reg_file_inst.v_reg[3][0],
             dut.datapath_inst.reg_file_inst.v_reg[3][1],
             dut.datapath_inst.reg_file_inst.v_reg[3][2],
             dut.datapath_inst.reg_file_inst.v_reg[3][3]);

    $display("V4 (Sub Result at PC=20) Expected: 0, 0, 0, 0 (EXECUTED)");
    $display("V4 Actual: %0d, %0d, %0d, %0d", dut.datapath_inst.reg_file_inst.v_reg[4][0],
             dut.datapath_inst.reg_file_inst.v_reg[4][1],
             dut.datapath_inst.reg_file_inst.v_reg[4][2],
             dut.datapath_inst.reg_file_inst.v_reg[4][3]);

    // =========================================================================
    // TEST CASE 2: BRANCH NOT TAKEN (V1 != V2)
    // =========================================================================
    $display("\n==========================================");
    $display("TEST 2: Branch Not Taken (V1 != V2)");
    $display("==========================================");

    @(negedge clk);
    reset = 1'b1;
    #20;

    @(negedge clk);
    reset          = 1'b0;

    // Cycle 0 (PC = 0): Load V1 with {10, 20, 30, 40}
    ext_data_in[0] = 32'd10;
    ext_data_in[1] = 32'd20;
    ext_data_in[2] = 32'd30;
    ext_data_in[3] = 32'd40;

    // Cycle 1 (PC = 4): Load V2 with {5, 5, 5, 5} (NOT EQUAL to V1)
    @(negedge clk);
    ext_data_in[0] = 32'd5;
    ext_data_in[1] = 32'd5;
    ext_data_in[2] = 32'd5;
    ext_data_in[3] = 32'd5;

    // Cycle 2 (PC = 8): BEQ evaluates V1 - V2 != 0 -> is_zero should be 0
    @(negedge clk);
    ext_data_in = '0;

    #40;

    $display("Test 2 Inspection:");
    $display("V3 (Add Result at PC=12) Expected: 15, 25, 35, 45 (EXECUTED)");
    $display("V3 Actual: %0d, %0d, %0d, %0d", dut.datapath_inst.reg_file_inst.v_reg[3][0],
             dut.datapath_inst.reg_file_inst.v_reg[3][1],
             dut.datapath_inst.reg_file_inst.v_reg[3][2],
             dut.datapath_inst.reg_file_inst.v_reg[3][3]);

    $finish;
  end

endmodule
