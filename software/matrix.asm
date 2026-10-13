// software/matrix.asm
// Initialize Constants
VLOAD V2, 100        // Load Multiplier {2, 2, 2, 2}
VLOAD V5, 101        // Load Pointer Increment {1, 0, 0, 0}
VSUB V4, V4, V4      // Clear V4 to 0 (Starting Pointer)
VLOAD V6, 102        // Load Loop Boundary (e.g., 2500 for a 100x100 matrix)

PROCESS_ROW:
    // Memory Pointer Logic
    VLOAD_IND V1, [V4]

    // Matrix Math Payload
    VMUL V1, V1, V2

    // Writeback and Pointer Increment
    VSTR_IND V1, [V4]
    VADD V4, V4, V5

    // Boundary Check
    VCMP V4, V6
    BNE PROCESS_ROW      // If Pointer != Boundary, keep looping

HALT:
    BEQ HALT
