//==============================================================================
// CORRECTED FILE: aes_round.v
//==============================================================================
`timescale 1ns/1ps

// --- Encryption Round Module (This was already working correctly) ---
module aes_round (
    input  [127:0] state_in,
    input  [127:0] round_key,
    input          is_final,
    output [127:0] state_out
);
    wire [127:0] sb, sr, mc;
    aes_subbytes     sbm(.state_in(state_in), .state_out(sb));
    aes_shiftrows    srm(.state_in(sb),       .state_out(sr));
    aes_mixcolumns   mcm(.state_in(sr),       .state_out(mc));
    aes_addroundkey  ark(.state_in(is_final ? sr : mc), .round_key(round_key), .state_out(state_out));
endmodule


// --- Inverse Round Module (This is the corrected version) ---
// It now correctly performs all 4 steps in the standard order for rounds 9 down to 1.
module aes_inv_round (
    input  [127:0] state_in,
    input  [127:0] round_key,
    output [127:0] state_out
);
    wire [127:0] isr_out, isb_out, ark_out;

    // Standard Inverse Cipher Round Order:
    // 1. InvShiftRows
    // 2. InvSubBytes
    // 3. AddRoundKey
    // 4. InvMixColumns
    aes_inv_shiftrows  isr_m(.state_in(state_in), .state_out(isr_out));
    aes_inv_subbytes   isb_m(.state_in(isr_out),  .state_out(isb_out));
    aes_addroundkey    ark_m(.state_in(isb_out),  .round_key(round_key), .state_out(ark_out));
    aes_inv_mixcolumns imc_m(.state_in(ark_out),  .state_out(state_out));
endmodule