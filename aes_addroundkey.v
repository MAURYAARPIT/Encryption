`timescale 1ns/1ps
//==============================================================================
// AES AddRoundKey Transformation - XOR state and round key
// File: aes_addroundkey.v
//==============================================================================

module aes_addroundkey (
    input  [127:0] state_in,   // Input state
    input  [127:0] round_key,  // Round key
    output [127:0] state_out   // Output state after XOR
);

assign state_out = state_in ^ round_key;

endmodule
