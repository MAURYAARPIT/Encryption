//==============================================================================
// Description: Implements ShiftRows and InvShiftRows using the official
// FIPS-197 column-major byte mapping.
//==============================================================================
`timescale 1ns/1ps

// AES state array mapping from 128-bit vector:
// state_in[127:120] -> byte 15
// state_in[119:112] -> byte 14
// ...
// state_in[7:0]     -> byte 0

// Standard 4x4 State Representation (indices of bytes):
// 0  4  8  12
// 1  5  9  13
// 2  6  10 14
// 3  7  11 15

module aes_shiftrows (
    input  [127:0] state_in,
    output [127:0] state_out
);
    // Row 0: No shift
    assign state_out[127:120] = state_in[127:120]; // byte 15
    assign state_out[95:88]   = state_in[95:88];   // byte 11
    assign state_out[63:56]   = state_in[63:56];   // byte 7
    assign state_out[31:24]   = state_in[31:24];   // byte 3

    // Row 1: Left shift by 1
    assign state_out[119:112] = state_in[87:80];   // byte 14 gets byte 10
    assign state_out[87:80]   = state_in[55:48];   // byte 10 gets byte 6
    assign state_out[55:48]   = state_in[23:16];   // byte 6  gets byte 2
    assign state_out[23:16]   = state_in[119:112]; // byte 2  gets byte 14

    // Row 2: Left shift by 2
    assign state_out[111:104] = state_in[47:40];   // byte 13 gets byte 5
    assign state_out[79:72]   = state_in[15:8];    // byte 9  gets byte 1
    assign state_out[47:40]   = state_in[111:104]; // byte 5  gets byte 13
    assign state_out[15:8]    = state_in[79:72];   // byte 1  gets byte 9

    // Row 3: Left shift by 3 (or right shift by 1)
    assign state_out[103:96]  = state_in[7:0];     // byte 12 gets byte 4
    assign state_out[71:64]   = state_in[103:96];  // byte 8  gets byte 0
    assign state_out[39:32]   = state_in[71:64];   // byte 4  gets byte 12
    assign state_out[7:0]     = state_in[39:32];   // byte 0  gets byte 8
endmodule


module aes_inv_shiftrows (
    input  [127:0] state_in,
    output [127:0] state_out
);
    // Row 0: No shift
    assign state_out[127:120] = state_in[127:120];
    assign state_out[95:88]   = state_in[95:88];
    assign state_out[63:56]   = state_in[63:56];
    assign state_out[31:24]   = state_in[31:24];

    // Row 1: Right shift by 1
    assign state_out[119:112] = state_in[23:16];
    assign state_out[87:80]   = state_in[119:112];
    assign state_out[55:48]   = state_in[87:80];
    assign state_out[23:16]   = state_in[55:48];

    // Row 2: Right shift by 2
    assign state_out[111:104] = state_in[47:40];
    assign state_out[79:72]   = state_in[15:8];
    assign state_out[47:40]   = state_in[111:104];
    assign state_out[15:8]    = state_in[79:72];

    // Row 3: Right shift by 3 (or left shift by 1)
    assign state_out[103:96]  = state_in[71:64];
    assign state_out[71:64]   = state_in[39:32];
    assign state_out[39:32]   = state_in[7:0];
    assign state_out[7:0]     = state_in[103:96];

endmodule
