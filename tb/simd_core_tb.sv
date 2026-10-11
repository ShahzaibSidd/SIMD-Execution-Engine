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

  wire [31:0] v1_lane0 = dut.datapath_inst.reg_file_inst.v_reg[1][0];
  wire [31:0] v1_lane1 = dut.datapath_inst.reg_file_inst.v_reg[1][1];
  wire [31:0] v1_lane2 = dut.datapath_inst.reg_file_inst.v_reg[1][2];
  wire [31:0] v1_lane3 = dut.datapath_inst.reg_file_inst.v_reg[1][3];

  wire [31:0] v2_lane0 = dut.datapath_inst.reg_file_inst.v_reg[2][0];
  wire [31:0] v2_lane1 = dut.datapath_inst.reg_file_inst.v_reg[2][1];
  wire [31:0] v2_lane2 = dut.datapath_inst.reg_file_inst.v_reg[2][2];
  wire [31:0] v2_lane3 = dut.datapath_inst.reg_file_inst.v_reg[2][3];

  wire [31:0] v4_lane0 = dut.datapath_inst.reg_file_inst.v_reg[4][0];
  wire [31:0] v4_lane1 = dut.datapath_inst.reg_file_inst.v_reg[4][1];
  wire [31:0] v4_lane2 = dut.datapath_inst.reg_file_inst.v_reg[4][2];
  wire [31:0] v4_lane3 = dut.datapath_inst.reg_file_inst.v_reg[4][3];

  initial begin
    $dumpfile("sim/simd_core.vcd");
    $dumpvars(0, simd_core_tb);

    // Dump the exact execution mask so we can watch SIMT in action
    $dumpvars(0, dut.datapath_inst.exec_mask);
    $dumpvars(0, dut.datapath_inst.lane_we);

    // Dump Registers and RAM
    for (int k = 1; k <= 4; k++) begin
      $dumpvars(0, dut.datapath_inst.reg_file_inst.v_reg[k]);
    end
    $dumpvars(0, dut.ram_inst.sram[2]);  // Address 32

    $dumpvars(0, v1_lane0);
    $dumpvars(0, v1_lane1);
    $dumpvars(0, v1_lane2);
    $dumpvars(0, v1_lane3);

    $dumpvars(0, v2_lane0);
    $dumpvars(0, v2_lane1);
    $dumpvars(0, v2_lane2);
    $dumpvars(0, v2_lane3);

    $dumpvars(0, v4_lane0);
    $dumpvars(0, v4_lane1);
    $dumpvars(0, v4_lane2);
    $dumpvars(0, v4_lane3);

    $display("\n==========================================");
    $display("BOOTING SIMT GPU CORE");
    $display("==========================================");

    reset                   = 1'b1;

    // Inject V1 (Lane 0 and 2 will be matches)
    dut.ram_inst.sram[0][0] = 32'd10;
    dut.ram_inst.sram[0][1] = 32'd20;
    dut.ram_inst.sram[0][2] = 32'd30;
    dut.ram_inst.sram[0][3] = 32'd40;

    // Inject V2 (Lanes 1 and 3 are different)
    dut.ram_inst.sram[1][0] = 32'd10;
    dut.ram_inst.sram[1][1] = 32'd99;
    dut.ram_inst.sram[1][2] = 32'd30;
    dut.ram_inst.sram[1][3] = 32'd99;

    #20;
    @(negedge clk);
    reset = 1'b0;

    // Give it 10 clock cycles to run the SIMT program
    #100;

    $display("GPU HALTED. Inspecting SRAM Address 32 (Hybrid Vector):");
    $display("Lanes 0/2 should be ADD (10+10=20, 30+30=60)");
    $display("Lanes 1/3 should be SUB (99-20=79, 99-40=59)");
    $display("Expected: 20, 79, 60, 59");
    $display("Actual:   %0d, %0d, %0d, %0d", dut.ram_inst.sram[2][0], dut.ram_inst.sram[2][1],
             dut.ram_inst.sram[2][2], dut.ram_inst.sram[2][3]);

    $finish;
  end

endmodule
