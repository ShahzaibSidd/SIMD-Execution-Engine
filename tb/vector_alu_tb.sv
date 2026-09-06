`timescale 1ns / 1ps

module vector_alu_tb;
  logic [3:0][31:0] a;
  logic [3:0][31:0] b;
  logic [1:0]       alu_op;
  logic [3:0][31:0] result;

  vector_alu dut (.*);

  initial begin
    int i, j;
    int          error_count = 0;
    logic [31:0] expected;

    $dumpfile("sim/vector_alu.vcd");
    $dumpvars(0, vector_alu_tb);

    error_count = 0;
    a           = 0;
    b           = 0;
    alu_op      = 0;

    #10;

    $display("Start loop test");

    for (i = 0; i < 100; i++) begin
      for (j = 0; j < 4; j++) begin
        a[j] = $urandom();
        b[j] = $urandom();
      end

      alu_op = $urandom_range(0, 3);
      #1;

      for (j = 0; j < 4; j++) begin
        case (alu_op)
          2'b00:   expected = a[j] + b[j];
          2'b01:   expected = a[j] - b[j];
          2'b10:   expected = a[j] & b[j];
          2'b11:   expected = a[j] | b[j];
          default: expected = 0;
        endcase

        if (result[j] !== expected) begin
          $error("FAIL: vector %0d, lane %0d, op %0d: expected %0h (Hardware returned %0h)", i, j,
                 alu_op, expected, result[j]);
          error_count++;
        end
      end

      #9;
    end


    if (error_count == 0) $display("SUCCESS: 400 parallel ALU operations verified!");
    else $display("FAILED with %0d errors.", error_count);

    $finish;
  end

endmodule
