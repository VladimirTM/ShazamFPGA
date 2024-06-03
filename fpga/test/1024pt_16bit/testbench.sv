`timescale 1ns/1ps
module testbench;
    reg clk = 0, adc_data_valid = 0, start = 0, reset = 0;
    reg [11:0] adc_data;
    real M_PI = 3.1415926535897932384626433832795029;
    
    `include "../include/dpram.sv"
    `include "../include/wait_clk.sv"
    `include "../include/to_signed_int.sv"
    
    parameter FFT_LENGTH = 1024;
    localparam EXP = 0.0625;

    integer inputReal;
    integer inputImag;
    integer input_file;
    integer i = 0, j = 0, k = 0;
    integer output_file;
    integer magnitudes_raw, magnitudes_fixed, verify_products, verify_input;

    wire signed [15:0] fft_real_output, fft_imag_output;
    wire [15:0] real_x_real, imag_x_imag;
    wire done_FFT, dmadr_ready, can_read_products, magnitude_ready;
    reg [9:0] index = 0;
    reg [9:0] index_1 = 0;
    wire [15:0] magnitude;
    
    FFT_IMPLEMENTATION fft_0 (
        .clk(clk),
        .input_stream_active_i(adc_data_valid),
        // change test here (make unsigned default)
        .input_real_i({adc_data, 1'b0, 1'b0, 1'b0, 1'b0}),
        .input_imaginary_i({16{1'b0}}),
        .reset(reset || !start),
        .index(index),
        .dmadr_real_output(fft_real_output),
        .dmadr_imag_output(fft_imag_output),
        .dmadr_ready(dmadr_ready),
        .done_FFT(done_FFT),
        .P1_out(real_x_real),
        .P2_out(imag_x_imag),
        .P_active(can_read_products),
        .magnitude(magnitude),
        .magnitude_ready(magnitude_ready)
    );

    initial begin 
        reset = 1;
        wait_clk( 20 );
        reset = 0;
        wait_clk( 4000 );

        start = 1;
        
        output_file = $fopen("../../../data/outputs/output_1_FFT.txt", "w");
        magnitudes_fixed = $fopen("../../../data/magnitudes/magnitudes_computed_fix.txt", "w");
        verify_products = $fopen("../../../data/magnitudes/verify_products_by_fixed_arithmetic.txt", "w");
        input_file = $fopen("../../../data/inputs/arduino_input.txt", "r");
        verify_input = $fopen("../../../data/outputs/verify_1_FFT_input.txt", "w");
        for ( i = 0; i < FFT_LENGTH; i = i + 1 ) begin
                $fscanf(input_file, "%d,", inputReal);

                adc_data = inputReal;
                adc_data_valid = 1;

                $fwrite(verify_input, "%f, ", inputReal * 0.000030517578125);
                
                $fwrite(output_file, "REAL DATA: %d, IMAGINARY DATA: %d\n", inputReal, 0);
                wait_clk (1);
                
                adc_data_valid <= 0;
                wait_clk( 20 );
        end

        while(!done_FFT) #20;
        
        $fwrite(output_file, "\n========FFT_OUTPUT:=========\n");
    end

    always @ (posedge clk) begin
        if(magnitude_ready) begin
            $fwrite(magnitudes_fixed, "%f,", magnitude);
            index_1 <= index_1 + 1;
        end 
        
        if(dmadr_ready) begin
            // checking that the result should be mirrored
            $fwrite(output_file, "%d. OUTPUT REAL: %f, OUTPUT IMAG: %f, MAGNITUDE: %f\n", index, fft_real_output *  EXP, fft_imag_output *  EXP, ((fft_real_output *  EXP * fft_real_output *  EXP) + (fft_imag_output * EXP * fft_imag_output *  EXP)));
            index <= index + 1;
        end 
    end 

endmodule
