`timescale 1ns/1ps
module testbench;
    reg clk = 0, adc_data_valid = 0, start = 0, reset = 0;
    reg [11:0] adc_data;
    
    `include "../include/dpram.sv"
    `include "../include/wait_clk.sv"
    
    parameter FFT_LENGTH = 1024;

    wire [24:0] maximas [15:0];
    wire maximas_found_active;
    
    localparam FREQUENCY_HOP = 9.76; 

    integer inputReal;
    integer inputImag;
    integer input_file;
    integer i, j;
    integer output_file;
    integer magnitudes_raw;

    shazam_core SHAZAM_CORE (
        .clk(clk),
        .adc_data_valid(adc_data_valid),
        .start(start),
        .reset(reset),
        .adc_data(adc_data),
        .maximas(maximas),
        .maximas_found_active(maximas_found_active)
    );

    initial begin 
        reset = 1;
        wait_clk( 20 );
        reset = 0;
        wait_clk( 4000 );

        start = 1;
        
        output_file = $fopen("../../../data/outputs/magnitudes_compared.txt", "w");
        magnitudes_raw = $fopen("../../../data/magnitudes/MAGNITUDES_COMPARED_4_FFTS.txt", "w");
        input_file = $fopen("../../../data/inputs/arduino_input.txt", "r");

        for ( i = 0; i < 2 * FFT_LENGTH; i = i + 1 ) begin
                $fscanf(input_file, "%d,", inputReal);
                
                adc_data <= inputReal;
                adc_data_valid <= 1;
                
                wait_clk (1);
                
                adc_data_valid <= 0;
                wait_clk( 20 );
        end
    end

    always @ (posedge maximas_found_active) begin
        for(j = 0; j < 16; j++) begin
            // $fwrite(magnitudes_raw, "%f, ", maximas[j][15:0]);
            $fwrite(magnitudes_raw, "%d. %f,\n", maximas[j][24:16], maximas[j][15:0]);
        end
    end

endmodule
