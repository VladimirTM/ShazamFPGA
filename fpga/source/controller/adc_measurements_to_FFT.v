module adc_measurements_to_FFT (
    input clk,
    input reset,
    input adc_input_valid,
    output wire write_active_FFT_0,
    output wire write_active_FFT_1,
    output wire write_active_FFT_2
);

    reg [14:0]  sample_count = 0;
    reg         completed_first_iteration = 0;

    reg write_active_FFT_0_reg = 0;
    reg write_active_FFT_1_reg = 0;
    reg write_active_FFT_2_reg = 0;

    assign write_active_FFT_0 = write_active_FFT_0_reg;
    assign write_active_FFT_1 = write_active_FFT_1_reg;
    assign write_active_FFT_2 = write_active_FFT_2_reg;
    
    always @ (posedge clk) begin
        if(reset) begin
            sample_count <= 0;
            write_active_FFT_0_reg <= 0;
            write_active_FFT_1_reg <= 0;
            write_active_FFT_2_reg <= 0;
        end 
        else begin      
            if(adc_input_valid) begin
                sample_count <= sample_count + 1;  

                if(sample_count == 1535) begin 
                    sample_count <= 0;
                    completed_first_iteration <= 1;
                end 

                if(sample_count >= 0 && sample_count < 512) begin
                    if(!completed_first_iteration) begin
                        write_active_FFT_0_reg <= 1;
                    end
                    else begin
                        write_active_FFT_2_reg <= 1;
                        write_active_FFT_0_reg <= 1;
                    end 
                end
                else if(sample_count >= 512 && sample_count < 1024) begin
                    if(!completed_first_iteration) begin
                        write_active_FFT_0_reg <= 1;
                        write_active_FFT_1_reg <= 1;
                    end 
                    else begin
                        write_active_FFT_0_reg <= 1;
                        write_active_FFT_1_reg <= 1;
                    end 
                end 
                else if (sample_count >= 1024 && sample_count < 1536) begin
                    if(!completed_first_iteration) begin
                        write_active_FFT_1_reg <= 1;
                        write_active_FFT_2_reg <= 1;
                    end
                    else begin 
                        write_active_FFT_1_reg <= 1;
                        write_active_FFT_2_reg <= 1;
                    end
                end
                end 
            else begin 
                write_active_FFT_0_reg <= 0;
                write_active_FFT_1_reg <= 0;
                write_active_FFT_2_reg <= 0;
            end     
        end 
    end
endmodule