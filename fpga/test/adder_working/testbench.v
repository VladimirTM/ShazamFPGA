`timescale 1ns/1ps
module testbench;
    reg signed [15:0] A;
    reg signed [15:0] B;
    wire signed [15:0] result;
    reg enable = 0;
    
    reg clk = 0;
    always #10 clk = ~clk;

    parameter EXP_WIDTH_B = 5;
    parameter EXP_WIDTH_A = 15;
    
    parameter EXP_A = 0.000030517578125; // 2^-15
    parameter EXP_B = 0.03125; // 2^-5

    fixed_point_adder ADDER_INSTANCE (
        .clk(clk),
        .enable(enable),
        .A(A),
        .B(B),
        .sum(result)
    );

    integer output_file;

    initial begin
        output_file = $fopen("adder_test.output.txt", "w");

        A = 16'b0111_1111_1111_1111; // this is approx 1023.968750
        B = 16'b0111_1111_1111_1111; // this is approx 1023.968750
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A + B = 1023.968750
        $fwrite(output_file, "RESULT 1: %f + %f = %f (expecting overflow)\n", A * EXP_B, B * EXP_B, result * EXP_B);

        #20;
        
        A = 16'b0100_0000_001__00000; // this is approx 513
        B = 16'b0111_1111_110__00000; // this is approx 1022
        enable = 1;
        
        #20;
        enable = 0;
        #20;

        // A + B will overflow so result should be: 1023.968750
        $fwrite(output_file, "RESULT 2: %f + %f = %f (expecting overflow = 1023.9999)\n", A * EXP_B, B * EXP_B, result * EXP_B);
    
        #20;

        
        A = 16'b000_0000_0010__10000; // this is approx 2.5
        B = 16'b001_0000_0001__10000; // this is approx 257.5
        enable = 1;

        #20;
        enable = 0;
        #20;
        
        $fwrite(output_file, "RESULT 3: %f + %f = %f (expecting 260)\n", A * EXP_B, B * EXP_B, result * EXP_B);

        #20;

        // A = -30 (30 = 0001_1110 => -30 = 1110 0010) in 2's complement
        A = 16'b111_1110_0010__00000;
        B = 16'b000_0000_0100__00000; // 4
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A + B = -120
        $fwrite(output_file, "RESULT 4: %f + %f = %f (expecting -26)\n", A * EXP_B, B * EXP_B, result * EXP_B);

        #20;

         // A = -512 (=1111 1110 0000 0000) in 2's complement
        A = 16'b110_0000_0000__00000;

        // B = -1000 in 2's complement
        B = 16'b1111_1100_000__11000;
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A + B expecting negative overflow
        $fwrite(output_file, "RESULT 5: %f + %f = %f (expecting overflow = -1024)\n", A * EXP_B, B * EXP_B, result * EXP_B);

        #20;

        // A = -512 (=1111 1110 0000 0000) in 2's complement
        A = 16'b110_0000_0000__00000;
        B = 16'b000_0001_0000__00000; // 16
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A + B = -496
        $fwrite(output_file, "RESULT 6: %f + %f = %f (expecting -496)\n", A * EXP_B, B * EXP_B, result * EXP_B);
        #20;


        // A = -30.5 (30.5 = 000_0001_1110__10000 => -30.5 = 1111 1100 0011 0000)
        A = 16'b1111_1100_0011_0000;
        B = 16'b000_0000_0100__01000; // 4.25
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A + B = -26.25
        $fwrite(output_file, "RESULT 7: %f + %f = %f (expecting -26.25)\n", A * EXP_B, B * EXP_B, result * EXP_B);
        #20;

        $fclose(output_file);
    end
endmodule