`timescale 1ns/1ps
//==============================================================================
// AES MixColumns Transformation - GF(2^8) arithmetic
// File: aes_mixcolumns.v
//==============================================================================

module aes_mixcolumns (
    input  [127:0] state_in,    // Input state matrix
    output [127:0] state_out    // Output state after MixColumns
);

function [7:0] xtime; input [7:0] x; begin xtime = (x<<1) ^ (x[7]?8'h1b:8'h00); end endfunction
function [7:0] mul02; input [7:0] x; begin mul02 = xtime(x); end endfunction
function [7:0] mul03; input [7:0] x; begin mul03 = xtime(x) ^ x; end endfunction

// Column 0
assign state_out[127:120] = mul02(state_in[127:120]) ^ mul03(state_in[119:112]) ^ state_in[111:104] ^ state_in[103:96];
assign state_out[119:112] = state_in[127:120] ^ mul02(state_in[119:112]) ^ mul03(state_in[111:104]) ^ state_in[103:96];
assign state_out[111:104] = state_in[127:120] ^ state_in[119:112] ^ mul02(state_in[111:104]) ^ mul03(state_in[103:96]);
assign state_out[103:96]   = mul03(state_in[127:120]) ^ state_in[119:112] ^ state_in[111:104] ^ mul02(state_in[103:96]);
// Column 1
assign state_out[95:88]   = mul02(state_in[95:88]) ^ mul03(state_in[87:80]) ^ state_in[79:72] ^ state_in[71:64];
assign state_out[87:80]   = state_in[95:88] ^ mul02(state_in[87:80]) ^ mul03(state_in[79:72]) ^ state_in[71:64];
assign state_out[79:72]   = state_in[95:88] ^ state_in[87:80] ^ mul02(state_in[79:72]) ^ mul03(state_in[71:64]);
assign state_out[71:64]   = mul03(state_in[95:88]) ^ state_in[87:80] ^ state_in[79:72] ^ mul02(state_in[71:64]);
// Column 2
assign state_out[63:56]   = mul02(state_in[63:56]) ^ mul03(state_in[55:48]) ^ state_in[47:40] ^ state_in[39:32];
assign state_out[55:48]   = state_in[63:56] ^ mul02(state_in[55:48]) ^ mul03(state_in[47:40]) ^ state_in[39:32];
assign state_out[47:40]   = state_in[63:56] ^ state_in[55:48] ^ mul02(state_in[47:40]) ^ mul03(state_in[39:32]);
assign state_out[39:32]   = mul03(state_in[63:56]) ^ state_in[55:48] ^ state_in[47:40] ^ mul02(state_in[39:32]);
// Column 3
assign state_out[31:24]   = mul02(state_in[31:24]) ^ mul03(state_in[23:16]) ^ state_in[15:8] ^ state_in[7:0];
assign state_out[23:16]   = state_in[31:24] ^ mul02(state_in[23:16]) ^ mul03(state_in[15:8]) ^ state_in[7:0];
assign state_out[15:8]    = state_in[31:24] ^ state_in[23:16] ^ mul02(state_in[15:8]) ^ mul03(state_in[7:0]);
assign state_out[7:0]     = mul03(state_in[31:24]) ^ state_in[23:16] ^ state_in[15:8] ^ mul02(state_in[7:0]);

endmodule

//==============================================================================
// AES Inverse MixColumns Transformation
//==============================================================================

module aes_inv_mixcolumns (
    input  [127:0] state_in,
    output [127:0] state_out
);

function [7:0] mul02; input [7:0] x; begin mul02 = (x<<1) ^ (x[7]?8'h1b:8'h00); end endfunction
function [7:0] mul04; input [7:0] x; begin mul04 = mul02(mul02(x)); end endfunction
function [7:0] mul08; input [7:0] x; begin mul08 = mul02(mul04(x)); end endfunction
function [7:0] mul09; input [7:0] x; begin mul09 = mul08(x)   ^ x; end endfunction
function [7:0] mul0b; input [7:0] x; begin mul0b = mul08(x) ^ mul02(x) ^ x; end endfunction
function [7:0] mul0d; input [7:0] x; begin mul0d = mul08(x) ^ mul04(x) ^ x; end endfunction
function [7:0] mul0e; input [7:0] x; begin mul0e = mul08(x) ^ mul04(x) ^ mul02(x); end endfunction

// Column 0
assign state_out[127:120] = mul0e(state_in[127:120]) ^ mul0b(state_in[119:112]) ^ mul0d(state_in[111:104]) ^ mul09(state_in[103:96]);
assign state_out[119:112] = mul09(state_in[127:120]) ^ mul0e(state_in[119:112]) ^ mul0b(state_in[111:104]) ^ mul0d(state_in[103:96]);
assign state_out[111:104] = mul0d(state_in[127:120]) ^ mul09(state_in[119:112]) ^ mul0e(state_in[111:104]) ^ mul0b(state_in[103:96]);
assign state_out[103:96]  = mul0b(state_in[127:120]) ^ mul0d(state_in[119:112]) ^ mul09(state_in[111:104]) ^ mul0e(state_in[103:96]);
// Column 1
assign state_out[95:88]   = mul0e(state_in[95:88])   ^ mul0b(state_in[87:80])  ^ mul0d(state_in[79:72]) ^ mul09(state_in[71:64]);
assign state_out[87:80]   = mul09(state_in[95:88])   ^ mul0e(state_in[87:80])  ^ mul0b(state_in[79:72]) ^ mul0d(state_in[71:64]);
assign state_out[79:72]   = mul0d(state_in[95:88])   ^ mul09(state_in[87:80])  ^ mul0e(state_in[79:72]) ^ mul0b(state_in[71:64]);
assign state_out[71:64]   = mul0b(state_in[95:88])   ^ mul0d(state_in[87:80])  ^ mul09(state_in[79:72]) ^ mul0e(state_in[71:64]);
// Column 2
assign state_out[63:56]   = mul0e(state_in[63:56])   ^ mul0b(state_in[55:48])  ^ mul0d(state_in[47:40]) ^ mul09(state_in[39:32]);
assign state_out[55:48]   = mul09(state_in[63:56])   ^ mul0e(state_in[55:48])  ^ mul0b(state_in[47:40]) ^ mul0d(state_in[39:32]);
assign state_out[47:40]   = mul0d(state_in[63:56])   ^ mul09(state_in[55:48])  ^ mul0e(state_in[47:40]) ^ mul0b(state_in[39:32]);
assign state_out[39:32]   = mul0b(state_in[63:56])   ^ mul0d(state_in[55:48])  ^ mul09(state_in[47:40]) ^ mul0e(state_in[39:32]);
// Column 3
assign state_out[31:24]   = mul0e(state_in[31:24])   ^ mul0b(state_in[23:16])  ^ mul0d(state_in[15:8])  ^ mul09(state_in[7:0]);
assign state_out[23:16]   = mul09(state_in[31:24])   ^ mul0e(state_in[23:16])  ^ mul0b(state_in[15:8])  ^ mul0d(state_in[7:0]);
assign state_out[15:8]    = mul0d(state_in[31:24])   ^ mul09(state_in[23:16])  ^ mul0e(state_in[15:8])  ^ mul0b(state_in[7:0]);
assign state_out[7:0]     = mul0b(state_in[31:24])   ^ mul0d(state_in[23:16])  ^ mul09(state_in[15:8])  ^ mul0e(state_in[7:0]);

endmodule
