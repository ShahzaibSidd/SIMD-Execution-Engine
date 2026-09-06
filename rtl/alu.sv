`default_nettype none

module alu (
    input  wire  [31:0] a,
    input  wire  [31:0] b,
    input  wire  [ 1:0] alu_op,
    output logic [31:0] result
);

  localparam logic [1:0] OP_ADD = 2'b00;
  localparam logic [1:0] OP_SUB = 2'b01;
  localparam logic [1:0] OP_AND = 2'b10;
  localparam logic [1:0] OP_OR  = 2'b11;

  always_comb begin
    case (alu_op)
      OP_ADD:  result = a + b;
      OP_SUB:  result = a - b;
      OP_AND:  result = a & b;
      OP_OR:   result = a | b;
      default: result = 32'd0;
    endcase
  end

endmodule
