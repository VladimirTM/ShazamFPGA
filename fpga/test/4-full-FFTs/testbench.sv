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
    
    reg [7:0] EXP = 8'b0000_0111; // 5 
    localparam FREQUENCY_HOP = 9.76; 

    integer inputReal;
    integer inputImag;
    integer input_file;
    integer i, j;
    integer output_file;
    integer magnitudes_raw;

    wire [15:0] P1, P2, real_part, imag_part;
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
        
        output_file = $fopen("../../../data/outputs/output_testbench_4_FFTs.txt", "w");
        magnitudes_raw = $fopen("../../../data/magnitudes/magnitudes_raw_testbench_4_FFTs.txt", "w");
        input_file = $fopen("../../../data/inputs/arduino_input.txt", "r");

        for ( i = 0; i < 1 * FFT_LENGTH; i = i + 1 ) begin
                $fscanf(input_file, "%d,", inputReal);
                
                adc_data <= inputReal;
                adc_data_valid <= 1;
                
                $fwrite(output_file, "REAL DATA: %d, IMAGINARY DATA: %d\n", inputReal, inputImag);
                wait_clk (1);
                
                adc_data_valid <= 0;
                wait_clk( 20 );
        end


    end

    always @ (posedge magnitude_ready) begin
        if(i == 1) $fwrite(magnitudes_raw, "\n\n");
        $fwrite(magnitudes_raw, "%f, ", magnitude * 0.0078125);
    end

endmodule
