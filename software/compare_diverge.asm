// software/compare_diverge.asm
// -------------------------------------------------------------------------
// SIMT compare-and-diverge showcase for waveform capture.
//
// V1 and V2 are compared lane-by-lane (VIF). The two branches each perform a
// DIFFERENT operation on the accumulator V3:
//
//     if   (V1 == V2)   V3 = V3 + V1     // IF  branch: add
//     else              V3 = V3 * V1     // ELSE branch: multiply
//
// This whole compare/diverge block runs TWICE back to back, so V3 evolves
// per lane depending on which branch that lane took.
//
// Data memory (word addressed), preloaded by the testbench:
//   addr 10 : V1 init = {5, 5, 9, 9}
//   addr 11 : V2 init = {5, 0, 9, 0}   -> V1==V2 in lanes {0,2}
//   addr 12 : V3 init = {10,10,10,10}
//
// Registers:
//   V0 = constant zero (unused here)
//   V1 = operand A      V2 = operand B      V3 = accumulator
// -------------------------------------------------------------------------

// ---- Load operands and accumulator ----
    VLOAD V1, 10          // V1 = {5,5,9,9}
    VLOAD V2, 11          // V2 = {5,0,9,0}
    VLOAD V3, 12          // V3 = {10,10,10,10}

// ================= ROUND 1 =================
    VIF  V1, V2           // active lanes where V1 == V2  -> {0,2}
    VADD V3, V3, V1       //   IF branch : V3 += V1
    VINV                  // flip to the ELSE lanes       -> {1,3}
    VMUL V3, V3, V1       //   ELSE branch: V3 *= V1
    VPOP                  // reconverge -> all lanes
    VSTR V3, 20           // store round-1 result

// ================= ROUND 2 =================
    VIF  V1, V2           // same compare, same mask      -> {0,2}
    VADD V3, V3, V1       //   IF branch : V3 += V1
    VINV                  // ELSE lanes                   -> {1,3}
    VMUL V3, V3, V1       //   ELSE branch: V3 *= V1
    VPOP                  // reconverge
    VSTR V3, 21           // store round-2 result

HALT:
    BEQ HALT
