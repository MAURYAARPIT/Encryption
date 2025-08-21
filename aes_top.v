//==============================================================================
`timescale 1ns/1ps

module aes_top (
    input               clk,
    input               rst_n,
    input               start,
    input               encrypt,
    input       [127:0] data_in,
    input       [127:0] key_in,
    output reg  [127:0] data_out,
    output              busy,
    output reg          done
);

// State encoding
localparam IDLE = 2'b00, PROC = 2'b01, DONE = 2'b10;
reg [1:0] state, next_state;

// Internal registers for inputs
reg [127:0] din_reg;
reg [127:0] key_reg;
reg         encrypt_reg;

// Instantiate AES Encrypt and Decrypt cores
wire [127:0] enc_out;
wire [127:0] dec_out;

// Since the cores are purely combinational, we can feed the registers directly
aes_encrypt enc (
    .plaintext(din_reg),
    .key(key_reg),
    .ciphertext(enc_out)
);

aes_decrypt dec (
    .ciphertext(din_reg),
    .key(key_reg),
    .plaintext(dec_out)
);

// Sequential logic for state and registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        din_reg <= 128'b0;
        key_reg <= 128'b0;
        data_out <= 128'b0;
        done <= 1'b0;
        encrypt_reg <= 1'b0;
    end else begin
        state <= next_state;
        done <= 1'b0; // Default done to 0

        // Latch inputs on start
        if (next_state == PROC) begin
            din_reg <= data_in;
            key_reg <= key_in;
            encrypt_reg <= encrypt;
        end
        
        // Latch output when moving to DONE state
        if (next_state == DONE) begin
            data_out <= encrypt_reg ? enc_out : dec_out;
            done <= 1'b1;
        end
    end
end

// Combinational logic for next state
always @(*) begin
    case (state)
        IDLE: next_state = start ? PROC : IDLE;
        PROC: next_state = DONE;
        DONE: next_state = IDLE; // Go back to IDLE after one cycle in DONE
        default: next_state = IDLE;
    endcase
end

// Outputs
assign busy = (state == PROC);


endmodule
