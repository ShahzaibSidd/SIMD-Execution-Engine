`default_nettype none

module instruction_decoder (
    input wire [31:0] instr,

    // datapath control
    output logic       we,
    output logic [2:0] rs1,
    output logic [2:0] rs2,
    output logic [2:0] rd,
    output logic [1:0] alu_op,
    output logic       wb_sel,

    // branch control
    output logic        branch,
    output logic [16:0] imm,

    // sram memory control
    output logic mem_we,

    // simt mask control
    output logic [1:0] mask_op
);

  localparam logic [5:0] OPC_VADD  = 6'b000001;
  localparam logic [5:0] OPC_VSUB  = 6'b000010;
  localparam logic [5:0] OPC_VAND  = 6'b000100;
  localparam logic [5:0] OPC_VOR   = 6'b001000;

  localparam logic [5:0] OPC_VLOAD = 6'b010000;
  localparam logic [5:0] OPC_VSTR  = 6'b010001;
  localparam logic [5:0] OPC_BEQ   = 6'b110000;

  localparam logic [5:0] OPC_VCMP  = 6'b100000;
  localparam logic [5:0] OPC_VINV  = 6'b100001;
  localparam logic [5:0] OPC_VPOP  = 6'b100010;


  logic [5:0] opcode;

  assign opcode = instr[31:26];
  assign rd     = instr[25:23];
  assign rs1    = instr[22:20];
  assign rs2    = instr[19:17];
  assign imm    = instr[16:0];

  always_comb begin
    we      = 1'b0;
    wb_sel  = 1'b0;
    alu_op  = 2'b00;
    branch  = 1'b0;
    mem_we  = 1'b0;
    mask_op = 2'b00;

    case (opcode)
      OPC_VADD: begin
        we     = 1'b1;
        wb_sel = 1'b0;
        alu_op = 2'b00;
      end
      OPC_VSUB: begin
        we     = 1'b1;
        wb_sel = 1'b0;
        alu_op = 2'b01;
      end
      OPC_VAND: begin
        we     = 1'b1;
        wb_sel = 1'b0;
        alu_op = 2'b10;
      end
      OPC_VOR: begin
        we     = 1'b1;
        wb_sel = 1'b0;
        alu_op = 2'b11;
      end
      OPC_VLOAD: begin
        we     = 1'b1;
        wb_sel = 1'b1;
        alu_op = 2'b00;
        mem_we = 1'b0;
      end
      OPC_VSTR: begin
        we     = 1'b0;
        wb_sel = 1'b0;
        alu_op = 2'b00;
        mem_we = 1'b1;
      end
      OPC_BEQ: begin
        we     = 1'b0;
        wb_sel = 1'b1;
        alu_op = 2'b01;
        branch = 1'b1;
      end
      OPC_VCMP: begin
        we      = 1'b0;
        wb_sel  = 1'b1;
        alu_op  = 2'b01;
        mask_op = 2'b01;
      end
      OPC_VINV: begin
        we      = 1'b0;
        wb_sel  = 1'b1;
        alu_op  = 2'b01;
        mask_op = 2'b10;
      end
      OPC_VPOP: begin
        we      = 1'b0;
        wb_sel  = 1'b1;
        alu_op  = 2'b01;
        mask_op = 2'b11;
      end

      default: begin
        we = 1'b0;
      end
    endcase
  end

endmodule
