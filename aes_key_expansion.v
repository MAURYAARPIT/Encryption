`timescale 1ns/1ps
//==============================================================================
// AES Key Expansion for AES-128
// Generates 11 round keys (44 words = 1408 bits)
// File: aes_key_expansion.v
//==============================================================================

module aes_key_expansion (
    input  [127:0] key_in,      // Original key
    output [1407:0] key_out     // Expanded key schedule
);

wire [31:0] w [0:43];
wire [31:0] rcon [0:9];

// Round constants
assign rcon[0]=32'h01000000; assign rcon[1]=32'h02000000;
assign rcon[2]=32'h04000000; assign rcon[3]=32'h08000000;
assign rcon[4]=32'h10000000; assign rcon[5]=32'h20000000;
assign rcon[6]=32'h40000000; assign rcon[7]=32'h80000000;
assign rcon[8]=32'h1b000000; assign rcon[9]=32'h36000000;

// Initial key words
assign w[0]=key_in[127:96];
assign w[1]=key_in[95:64];
assign w[2]=key_in[63:32];
assign w[3]=key_in[31:0];

// Generate words
genvar i;
generate
  for (i=4; i<44; i=i+1) begin : key_gen
    if (i%4==0) begin
      wire [31:0] temp = {w[i-1][23:16],w[i-1][15:8],w[i-1][7:0],w[i-1][31:24]};
      wire [31:0] subword;
      aes_sbox sb0(.data_in(temp[31:24]), .data_out(subword[31:24]));
      aes_sbox sb1(.data_in(temp[23:16]), .data_out(subword[23:16]));
      aes_sbox sb2(.data_in(temp[15:8]),  .data_out(subword[15:8]));
      aes_sbox sb3(.data_in(temp[7:0]),   .data_out(subword[7:0]));
      assign w[i] = w[i-4] ^ subword ^ rcon[i/4-1];
    end else begin
      assign w[i] = w[i-4] ^ w[i-1];
    end
  end
endgenerate

// Pack keys
assign key_out = {w[0],w[1],w[2],w[3],w[4],w[5],w[6],w[7],w[8],w[9],
                  w[10],w[11],w[12],w[13],w[14],w[15],w[16],w[17],w[18],w[19],
                  w[20],w[21],w[22],w[23],w[24],w[25],w[26],w[27],w[28],w[29],
                  w[30],w[31],w[32],w[33],w[34],w[35],w[36],w[37],w[38],w[39],
                  w[40],w[41],w[42],w[43]};

endmodule

// Round key extractor
module aes_key_schedule (
    input  [1407:0] expanded_keys, // Full schedule
    input  [3:0]    round,         // Round number (0–10)
    output [127:0]  round_key      // Selected round key
);
wire [127:0] keys [0:10];
assign {keys[0],keys[1],keys[2],keys[3],keys[4],keys[5],
        keys[6],keys[7],keys[8],keys[9],keys[10]} = expanded_keys;
assign round_key = keys[round];
endmodule
