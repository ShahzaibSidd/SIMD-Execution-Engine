`default_nettype none
`timescale 1ns / 1ps

module simd_core_tb;

  // 1. Declare Signals
  logic             clk;
  logic             reset;
  logic [3:0][31:0] ext_data_in;

  // 2. Instantiate the CPU
  simd_core dut (.*);

  // 3. Clock Generation (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // 4. The Boot Sequence
  initial begin
    $dumpfile("sim/simd_core.vcd");
    $dumpvars(0, simd_core_tb);

    // Dump internal registers so we can see them in GTKWave
    for (int k = 0; k < 8; k++) begin
      $dumpvars(0, dut.datapath_inst.reg_file_inst.v_reg[k]);
    end

    // --- PHASE 1: SYSTEM RESET ---
    // Turn the reset line ON to clear the Program Counter
    reset       = 1'b1;
    ext_data_in = '0;

    // Hold reset for 20ns to let the silicon stabilize
    #20;

    // --- PHASE 2: BOOT UP ---
    // Release reset on the negative edge. The CPU wakes up and starts fetching!
    @(negedge clk);
    reset          = 1'b0;

    // Cycle 1: PC is 0. ROM outputs VLOAD V1. 
    // We feed the external bus with the data it expects to load.
    ext_data_in[0] = 32'd10;
    ext_data_in[1] = 32'd20;
    ext_data_in[2] = 32'd30;
    ext_data_in[3] = 32'd40;

    // Cycle 2: PC is 4. ROM outputs VLOAD V2.
    // Change the external data bus for the next load.
    @(negedge clk);
    ext_data_in[0] = 32'd5;
    ext_data_in[1] = 32'd5;
    ext_data_in[2] = 32'd5;
    ext_data_in[3] = 32'd5;

    // Cycle 3: PC is 8. ROM outputs VADD V3, V1, V2.
    // Cycle 4: PC is 12. ROM outputs VSUB V4, V3, V2.
    // Since the CPU is doing math, it ignores ext_data_in. We just let it run.
    #50;

    // --- PHASE 3: VERIFY ---
    $display("\n--- AUTONOMOUS EXECUTION COMPLETE ---");
    $display("V1 (Loaded) : %0d, %0d, %0d, %0d", dut.datapath_inst.reg_file_inst.v_reg[1][0],
             dut.datapath_inst.reg_file_inst.v_reg[1][1],
             dut.datapath_inst.reg_file_inst.v_reg[1][2],
             dut.datapath_inst.reg_file_inst.v_reg[1][3]);

    $display("V3 (V1 + V2): %0d, %0d, %0d, %0d", dut.datapath_inst.reg_file_inst.v_reg[3][0],
             dut.datapath_inst.reg_file_inst.v_reg[3][1],
             dut.datapath_inst.reg_file_inst.v_reg[3][2],
             dut.datapath_inst.reg_file_inst.v_reg[3][3]);

    $display("V4 (V3 - V2): %0d, %0d, %0d, %0d", dut.datapath_inst.reg_file_inst.v_reg[4][0],
             dut.datapath_inst.reg_file_inst.v_reg[4][1],
             dut.datapath_inst.reg_file_inst.v_reg[4][2],
             dut.datapath_inst.reg_file_inst.v_reg[4][3]);

    $finish;
  end

endmodule
