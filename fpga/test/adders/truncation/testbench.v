`timescale 1ns/1ps
module testbench;
    reg signed [15:0] A;
    reg signed [15:0] B;
    wire signed [15:0] result;
    reg signed [16:0] result_v;
    reg enable = 0;
    
    reg clk = 0;
    always #10 clk = ~clk;

    parameter EXP = 0.00390625; // 2^-8
    
    fixed_point_truncation_adder ADDER_INSTANCE (
        .clk(clk),
        .enable(enable),
        .A(A),
        .B(B),
        .sum(result)
    );

    integer output_file, i = 0;

    initial begin
        output_file = $fopen("../../../test/adders/data/truncation_adder.txt", "w");

        for(i = 0; i < 10_000; i = i + 1) begin 
                A = $random % 65_535;
                B = $random % 65_535;
                enable = 1;
                #20; // wait 1 period
                #20; // wait 1 period
                $fwrite(output_file, "RESULT %d: %f + %f = %f (EXPECTING: %f)\n", i, A * EXP, B * EXP, result * EXP, (A+B)* EXP);
                enable = 0;
                i = i + 1;
                #20; // wait 1 period
            end 

        $fclose(output_file);
    end
endmodule