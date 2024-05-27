`timescale 1ns/1ps
module testbench;
    reg clk = 0, adc_data_valid = 0, start = 0, reset = 0;
    reg [11:0] adc_data;
    
    `include "../include/dpram.sv"
    `include "../include/wait_clk.sv"
    
    parameter FFT_LENGTH = 1024;

    wire [15:0] magnitude;
    wire magnitude_ready;
    wire [10:0] index;
    
    reg signed [7:0] EXP = 8'b1111_1010; // -6
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
        .magnitude_out(magnitude),
        .magnitude_ready_out(magnitude_ready),
        .index_out(index)
    );

    initial begin 
        reset = 1;
        wait_clk( 20 );
        reset = 0;
        wait_clk( 4000 );

        start = 1;
        
        output_file = $fopen("output_testbench_after_hardcoded_5_bfpexp.txt", "w");
        magnitudes_raw = $fopen("magnitudes_raw_after_hardcoded_5_bfpexp.txt", "w");
        input_file = $fopen("arduino_input.txt", "r");

        for ( i = 0; i < 21 * FFT_LENGTH; i = i + 1 ) begin
                $fscanf(input_file, "%d,", inputReal);
                
                adc_data <= inputReal;
                adc_data_valid <= 1;
                
                $fwrite(output_file, "REAL DATA: %d, IMAGINARY DATA: %d\n", inputReal, inputImag);
                wait_clk (1);
                
                adc_data_valid <= 0;
                wait_clk( 20 );
        end


        $fwrite(output_file, "FFT RESULT FROM FFT: $d:\n", j);
    end

    always @ (posedge magnitude_ready) begin
        $fwrite(magnitudes_raw, "%f, ", $sqrt(magnitude * (2.0**EXP)));
        $fwrite(output_file, "%d. MAGNITUDE: %f\n", FREQUENCY_HOP * index, $sqrt(magnitude * (2.0**EXP)));
    end

endmodule
