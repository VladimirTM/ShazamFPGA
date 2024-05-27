`timescale 1ns/1ps

module testbench;
    reg signed [15:0] A;
    reg signed [15:0] B;
    wire signed [15:0] result;
    wire done;
    reg enable = 0;
    
    reg clk = 0;
    always #10 clk = ~clk;

    localparam EXP = 5;
    localparam EXP_SMALLER = 0;
    reg [7:0] EXP_MULT = 8'b0000_0101; // 5
    reg [7:0] EXP_MULT_SMALLER = 8'b0000_0000; // 0
    
    fixed_point_multiplier #(.EXP_WIDTH_A(EXP), .EXP_WIDTH_B(EXP), .EXP_WIDTH_PRODUCT(EXP_SMALLER)) MULTIPLIER_INSTANCE (
        .clk(clk),
        .enable(enable),
        .done(done),
        .A(A),
        .B(B),
        .product(result)
    );

    integer output_file;

    initial begin
        output_file = $fopen("../../../data/multiplier_test.output.txt", "w");

        A = 16'b0111_1111_1111_1111; // this is approx 1024,9875
        B = 16'b0111_1111_1111_1111; // this is approx 1024,96875
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A * B = 1024,96875
        $fwrite(output_file, "RESULT 1: %f * %f = %f (expecting 1024,96875-ish)\n", A *0.03125, B *0.03125, result);

        #20;
        
        A = 16'b0000_0010_100_00000; // this is approx 20
        B = 16'b0111_1111_110_00000; // this is approx 1022
        enable = 1;
        
        #20;
        enable = 0;
        #20;

        // A * B will overflow so result should be: 1023.9999
        $fwrite(output_file, "RESULT 2: %f * %f = %f (expecting positive overflow = 1023.9999)\n", A *0.03125, B *0.03125, result);
    
        #20;

        
        A = 16'b000_0000_0010__10000; // this is approx 2.5
        B = 16'b001_0000_0001__10000; // this is approx 257.5
        enable = 1;

        #20;
        enable = 0;
        #20;
        
        $fwrite(output_file, "RESULT 3: %f * %f = %f (expecting 643.75)\n", A *0.03125, B *0.03125, result);

        #20;

        // A = -30 (30 = 0001_1110 => -30 = 1110 0010) in 2's complement
        A = 16'b111_1110_0010__00000;
        // B = -30
        B = 16'b111_1110_0010__00000;
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A * B = 90
        $fwrite(output_file, "RESULT 4: %f * %f = %f (expecting 90)\n", A *0.03125, B *0.03125, result);

        #20;

         // A = -512 (=1111 1110 0000 0000) in 2's complement
        A = 16'b110_0000_0000__00000;
        B = 16'b000_0000_0100__00000;
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A * B expecting negative overflow
        $fwrite(output_file, "RESULT 5: %f * %f = %f (should overflow negative: -1023.9999)\n", A *0.03125, B *0.03125, result);

        #20;

        // A = -512 (=1111 1110 0000 0000) in 2's complement
        A = 16'b110_0000_0000__00000;
        B = 16'b000_0001_0000__00000; // 16
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A * B should overflow negative
        $fwrite(output_file, "RESULT 6: %f * %f = %f (should overflow negative: -1023.9999)\n", A *0.03125, B *0.03125, result);
        #20;


        // A = -30.5 (30.5 = 000_0001_1110__10000 => -30.5 = 1111 1100 0011 0000)
        A = 16'b1111_1100_0011_0000;
        B = 16'b000_0000_0100__01000; // 4.25
        enable = 1;

        #20;
        enable = 0;
        #20;

        // A * B = -129.625
        $fwrite(output_file, "RESULT 7: %f * %f = %f (expecting -129.625)\n", A *0.03125, B *0.03125, result);
        #20;

        enable = 1;
        A = 16'b1111_1100_0011_0000; // -30.5
        B = 16'b1111_1111_0111_1000; // -4.25

        #20;
        #20;
        $fwrite(output_file, "RESULT 7: %f * %f = %f (expecting 129.625)\n", A *0.03125, B *0.03125, result);
    end
endmodule