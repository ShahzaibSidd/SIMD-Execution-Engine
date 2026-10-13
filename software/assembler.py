import sys
import re

# Opcode Mapping (Matches your instruction_decoder.sv exactly)
OPCODES = {
    "VADD":      0b000001,
    "VSUB":      0b000010,
    "VMUL":      0b000011,
    "VLOAD":     0b010000,
    "VSTR":      0b010001,
    "VLOAD_IND": 0b010010,
    "VSTR_IND":  0b010011,
    "VCMP":      0b100000,
    "VINV":      0b100001,
    "VPOP":      0b100010,
    "BEQ":       0b110000,
    "BNE":       0b110001
}

def to_2s_complement(val, bits):
    if val < 0:
        val = (1 << bits) + val
    return val & ((1 << bits) - 1)

def parse_register(reg_str):
    # Converts "V4" or "[V4]" into the integer 4
    return int(re.sub(r'[^0-9]', '', reg_str))

def assemble(input_file, output_file):
    with open(input_file, 'r') as f:
        lines = f.readlines()

    instructions = []
    labels = {}

    # PASS 1: Strip comments, empty lines, and record label locations
    pc = 0
    for line in lines:
        line = line.split('//')[0].strip()
        if not line:
            continue
        if line.endswith(':'):
            label_name = line[:-1]
            labels[label_name] = pc
        else:
            instructions.append(line)
            pc += 1

    # PASS 2: Parse instructions to 32-bit Hex
    hex_output = []
    for current_pc, line in enumerate(instructions):
        parts = line.replace(',', ' ').split()
        op_str = parts[0].upper()

        opcode = OPCODES[op_str]
        rd = rs1 = rs2 = imm = 0

        if op_str in ["VADD", "VSUB", "VMUL"]:
            # Format: VADD V1, V2, V3
            rd = parse_register(parts[1])
            rs1 = parse_register(parts[2])
            rs2 = parse_register(parts[3])

        elif op_str == "VCMP":
            # Format: VCMP V4, V6  -> compares rs1 (V4) against rs2 (V6)
            rs1 = parse_register(parts[1])
            rs2 = parse_register(parts[2])

        elif op_str in ["VLOAD", "VSTR"]:
            # Format: VLOAD V1, 100
            rd = parse_register(parts[1])
            imm = int(parts[2])

        elif op_str in ["VLOAD_IND", "VSTR_IND"]:
            # Format: VLOAD_IND V1, [V4]
            rd = parse_register(parts[1])
            rs1 = parse_register(parts[2])

        elif op_str in ["BEQ", "BNE"]:
            # Format: BEQ/BNE LABEL
            target_label = parts[1]
            if target_label in labels:
                # Calculate relative offset (Target PC - Current PC)
                offset = labels[target_label] - current_pc
                # The Verilog PC adds 1 * 4 bytes per cycle, but our PC tracks words, so we multiply by 4
                imm = to_2s_complement(offset * 4, 17)
            else:
                imm = to_2s_complement(int(parts[1]), 17)

        elif op_str in ["VINV", "VPOP"]:
            pass 

        # Bitwise Packing (32-bit instruction)
        machine_code = (opcode << 26) | (rd << 23) | (rs1 << 20) | (rs2 << 17) | imm

        # Format as 8-character uppercase Hex string
        hex_output.append(f"{machine_code:08X}")

    # Write to program.hex
    with open(output_file, 'w') as f:
        for hex_str in hex_output:
            f.write(hex_str + '\n')
    print(f"Successfully compiled {len(hex_output)} instructions to {output_file}.")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 assembler.py <input.asm> <output.hex>")
    else:
        assemble(sys.argv[1], sys.argv[2])
