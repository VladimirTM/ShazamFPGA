`timescale 1ns/1ps
module testbench;
    reg signed [15:0] A;
    reg signed [15:0] B;
    wire signed [15:0] result;
    wire done;
    reg enable = 0;
    
    reg clk = 0;
    always #10 clk = ~clk;

    parameter EXP_WIDTH_B = 5;
    parameter EXP_WIDTH_A = 15;
    
    parameter EXP_A = 0.000030517578125; // 2^-15
    parameter EXP_B = 0.03125; // 2^-5

    fixed_point_multiplier #(.EXP_WIDTH_A(EXP_WIDTH_A), .EXP_WIDTH_B(EXP_WIDTH_B), .EXP_WIDTH_PRODUCT(EXP_WIDTH_B)) MULTIPLIER_INSTANCE (
        .clk(clk),
        .enable(enable),
        .done(done),
        .A(A),
        .B(B),
        .product(result)
    );

    integer output_file;

    initial begin
        output_file = $fopen("multiplier_test_sin_cos.output.txt", "w");
        enable = 1;

        A = 16'b0__010_1101_0100_0001; // this is approx ?
        B = 16'b111_1111_1101__00000; // this is -3
        #20;
        #20;
        // A * B = 1024,96875
        $fwrite(output_file, "RESULT 1: %f * %f = %f (expecting small value) - decimal: %d\n", A * EXP_A, B * EXP_B, result * EXP_B, result);

        A = 16'b0__1110_1110_0100_000;
        B = 16'b0011_1111_110_00000; // this is approx 510
        #20;
        #20;
        // A * B should NOT OVERFLOW
        $fwrite(output_file, "RESULT 2: %f * %f = %f (expecting NOT overflow)\n", A * EXP_A, B * EXP_B, result * EXP_B);
        
        A = 16'b0__0100_1001_1010_110;
        B = 16'b001_0000_0001__10000; // this is approx 257.5
        $fwrite(output_file, "RESULT 3: %f * %f = %f (expecting NOT overflow)\n", A * EXP_A, B * EXP_B, result * EXP_B);


        A = 16'b0__1111_1000_1000_000;
        B = 16'b000_0000_0100__00000;
        #20;
        #20;
        // A * B = -120
        $fwrite(output_file, "RESULT 4: %f * %f = %f (expecting NOT overflow)\n", A * EXP_A, B * EXP_B, result * EXP_B);

        A = 16'b0__1000_0110_0100_001;
        B = 16'b100_0011_0101__00000;
        // A * B expecting negative overflow
        #20;
        #20;
        $fwrite(output_file, "RESULT 5: %f * %f = %f (expecting NOT overflow)\n", A * EXP_A, B * EXP_B, result * EXP_B);

        A = 16'b0__1000_0000_0000_000;
        B = 16'b000_0001_0000__00000; // 16
        #20;
        #20;
        // A * B should NOT overflow
        $fwrite(output_file, "RESULT 6: %f * %f = %f (should NOT overflow)\n", A * EXP_A, B * EXP_B, result * EXP_B);
        
        A = 16'b0__1111_1000_0110_000;
        B = 16'b000_0000_0100__01000; // 4.25
        #20;
        #20;
        $fwrite(output_file, "RESULT 7: %f * %f = %f (expecting NOT overflow)\n", A * EXP_A, B * EXP_B, result * EXP_B);

        A = 16'b0000_0000_0000_0000; // 0
        B = 16'b0000_0000_0000_0000; // 0
        #20;
        #20;
        $fwrite(output_file, "RESULT 7: %f * %f = %f (expecting NOT overflow) decimal: %d\n", A * EXP_A, B * EXP_B, result * EXP_B, result);
    
        A = 16'b0111_0000_0000_0000; // 0.7725
        B = 16'b0000_0000_0000_0000; // 0
        #20;
        #20;
        $fwrite(output_file, "RESULT 7: %f * %f = %f (expecting NOT overflow) decimal: %d\n", A * EXP_A, B * EXP_B, result * EXP_B, result);
    
        A = 16'b1101_0010_1011_10011; // 0.7725
        B = 16'b0000_0000_0000_0000; // 0
        #20;
        #20;
        $fwrite(output_file, "RESULT 7: %f * %f = %f (expecting NOT overflow) decimal: %d\n", A * EXP_A, B * EXP_B, result * EXP_B, result);
    end
endmodule