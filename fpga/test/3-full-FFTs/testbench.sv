`timescale 1ns/1ps
module testbench;
    reg clk = 0, adc_data_valid = 0, start = 0, reset = 0;
    reg [11:0] adc_data;
    
    `include "../include/dpram.sv"
    `include "../include/wait_clk.sv"
    
    parameter FFT_LENGTH = 1024;

    reg [15:0] magnitude;
    reg magnitude_ready;
    reg [8:0] index;
    reg FFT_0_all_done; 
    
    integer inputReal;
    integer inputImag;
    integer input_file;
    integer i;
    integer output_file;
    integer magnitudes_raw;

    shazam_core SHAZAM_CORE (
        .clk(clk),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid),
        .start(start),
        .reset(reset)
    );

    initial begin 
        reset = 1;
        wait_clk( 20 );
        reset = 0;
        wait_clk( 4000 );

        start = 1;
        
        output_file = $fopen("../../../data/outputs/output_testbench_3_FFTs.txt", "w");
        magnitudes_raw = $fopen("../../../data/magnitudes/magnitudes_raw_testbench_3_FFTs.txt", "w");
        input_file = $fopen("../../../data/inputs/arduino_input.txt", "r");

        for ( i = 0; i < FFT_LENGTH * 2; i = i + 1 ) begin
            $fscanf(input_file, "%d,", inputReal);
            
            adc_data <= inputReal;
            adc_data_valid <= 1;
            
            $fwrite(output_file, "REAL DATA: %f, IMAGINARY DATA: %d\n", adc_data, inputImag);
            if(i == FFT_LENGTH) $fwrite(output_file, "\n=====================FFT 1====================\n");
            
            wait_clk (1);
            
            adc_data_valid <= 0;
            wait_clk( 20 );
        end


    end

    always @ (posedge SHAZAM_CORE.FFT_0_all_done) begin
        FFT_0_all_done = SHAZAM_CORE.FFT_0_all_done;
        $fwrite(magnitudes_raw, "\n==============FFT 1================\n");
    end
    
    always @ (posedge SHAZAM_CORE.FFT_1_all_done) begin
        $fwrite(magnitudes_raw, "\n==============FFT 2================\n");
    end 

    always @ (posedge SHAZAM_CORE.FFT_2_all_done) begin
        $fwrite(magnitudes_raw, "\n==============FFT 0================\n");
    end 

    
    
    always @ (posedge SHAZAM_CORE.magnitude_ready) begin
        magnitude = SHAZAM_CORE.magnitude[15:0];
        magnitude_ready = SHAZAM_CORE.magnitude_ready;
        index = SHAZAM_CORE.index;
        $fwrite(magnitudes_raw, "%f, ", SHAZAM_CORE.magnitude[15:0]);
    end

endmodule
