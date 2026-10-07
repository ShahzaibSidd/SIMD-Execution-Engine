`default_nettype none
`timescale 1ns / 1ps

module simd_core_tb;

  logic clk;
  logic reset;

  // The fully self-contained CPU
  simd_core dut (
      .clk  (clk),
      .reset(reset)
  );

  // 100 MHz clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $dumpfile("sim/simd_core.vcd");
    $dumpvars(0, simd_core_tb);

    // Dump register file and SRAM memory slots for inspection
    for (int k = 0; k < 8; k++) begin
      $dumpvars(0, dut.datapath_inst.reg_file_inst.v_reg[k]);
    end
    $dumpvars(0, dut.ram_inst.sram[0]);
    $dumpvars(0, dut.ram_inst.sram[1]);
    $dumpvars(0, dut.ram_inst.sram[2]);  // This is Address 32

    $display("\n==========================================");
    $display("BOOTING SIMD MICROPROCESSOR");
    $display("==========================================");

    // 1. Hold reset high
    reset                   = 1'b1;

    // 2. Pre-load the Data RAM (Simulating a Bootloader)
    // sram[0] corresponds to address 0
    dut.ram_inst.sram[0][0] = 32'd10;
    dut.ram_inst.sram[0][1] = 32'd20;
    dut.ram_inst.sram[0][2] = 32'd30;
    dut.ram_inst.sram[0][3] = 32'd40;

    // sram[1] corresponds to address 16
    dut.ram_inst.sram[1][0] = 32'd5;
    dut.ram_inst.sram[1][1] = 32'd5;
    dut.ram_inst.sram[1][2] = 32'd5;
    dut.ram_inst.sram[1][3] = 32'd5;

    #20;

    // 3. Release reset. The CPU is now completely autonomous.
    @(negedge clk);
    reset = 1'b0;

    // 4. Give the CPU exactly 6 clock cycles to run the 5-instruction program
    #60;

    $display("CPU HALTED. Inspecting SRAM Address 32 (sram[2]):");
    $display("Expected: 15, 25, 35, 45");
    $display("Actual:   %0d, %0d, %0d, %0d", dut.ram_inst.sram[2][0], dut.ram_inst.sram[2][1],
             dut.ram_inst.sram[2][2], dut.ram_inst.sram[2][3]);

    $finish;
  end

endmodule
