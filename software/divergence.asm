// software/divergence.asm
// SIMT divergence test for the VIF / VINV / VPOP mask stack.
//
// The testbench preloads these constants into data memory:
//   addr 20: A1       = {7, 7, 7, 7}
//   addr 21: B1       = {7, 0, 7, 0}   -> A1==B1 in lanes {0,2}
//   addr 22: IF_VAL   = {100,100,100,100}
//   addr 23: ELSE_VAL = {200,200,200,200}
//   addr 24: C        = {9, 9, 9, 9}
//   addr 25: D        = {9, 9, 0, 0}   -> C==D in lanes {0,1}
//   addr 26: ALLSAME  = {5, 5, 5, 5}   -> matches all 4 lanes
//   addr 27: NONESAME = {1, 2, 3, 4}   -> matches no lane vs ALLSAME? see below
//   addr 28: FIVES    = {5, 5, 5, 5}
//
// Register use:
//   V1,V2 predicate operands; V3 result; V4,V5 nested operands; V6,V7 scratch

// TEST 1: Simple IF / ELSE  (predicate active in lanes {0,2})
//   Expect V3 = {100, 200, 100, 200}
    VLOAD V1, 20          // V1 = {7,7,7,7}
    VLOAD V2, 21          // V2 = {7,0,7,0}
    VLOAD V6, 22          // V6 = IF_VAL   {100,100,100,100}
    VLOAD V7, 23          // V7 = ELSE_VAL {200,200,200,200}
    VSUB  V3, V3, V3      // V3 = 0

    VIF   V1, V2          // keep lanes where V1==V2 -> {0,2}
    VADD  V3, V6, V0      // IF body: V3 = IF_VAL  (lanes 0,2 only)
    VINV                  // flip to the ELSE lanes -> {1,3}
    VADD  V3, V7, V0      // ELSE body: V3 = ELSE_VAL (lanes 1,3 only)
    VPOP                  // restore mask -> all lanes
    VSTR  V3, 40          // store result of TEST 1

// TEST 2: Second independent region after full restore.
//   Predicate active in all 4 lanes (ALLSAME vs FIVES).
//   Expect V3 = {100,100,100,100}  (IF body writes every lane)
    VLOAD V1, 26          // V1 = {5,5,5,5}
    VLOAD V2, 28          // V2 = {5,5,5,5}
    VSUB  V3, V3, V3      // V3 = 0

    VIF   V1, V2          // all lanes match -> mask stays 1111
    VADD  V3, V6, V0      // every lane writes IF_VAL
    VPOP                  // restore
    VSTR  V3, 41          // store result of TEST 2

// TEST 3: Predicate active in NO lane.
//   V1={5,5,5,5} vs V2={1,2,3,4} -> no match, mask -> 0000
//   IF body must write nothing; V3 keeps its pre-set value {55,55,55,55}
//   Expect V3 = {55,55,55,55}
    VLOAD V2, 27          // V2 = {1,2,3,4}
    VLOAD V5, 29          // V5 = {55,55,55,55}
    VADD  V3, V5, V0      // V3 = {55,55,55,55}

    VIF   V1, V2          // no lane matches -> mask 0000
    VADD  V3, V6, V0      // IF body: should write NOTHING
    VPOP                  // restore
    VSTR  V3, 42          // store result of TEST 3

// TEST 4: Nested VIF.
//   Outer: V1={7,7,7,7} vs V2={7,0,7,0} -> active {0,2}
//   Inner: V4={9,9,9,9} vs V5={9,9,0,0} -> C==D in {0,1}
//   Combined active after inner VIF = {0,2} & {0,1} = {0}
//   Inner body writes lane 0 only.
//   After inner VPOP, mask returns to outer {0,2}; outer body writes {0,2}.
//   Start V3 = 0.
//   Inner body sets V3 lane0 = 100.
//   Outer body (after inner pop) sets V3 lanes {0,2} = 200.
//   Expect V3 = {200, 0, 200, 0}
    VLOAD V1, 20          // {7,7,7,7}
    VLOAD V2, 21          // {7,0,7,0}
    VLOAD V4, 24          // {9,9,9,9}
    VLOAD V5, 25          // {9,9,0,0}
    VSUB  V3, V3, V3      // V3 = 0

    VIF   V1, V2          // outer -> active {0,2}
    VIF   V4, V5          // inner -> active {0,2}&{0,1} = {0}
    VADD  V3, V6, V0      // inner body: V3 lane0 = 100
    VPOP                  // pop inner -> back to outer {0,2}
    VADD  V3, V7, V0      // outer body: V3 lanes {0,2} = 200 (overwrites lane0)
    VPOP                  // pop outer -> all lanes
    VSTR  V3, 43          // store result of TEST 4

// ============================================================
HALT:
    BEQ HALT
