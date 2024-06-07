`timescale 1ns/1ps
module testbench;
    reg clk = 0, adc_data_valid = 0, start = 0, reset = 0;
    reg [11:0] adc_data;
    
    `include "../include/dpram.sv"
    `include "../include/wait_clk.sv"
    
    parameter FFT_LENGTH = 1024;
    localparam MAXIMAS_COUNT = 10;
    integer i;
    integer inputReal;
    integer inputImag;
    integer input_file;
    integer most_signifcant_frequencies_file, maximas_file, magnitudes_file;

    wire mosi, cs, sclk;
    shazam #(.MAXIMAS_COUNT(MAXIMAS_COUNT)) SHAZAM (
        .MAX10_CLK1_50(clk),
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
        
        most_signifcant_frequencies_file = $fopen("../../../test/Shazam/data/most_significant_frequencies.txt", "w");
        maximas_file = $fopen("../../../test/Shazam/data/maximas_frequencies_and_magnitudes.txt", "w");
        magnitudes_file = $fopen("../../../test/Shazam/data/all_magnitudes.txt");
        input_file = $fopen("../../../test/data/inputs/arduino.txt", "r");

        for ( i = 0; i < 5 * FFT_LENGTH; i = i + 1 ) begin
                $fscanf(input_file, "%d,", inputReal);
                adc_data <= inputReal;
                adc_data_valid <= 1;

                wait_clk (1);
                
                adc_data_valid <= 0;
                wait_clk( 20 );
        end


    end

    integer maximas_index;
    always @(posedge SHAZAM.maximas_found_active) begin
        for(maximas_index = 0; maximas_index < MAXIMAS_COUNT; maximas_index = maximas_index + 1) begin
            $fwrite(maximas_file, "%d: %f\n", SHAZAM.maximas[maximas_index][24:16], SHAZAM.maximas[maximas_index][15:0]);
        end 
    end

    reg [9:0] magnitude_index = 0;
    reg [3:0] fft_count = 0;
    
    always @(posedge SHAZAM.SHAZAM_ANALYZE_SOUNDS.magnitude_ready) begin
            if(magnitude_index == 511) fft_count = fft_count + 1;

            if(magnitude_index == 0) $fwrite(magnitudes_file, "\n=============MAGNITUDES FROM FFT %d:============\n", fft_count);
            else $fwrite(magnitudes_file, "%d: %f\n", magnitude_index, SHAZAM.SHAZAM_ANALYZE_SOUNDS.magnitude[15:0]);
            
            magnitude_index <= magnitude_index + 1;
    end

    reg [2:0] index = 0;
    reg [3:0] samples = 0;
    reg [9:0] number = 0;

    always @ (negedge sclk) begin
        if(!cs) begin
            if(samples == MAXIMAS_COUNT) begin
                samples <= 0;
                $fwrite(most_signifcant_frequencies_file, "\n===========================================\n");
            end 
            if(index == 7) begin
                samples <= samples + 1;
                $fwrite(most_signifcant_frequencies_file, "%d, ", number * 2);
                number <= 0;
                index <= 0;
            end 
            number[7 - index] <= mosi;
            index <= index + 1;
        end
    end

endmodule
