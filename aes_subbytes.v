`timescale 1ns/1ps
//==============================================================================
// AES SubBytes Transformation - Parallel S-box processing
// File: aes_subbytes.v
//==============================================================================

// AES SubBytes Transformation Module
module aes_subbytes (
    input  [127:0] state_in,   // Input state (16 bytes)
    output [127:0] state_out   // Output state after substitution
);

// Instantiate 16 S-boxes for parallel processing of all bytes
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : sbox_array
        aes_sbox sbox_inst (
            .data_in(state_in[i*8 +: 8]),
            .data_out(state_out[i*8 +: 8])
        );
    end
endgenerate

endmodule

// AES Inverse SubBytes Transformation Module
module aes_inv_subbytes (
    input  [127:0] state_in,   // Input state (16 bytes)
    output [127:0] state_out   // Output state after inverse substitution
);

// Instantiate 16 inverse S-boxes for parallel processing
genvar i;
generate
    for (i = 0; i < 16; i = i + 1) begin : inv_sbox_array
        aes_inv_sbox inv_sbox_inst (
            .data_in(state_in[i*8 +: 8]),
            .data_out(state_out[i*8 +: 8])
        );
    end
endgenerate

endmodule
