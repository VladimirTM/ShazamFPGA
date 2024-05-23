module adc_measurements_to_FFT (
    input clk,
    input rst,
    output write_active_FFT_0,
    output write_active_FFT_1,
    output write_active_FFT_2,
    output write_active_FFT_3
);

    reg[15:0]   adc_input_real;
    reg         input_active;
    reg [14:0]  sample_count;
    reg         completed_first_iteration = 0;

    reg write_active_FFT_0_reg = 0;
    reg write_active_FFT_1_reg = 0;
    reg write_active_FFT_2_reg = 0;
    reg write_active_FFT_3_reg = 0;

    assign write_active_FFT_0 = write_active_FFT_0_reg;
    assign write_active_FFT_1 = write_active_FFT_1_reg;
    assign write_active_FFT_2 = write_active_FFT_2_reg;
    assign write_active_FFT_3 = write_active_FFT_3_reg;
    
    // recording data at 25k samples/second, but we will only use 24,576 samples (for 24 FFTs).
    // this leaves less than 512 samples unused in each second 
    
    always @ (posedge clk) begin
        if(input_active) begin
            if(sample_count == 2047) begin 
                sample_count <= 0;
                completed_first_iteration <= 1;
            end 

            if(sample_count >= 0 && sample_count < 512) begin
                if(!completed_first_iteration) begin
                    write_active_FFT_0_reg <= 1;
                end
                else begin
                    write_active_FFT_0_reg <= 1;
                    write_active_FFT_1_reg <= 1;
                end 
            end
            else if(sample_count > 511 && sample_count < 1024) begin
                if(!completed_first_iteration) begin
                    write_active_FFT_0_reg <= 1;
                    write_active_FFT_1_reg <= 1;
                end 
                else begin
                    write_active_FFT_1_reg <= 1;
                    write_active_FFT_2_reg <= 1;
                end 
            end 
            else if (sample_count > 1023 && sample_count < 1536) begin
                if(!completed_first_iteration) begin
                    write_active_FFT_1_reg <= 1;
                    write_active_FFT_2_reg <= 1;
                end
                else begin 
                    write_active_FFT_2_reg <= 1;
                    write_active_FFT_3_reg <= 1;
                end
            else if (sample_count > 1535 && sample_count < 2048) begin
                    if(!completed_first_iteration) begin
                        write_active_FFT_2_reg <= 1;
                        write_active_FFT_3_reg <= 1;
                    end 
                    else begin
                        write_active_FFT_3_reg <= 1;
                        write_active_FFT_0_reg <= 1;
                    end 
                end 
            end 
        end
        else begin 
            write_active_FFT_0_reg <= 0;
            write_active_FFT_1_reg <= 0;
            write_active_FFT_2_reg <= 0;
            write_active_FFT_3_reg <= 0;
        end     
    end
endmodule