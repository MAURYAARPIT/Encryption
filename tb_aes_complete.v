`timescale 1ns/1ps
//==============================================================================
// Testbench - Verilog-1995 Compatible
//==============================================================================

module tb_aes;

    // DUT Connections
    reg clk = 0;
    reg rst_n = 0;
    reg start = 0;
    reg encrypt = 1; 
    reg [127:0] data_in;
    reg [127:0] key_in;
    wire [127:0] data_out;
    wire busy;
    wire done;

    // Test vector variables are now declared at the module level
    reg [127:0] test_plaintext;
    reg [127:0] test_key;
    reg [127:0] expected_ciphertext;
    reg [127:0] captured_ciphertext;
    reg [127:0] recovered_plaintext;

    // Instantiate the Unit Under Test (UUT)
    aes_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .encrypt(encrypt),
        .data_in(data_in),
        .key_in(key_in),
        .data_out(data_out),
        .busy(busy),
        .done(done)
    );

    // Clock generation (100 MHz)
    always #5 clk = ~clk;

    // Main test sequence
    initial begin
        // Initialize test vector values inside the initial block
        test_plaintext = 128'h00112233445566778899aabbccddeeff;
        test_key       = 128'h000102030405060708090a0b0c0d0e0f;
        expected_ciphertext = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

        // --- Start of Test ---
        $display("Starting AES Core Test...");
        rst_n = 0;
        #30;
        rst_n = 1; 
        #20;

        // --- Test 1: AES Encryption ---
        $display("\n==============================");
        $display("==== AES Encryption Test ====");
        $display("==============================");
        
        @(posedge clk);
        data_in = test_plaintext;
        key_in = test_key;
        encrypt = 1'b1;
        start = 1;
        
        @(posedge clk);
        start = 0;

        wait (done == 1);
        captured_ciphertext = data_out;

        $display("Plaintext : %032h", test_plaintext);
        $display("Key       : %032h", test_key);
        $display("Result    : %032h", captured_ciphertext);
        $display("Expected  : %032h", expected_ciphertext);

        if (captured_ciphertext == expected_ciphertext) begin
            $display("Encryption result: PASSED ");
        end else begin
            $display("Encryption result: FAILED ");
        end

        #50;

        // --- Test 2: AES Decryption ---
        $display("\n==============================");
        $display("==== AES Decryption Test ====");
        $display("==============================");

        @(posedge clk);
        data_in = captured_ciphertext;
        key_in = test_key;
        encrypt = 1'b0;
        start = 1;
        
        @(posedge clk);
        start = 0;

        wait (done == 1);
        recovered_plaintext = data_out;

        $display("Ciphertext: %032h", captured_ciphertext);
        $display("Key       : %032h", test_key);
        $display("Recovered : %032h", recovered_plaintext);
        $display("Expected  : %032h", test_plaintext);

        if (recovered_plaintext == test_plaintext) begin
            $display("Decryption result: PASSED ");
        end else begin
            $display("Decryption result: FAILED ");
        end

        $display("\nSimulation Complete.");
        #20;
        $stop;
    end

endmodule
