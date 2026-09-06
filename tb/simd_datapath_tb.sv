`default_nettype none
`timescale 1ns / 1ps

module simd_datapath_tb;

  logic       clk;
  logic       we;
  logic [2:0] rs1;
  logic [2:0] rs2;
  logic [2:0] rd;
  logic [1:0] alu_op;

  simd_datapath dut (.*);

  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Toggle clock every 5ns
  end

  initial begin
    $dumpfile("sim/simd_datapath.vcd");
    $dumpvars(0, simd_datapath_tb);

    // Explicitly force the simulator to dump the unpacked memory array
    for (int k = 0; k < 8; k++) begin
      $dumpvars(0, dut.reg_file_inst.v_reg[k]);
    end

    we     = 0;
    rs1    = 0;
    rs2    = 0;
    rd     = 0;
    alu_op = 0;

    #10;

    // Injecting values directly into the physical registers V1 and V2
    dut.reg_file_inst.v_reg[1][0] = 32'h0000_0001;  // V1, Lane 0
    dut.reg_file_inst.v_reg[1][1] = 32'h0000_0002;  // V1, Lane 1
    dut.reg_file_inst.v_reg[1][2] = 32'h0000_0003;  // V1, Lane 2
    dut.reg_file_inst.v_reg[1][3] = 32'h0000_0004;  // V1, Lane 3

    dut.reg_file_inst.v_reg[2][0] = 32'h0000_0010;  // V2, Lane 0
    dut.reg_file_inst.v_reg[2][1] = 32'h0000_0020;  // V2, Lane 1
    dut.reg_file_inst.v_reg[2][2] = 32'h0000_0030;  // V2, Lane 2
    dut.reg_file_inst.v_reg[2][3] = 32'h0000_0040;  // V2, Lane 3

    $display("Pre-Execution: V1 and V2 successfully loaded via backdoor.");

    // --- EXECUTE: VADD V3, V1, V2 ---
    @(negedge clk);
    rs1    = 3'd1;  // Read from V1
    rs2    = 3'd2;  // Read from V2
    rd     = 3'd3;  // Write to V3
    alu_op = 2'b00;  // Opcode: ADD
    we     = 1'b1;  // Enable Write

    // Wait exactly one clock cycle for the data to process and save
    @(negedge clk);
    we = 1'b0;  // Turn off write enable so we don't accidentally overwrite data

    // --- VERIFY RESULTS ---
    $display("Execution Complete. Inspecting V3...");
    $display("Lane 0: %0h (Expected: 11)", dut.reg_file_inst.v_reg[3][0]);
    $display("Lane 1: %0h (Expected: 22)", dut.reg_file_inst.v_reg[3][1]);
    $display("Lane 2: %0h (Expected: 33)", dut.reg_file_inst.v_reg[3][2]);
    $display("Lane 3: %0h (Expected: 44)", dut.reg_file_inst.v_reg[3][3]);

    $finish;
  end

endmodule
