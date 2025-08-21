//==============================================================================
// CORRECTED FILE: aes_encrypt_decrypt.v
//==============================================================================
`timescale 1ns/1ps

// --- Encryption Module (This was already working correctly) ---
module aes_encrypt (
    input  [127:0] plaintext,
    input  [127:0] key,
    output [127:0] ciphertext
);
    wire [1407:0] ks;
    aes_key_expansion keyexp(.key_in(key), .key_out(ks));

    wire [127:0] round_key [0:10];
    genvar k; 
    generate
        for(k=0; k<=10; k=k+1) begin : rk
            aes_key_schedule ksched(.expanded_keys(ks), .round(k), .round_key(round_key[k]));
        end
    endgenerate

    wire [127:0] st [0:10];
    aes_addroundkey ark0(.state_in(plaintext), .round_key(round_key[0]), .state_out(st[0]));
    
    generate
        for(k=1; k<=9; k=k+1) begin : mid
            aes_round ar(.state_in(st[k-1]), .round_key(round_key[k]), .is_final(1'b0), .state_out(st[k]));
        end
    endgenerate
    
    aes_round finalr(.state_in(st[9]), .round_key(round_key[10]), .is_final(1'b1), .state_out(st[10]));
    assign ciphertext = st[10];
endmodule


// --- Decryption Module (This is the corrected version) ---
module aes_decrypt (
    input  [127:0] ciphertext,
    input  [127:0] key,
    output [127:0] plaintext
);
    wire [1407:0] ks;
    aes_key_expansion keyexp(.key_in(key), .key_out(ks));

    wire [127:0] rk [0:10];
    genvar i;
    generate for(i=0; i<=10; i=i+1) begin : dec_ksched
        aes_key_schedule ksched(.expanded_keys(ks), .round(i), .round_key(rk[i]));
    end endgenerate

    wire [127:0] st [0:10];

    aes_addroundkey ark10(.state_in(ciphertext), .round_key(rk[10]), .state_out(st[10]));

    generate
      for(i=1; i<=9; i=i+1) begin : dec_rounds
        aes_inv_round inv_r(
            .state_in( st[11-i] ),
            .round_key(rk[10-i]),
            .state_out( st[10-i] )
        );
      end
    endgenerate

    wire [127:0] final_st_isr, final_st_isb;
    aes_inv_shiftrows isr0(.state_in(st[1]), .state_out(final_st_isr));
    aes_inv_subbytes  isb0(.state_in(final_st_isr), .state_out(final_st_isb));
    aes_addroundkey   ark0(.state_in(final_st_isb), .round_key(rk[0]), .state_out(plaintext));
endmodule