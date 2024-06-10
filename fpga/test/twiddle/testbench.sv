`timescale 1ns/1ps
module testbench;
    reg clk = 0, adc_data_valid = 0, start = 0, reset = 0;
    reg [11:0] adc_data;
    
    `include "../include/dpram.sv"
    `include "../include/wait_clk.sv"
    
    parameter FFT_LENGTH = 1024;
    integer i;
    integer twiddles, input_file, inputReal, radix2butterfly_output;

    localparam real EXP [0:10] = {0.000030517578125, 0.00006103515625, 0.0001220703125, 0.000244140625, 0.00048828125, 0.0009765625, 0.001953125, 0.00390625, 0.0078125, 0.015625, 0.03125};

    wire mosi, cs, sclk;
    shazam SHAZAM (
        .clk(clk),
        .reset(reset),
        .start(start),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid),
        .mosi(mosi),
        .cs(cs),
        .sclk(sclk)
    );

    initial begin 
        reset = 1;
        wait_clk( 20 );
        reset = 0;
        wait_clk( 4000 );

        start = 1;
        
        twiddles = $fopen("../../../test/twiddle/data/twiddles.txt", "w");
        radix2butterfly_output = $fopen("../../../test/twiddle/data/radix2butterfly/radix2.txt", "w");
        input_file = $fopen("../../../test/data/inputs/arduino.txt", "r");
        for ( i = 0; i < FFT_LENGTH; i = i + 1 ) begin
                $fscanf(input_file, "%d,", inputReal);
                adc_data <= inputReal;
                adc_data_valid <= 1;

                wait_clk (1);
                
                adc_data_valid <= 0;
                wait_clk( 20 );
        end


    end

    reg signed [15:0] cos, sin, abs_cos, abs_sin;
    reg compute_abs_cos = 0;
    wire done_abs_cos;
    fixed_point_multiplier ABS_COS (
        .clk(clk),
        .reset(reset),
        .enable(compute_abs_cos),
        .A(cos),
        .B(cos),
        .product(abs_cos),
        .done(done_abs_cos)
    );

    reg compute_abs_sin = 0;
    wire done_abs_sin;
    fixed_point_multiplier ABS_SIN (
        .clk(clk),
        .reset(reset),
        .enable(compute_abs_sin),
        .A(sin),
        .B(sin),
        .product(abs_sin),
        .done(done_abs_sin)
    );

    always @ (posedge clk) begin
        if(SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.twact) begin 
            cos = SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.tdr_rom_real;
            sin = SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.tdr_rom_imag;
            compute_abs_cos = 1;
            compute_abs_sin = 1;
            #20;
            #20;
            // the twiddles^2 will be 1 line delayed
            $fwrite(twiddles, "cos: %f, sin: %f, cos^2 = %f, sin^2 = %f\n", cos * EXP[0], sin * EXP[0], abs_cos * EXP[0], abs_sin * EXP[0]);
            compute_abs_cos = 0;
            compute_abs_sin = 0;
        end 
    end 

    genvar j;
    generate
        for (j = 0; j < 10; j = j + 1) begin : print_butterfly_stage
            reg wrote_stage_title = 0;
            reg signed [15:0] A_real, A_imag, B_real, B_imag, twiddle_real, twiddle_imag, out_A_real, out_A_imag, out_B_real, out_B_imag;
            reg signed [15:0] A_real_1, A_imag_1, B_real_1, B_imag_1, twiddle_real_1, twiddle_imag_1;
            reg signed [15:0] A_real_2, A_imag_2, B_real_2, B_imag_2, twiddle_real_2, twiddle_imag_2;
            reg signed [15:0] A_real_3, A_imag_3, B_real_3, B_imag_3, twiddle_real_3, twiddle_imag_3;
            reg signed [15:0] A_real_4, A_imag_4, B_real_4, B_imag_4, twiddle_real_4, twiddle_imag_4;
            reg signed [15:0] A_real_5, A_imag_5, B_real_5, B_imag_5, twiddle_real_5, twiddle_imag_5;
            reg signed [15:0] A_real_6, A_imag_6, B_real_6, B_imag_6, twiddle_real_6, twiddle_imag_6;
            reg [10:0] index = 0;


            always @ (posedge clk) begin
                if(SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.iact) begin 
                    if(!wrote_stage_title) $fwrite(radix2butterfly_output, "\n============ STAGE %d =============\n", j + 1);
                    wrote_stage_title <= 1;
                    A_real <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.A_real;
                    A_imag <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.A_imag;
                    B_real <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.B_real;
                    B_imag <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.B_imag;
                    twiddle_real <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.twiddle_real;
                    twiddle_imag <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.twiddle_imag;
                    out_A_real <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.out_A_real;
                    out_A_imag <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.out_A_imag;
                    out_B_real <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.out_B_real;
                    out_B_imag <= SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.out_B_imag;
                end 
            end

            always @ (posedge clk) begin
                A_real_1 <= A_real;
                A_imag_1 <= A_imag;
                B_real_1 <= B_real;
                B_imag_1 <= A_imag;
                twiddle_real_1 <= twiddle_real;
                twiddle_imag_1 <= twiddle_imag;

                A_real_2 <= A_real_1;
                A_imag_2 <= A_imag_1;
                B_real_2 <= B_real_1;
                B_imag_2 <= A_imag_1;
                twiddle_real_2 <= twiddle_real_1;
                twiddle_imag_2 <= twiddle_imag_1;

                A_real_3 <= A_real_2;
                A_imag_3 <= A_imag_2;
                B_real_3 <= B_real_2;
                B_imag_3 <= A_imag_2;
                twiddle_real_3 <= twiddle_real_2;
                twiddle_imag_3 <= twiddle_imag_2;

                A_real_4 <= A_real_3;
                A_imag_4 <= A_imag_3;
                B_real_4 <= B_real_3;
                B_imag_4 <= A_imag_3;
                twiddle_real_4 <= twiddle_real_3;
                twiddle_imag_4 <= twiddle_imag_3;

                A_real_5 <= A_real_4;
                A_imag_5 <= A_imag_4;
                B_real_5 <= B_real_4;
                B_imag_5 <= A_imag_4;
                twiddle_real_5 <= twiddle_real_4;
                twiddle_imag_5 <= twiddle_imag_4;

                A_real_6 <= A_real_5;
                A_imag_6 <= A_imag_5;
                B_real_6 <= B_real_5;
                B_imag_6 <= A_imag_5;
                twiddle_real_6 <= twiddle_real_5;
                twiddle_imag_6 <= twiddle_imag_5;
            end 

            always @ (posedge clk) begin
                if(SHAZAM.SHAZAM_ANALYZE_SOUNDS.FFT_0.uR2FFT.ubutterflyUnit.ubutterflyCore.radix2instances[j].uradix2bt.oact) begin
                    index <= index + 2;
                    $fwrite(radix2butterfly_output, "%d. A_OUT: (%f + j%f) + (%f + j%f) = %f + j%f\n", index + 1, A_real_6 * EXP[j], A_imag_6 * EXP[j], B_real_6 * EXP[j], B_imag_6 * EXP[j], out_A_real * EXP[j + 1], out_A_imag * EXP[j + 1]);
                    $fwrite(radix2butterfly_output, "%d. B_OUT: ((%f + j%f) - (%f + j%f)) * (%f + j%f) = %f + j%f\n", index + 2, A_real_6 * EXP[j], A_imag_6 * EXP[j], B_real_6 * EXP[j], B_imag_6 * EXP[j], twiddle_real_6* EXP[0], twiddle_imag_6* EXP[0], out_B_real* EXP[j + 1], out_B_imag* EXP[j + 1]);
                end 
            end
        end 
    endgenerate

endmodule
