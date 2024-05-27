module shazam_core (
    input clk,
    input [11:0] adc_data,
    input adc_data_valid,
    input start,
    input reset,
    output [15:0] magnitude_out,
    output magnitude_ready_out,
    output [10:0] index_out
);

   wire write_active_FFT_0, write_active_FFT_1, write_active_FFT_2, write_active_FFT_3;
   adc_measurements_to_FFT SELECT_AVAILABLE_FFT (
        .clk(clk),
        .reset(reset || !start),
        .adc_input_valid(adc_data_valid),
        .write_active_FFT_0(write_active_FFT_0),
        .write_active_FFT_1(write_active_FFT_1),
        .write_active_FFT_2(write_active_FFT_2),
        .write_active_FFT_3(write_active_FFT_3)
   );

   wire FFT_0_all_done, FFT_1_all_done, FFT_2_all_done, FFT_3_all_done;

   reg [15:0] magnitude;
   reg magnitude_ready;
   reg [10:0] index = 0;

   assign magnitude_out = magnitude;
   assign magnitude_ready_out = magnitude_ready;
   assign index_out = index;

   wire magnitude_FFT_0_ready, magnitude_FFT_1_ready, magnitude_FFT_2_ready, magnitude_FFT_3_ready; 
   wire [15:0] magnitude_FFT_0, magnitude_FFT_1, magnitude_FFT_2, magnitude_FFT_3; 
   reg [15:0] magnitudes [1023:0];
   
   always @(posedge clk) begin
      if(magnitude_FFT_0_ready == 1) begin
         magnitude_ready <= 1;
         magnitude <= magnitude_FFT_0;
         index <= index == 1023 ? 0 : index + 1;
         magnitudes[index] <= magnitude;
      end  
      else if(magnitude_FFT_1_ready == 1) begin
         magnitude_ready <= 1;
         magnitude <= magnitude_FFT_1;
         index <= index == 1023 ? 0 : index + 1;
         magnitudes[index] <= magnitude;
      end
      else if(magnitude_FFT_2_ready == 1) begin
         magnitude_ready <= 1;
         magnitude <= magnitude_FFT_2;
         index <= index == 1023 ? 0 : index + 1;
         magnitudes[index] <= magnitude;
      end  
      else if(magnitude_FFT_3_ready == 1) begin
         magnitude_ready <= 1;
         magnitude <= magnitude_FFT_3;
         index <= index == 1023 ? 0 : index + 1;
         magnitudes[index] <= magnitude;
      end
      else magnitude_ready <= 0;

   end 

   reg reset_FFT_0 = 0;
   always @(posedge clk) begin
      if(reset || !start) reset_FFT_0 = 1;
      else if(FFT_0_all_done) reset_FFT_0 = 1;
      else reset_FFT_0 = 0; 
   end

   FFT_IMPLEMENTATION FFT_0 (
        .clk(clk),
        .reset(reset_FFT_0),
        .done_all_processing(FFT_0_all_done),
        .input_stream_active_i(write_active_FFT_0),
        .input_real_i({adc_data[11], 1'b0, 1'b0, 1'b0, 1'b0, adc_data[10:0]}),
        .input_imaginary_i(0),
        .index(index),
        .magnitude(magnitude_FFT_0),
        .magnitude_ready(magnitude_FFT_0_ready)
   );

   reg reset_FFT_1 = 0;
   always @(posedge clk) begin
      if(reset || !start) reset_FFT_1 = 1;
      else if(FFT_1_all_done) reset_FFT_1 = 1;
      else reset_FFT_1 = 0; 
   end
   
   FFT_IMPLEMENTATION FFT_1 (
        .clk(clk),
        .reset(reset_FFT_1),
        .done_all_processing(FFT_1_all_done),
        .input_stream_active_i(write_active_FFT_1),
        .input_real_i({adc_data[11], 1'b0, 1'b0, 1'b0, 1'b0, adc_data[10:0]}),
        .input_imaginary_i(0),
        .index(index),
        .magnitude(magnitude_FFT_1),
        .magnitude_ready(magnitude_FFT_1_ready)
   );


   reg reset_FFT_2 = 0;
   always @(posedge clk) begin
      if(reset || !start) reset_FFT_2 = 1;
      else if(FFT_2_all_done) reset_FFT_2 = 1;
      else reset_FFT_2 = 0; 
   end
   
   FFT_IMPLEMENTATION FFT_2 (
        .clk(clk),
        .reset(reset_FFT_2),
        .done_all_processing(FFT_2_all_done),
        .input_stream_active_i(write_active_FFT_2),
        .input_real_i({adc_data[11], 1'b0, 1'b0, 1'b0, 1'b0, adc_data[10:0]}),
        .input_imaginary_i(0),
        .index(index),
        .magnitude(magnitude_FFT_2),
        .magnitude_ready(magnitude_FFT_2_ready)
   );
   
   
   reg reset_FFT_3 = 0;
   always @(posedge clk) begin
      if(reset || !start) reset_FFT_3 = 1;
      else if(FFT_3_all_done) reset_FFT_3 = 1;
      else reset_FFT_3 = 0; 
   end
   
   FFT_IMPLEMENTATION FFT_3 (
        .clk(clk),
        .reset(reset_FFT_3),
        .done_all_processing(FFT_3_all_done),
        .input_stream_active_i(write_active_FFT_3),
        .input_real_i({adc_data[11], 1'b0, 1'b0, 1'b0, 1'b0, adc_data[10:0]}),
        .input_imaginary_i(0),
        .index(index),
        .magnitude(magnitude_FFT_3),
        .magnitude_ready(magnitude_FFT_3_ready)
   );
endmodule