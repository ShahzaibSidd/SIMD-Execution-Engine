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
    output logic        branch_ne,
    output logic [16:0] imm,

    // scalar compare flag control
    output logic cmp_set,

    // sram memory control
    output logic mem_we,
    output logic mem_addr_sel,

    // simt mask control
    output logic [1:0] mask_op
);

  localparam logic [5:0] OPC_VADD = 6'b000001;
  localparam logic [5:0] OPC_VSUB = 6'b000010;
  localparam logic [5:0] OPC_VMUL = 6'b000011;
  localparam logic [5:0] OPC_VOR = 6'b001000;

  localparam logic [5:0] OPC_VLOAD = 6'b010000;
  localparam logic [5:0] OPC_VSTR = 6'b010001;
  localparam logic [5:0] OPC_VLOAD_IND = 6'b010010;
  localparam logic [5:0] OPC_VSTR_IND = 6'b010011;

  localparam logic [5:0] OPC_VCMP = 6'b100000;
  localparam logic [5:0] OPC_VINV = 6'b100001;
  localparam logic [5:0] OPC_VPOP = 6'b100010;

  localparam logic [5:0] OPC_BEQ = 6'b110000;
  localparam logic [5:0] OPC_BNE = 6'b110001;

  typedef struct packed {
    logic       we;            // vector regfile write enable
    logic       wb_sel;        // 0 = ALU result, 1 = memory data
    logic [1:0] alu_op;        // 00 add, 01 sub, 10 mul, 11 or
    logic       branch;        // this is a branch instruction
    logic       branch_ne;     // branch on NOT-equal (BNE) vs equal (BEQ)
    logic       cmp_set;       // latch the scalar equality flag (VCMP)
    logic       mem_we;        // data memory write enable
    logic       mem_addr_sel;  // 0 = immediate addr, 1 = indirect pointer
    logic [1:0] mask_op;       // SIMT mask: 00 nop, 01 push, 10 inv, 11 pop
  } ctrl_word_t;

  logic       [5:0] opcode;
  ctrl_word_t       ctrl;

  assign opcode       = instr[31:26];
  assign rd           = instr[25:23];
  assign rs1          = instr[22:20];
  assign rs2          = instr[19:17];
  assign imm          = instr[16:0];

  assign we           = ctrl.we;
  assign wb_sel       = ctrl.wb_sel;
  assign alu_op       = ctrl.alu_op;
  assign branch       = ctrl.branch;
  assign branch_ne    = ctrl.branch_ne;
  assign cmp_set      = ctrl.cmp_set;
  assign mem_we       = ctrl.mem_we;
  assign mem_addr_sel = ctrl.mem_addr_sel;
  assign mask_op      = ctrl.mask_op;

  always_comb begin
    // Start from the inert word (all fields zero: no writes, no branch,
    // ALU add, mask untouched); each arm overrides only what differs.
    ctrl = '0;

    case (opcode)
      OPC_VADD: begin
        ctrl.we     = 1'b1;
        ctrl.alu_op = 2'b00;
      end
      OPC_VSUB: begin
        ctrl.we     = 1'b1;
        ctrl.alu_op = 2'b01;
      end
      OPC_VMUL: begin
        ctrl.we     = 1'b1;
        ctrl.alu_op = 2'b10;
      end
      OPC_VOR: begin
        ctrl.we     = 1'b1;
        ctrl.alu_op = 2'b11;
      end
      OPC_VLOAD: begin
        ctrl.we     = 1'b1;
        ctrl.wb_sel = 1'b1;
      end
      OPC_VSTR: begin
        ctrl.mem_we = 1'b1;
      end
      OPC_BEQ: begin
        ctrl.wb_sel = 1'b1;
        ctrl.alu_op = 2'b01;
        ctrl.branch = 1'b1;
      end
      OPC_BNE: begin
        ctrl.wb_sel    = 1'b1;
        ctrl.alu_op    = 2'b01;
        ctrl.branch    = 1'b1;
        ctrl.branch_ne = 1'b1;
      end
      OPC_VLOAD_IND: begin
        ctrl.we           = 1'b1;
        ctrl.wb_sel       = 1'b1;
        ctrl.mem_addr_sel = 1'b1;
      end
      OPC_VSTR_IND: begin
        ctrl.mem_we       = 1'b1;
        ctrl.mem_addr_sel = 1'b1;
      end
      OPC_VCMP: begin
        ctrl.alu_op  = 2'b01;
        ctrl.cmp_set = 1'b1;
      end
      OPC_VINV: begin
        ctrl.wb_sel  = 1'b1;
        ctrl.alu_op  = 2'b01;
        ctrl.mask_op = 2'b10;
      end
      OPC_VPOP: begin
        ctrl.wb_sel  = 1'b1;
        ctrl.alu_op  = 2'b01;
        ctrl.mask_op = 2'b11;
      end

      default: ctrl = '0;
    endcase
  end

endmodule
