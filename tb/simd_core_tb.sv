`default_nettype none
`timescale 1ns / 1ps

module simd_core_tb;
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

  initial begin
    $dumpfile("sim/simd_core.vcd");
    $dumpvars(0, simd_core_tb);

    reset                     = 1'b1;

    // --- 1. INJECT SETUP CONSTANTS ---
    // Addr 100: The Scalar Multiplier (Scale matrix by 2)
    dut.ram_inst.sram[100][0] = 32'd2;
    dut.ram_inst.sram[100][1] = 32'd2;
    dut.ram_inst.sram[100][2] = 32'd2;
    dut.ram_inst.sram[100][3] = 32'd2;

    // Addr 101: Pointer Increment (Adds 1 to Lane 0)
    dut.ram_inst.sram[101][0] = 32'd1;
    dut.ram_inst.sram[101][1] = 32'd0;
    dut.ram_inst.sram[101][2] = 32'd0;
    dut.ram_inst.sram[101][3] = 32'd0;

    // Addr 102: Loop Boundary (Stop at Address 4)
    dut.ram_inst.sram[102][0] = 32'd4;
    dut.ram_inst.sram[102][1] = 32'd0;
    dut.ram_inst.sram[102][2] = 32'd0;
    dut.ram_inst.sram[102][3] = 32'd0;

    // --- 2. INJECT 4x4 MATRIX DATA ---
    // Row 0 (Address 0)
    dut.ram_inst.sram[0][0]   = 32'd1;
    dut.ram_inst.sram[0][1]   = 32'd2;
    dut.ram_inst.sram[0][2]   = 32'd3;
    dut.ram_inst.sram[0][3]   = 32'd4;

    // Row 1 (Address 1)
    dut.ram_inst.sram[1][0]   = 32'd5;
    dut.ram_inst.sram[1][1]   = 32'd6;
    dut.ram_inst.sram[1][2]   = 32'd7;
    dut.ram_inst.sram[1][3]   = 32'd8;

    // Row 2 (Address 2)
    dut.ram_inst.sram[2][0]   = 32'd9;
    dut.ram_inst.sram[2][1]   = 32'd10;
    dut.ram_inst.sram[2][2]   = 32'd11;
    dut.ram_inst.sram[2][3]   = 32'd12;

    // Row 3 (Address 3)
    dut.ram_inst.sram[3][0]   = 32'd13;
    dut.ram_inst.sram[3][1]   = 32'd14;
    dut.ram_inst.sram[3][2]   = 32'd15;
    dut.ram_inst.sram[3][3]   = 32'd16;

    #20;
    @(negedge clk);
    reset = 1'b0;

    // Let the GPU stream process the matrix for 300 clock cycles.
    #300;

    $display("\n==========================================");
    $display("MATRIX PROCESSING COMPLETE");
    $display("==========================================");

    for (int i = 0; i < 4; i++) begin
      $display("Row %0d | %0d, %0d, %0d, %0d", i, dut.ram_inst.sram[i][0], dut.ram_inst.sram[i][1],
               dut.ram_inst.sram[i][2], dut.ram_inst.sram[i][3]);
    end

    $finish;
  end
endmodule
