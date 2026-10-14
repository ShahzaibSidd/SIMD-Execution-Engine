SRC_DIR = rtl
TB_DIR = tb
SIM_DIR = sim
RTL_SRCS = $(wildcard rtl/*.sv)

vec_alu_compile:
	iverilog -g2012 -o $(SIM_DIR)/vec_alu_sim.vvp $(SRC_DIR)/alu.sv $(SRC_DIR)/vector_alu.sv $(TB_DIR)/vector_alu_tb.sv

vec_alu_sim: vec_alu_compile
	vvp $(SIM_DIR)/vec_alu_sim.vvp

vec_alu_waves: vec_alu_sim
	gtkwave $(SIM_DIR)/vector_alu.vcd &


datapath_compile:
	iverilog -g2012 -o $(SIM_DIR)/datapath_sim.vvp $(SRC_DIR)/alu.sv $(SRC_DIR)/vector_alu.sv $(SRC_DIR)/vector_regfile.sv $(SRC_DIR)/simd_datapath.sv $(TB_DIR)/simd_datapath_tb.sv

datapath_sim: datapath_compile
	vvp sim/datapath_sim.vvp

datapath_wave: datapath_sim
	gtkwave sim/simd_datapath.vcd &


TB_SRC = tb/simd_core_tb.sv
OUT_VVP = sim/simd_core.vvp
OUT_VCD = sim/simd_core.vcd

# Compile all RTL files and the testbench together
compile:
	iverilog -g2012 -o $(OUT_VVP) $(RTL_SRCS) $(TB_SRC)

# Run the simulation executable
sim: compile
	vvp $(OUT_VVP)

# Compile, simulate, and open GTKWave in the background
wave: sim
	gtkwave $(OUT_VCD) &

# ---- SIMT divergence test (VIF / VINV / VPOP) ----
DIV_TB  = tb/simd_divergence_tb.sv
DIV_VVP = sim/simd_divergence.vvp
DIV_VCD = sim/simd_divergence.vcd

# Assemble the divergence program into program.hex (the ROM path the core reads)
div_asm:
	python3 software/assembler.py software/divergence.asm software/program.hex

div_compile: div_asm
	iverilog -g2012 -o $(DIV_VVP) $(RTL_SRCS) $(DIV_TB)

div_sim: div_compile
	vvp $(DIV_VVP)

div_wave: div_sim
	gtkwave $(DIV_VCD) &

SHOW_TB  = tb/simd_showcase_tb.sv
SHOW_VVP = sim/simd_showcase.vvp
SHOW_VCD = sim/simd_showcase.vcd

show_asm:
	python3 software/assembler.py software/compare_diverge.asm software/program.hex

show_compile: show_asm
	iverilog -g2012 -o $(SHOW_VVP) $(RTL_SRCS) $(SHOW_TB)

show_sim: show_compile
	vvp $(SHOW_VVP)

show_wave: show_sim
	gtkwave $(SHOW_VCD) &

# Clean up the simulation folder
clean:
	rm -f sim/*.vvp sim/*.vcd
