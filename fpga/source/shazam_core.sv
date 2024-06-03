module shazam_core (
    input clk,
    input [11:0] adc_data,
    input adc_data_valid,
    input start,
    input reset,
    output [24:0] maximas [15:0],
    output wire maximas_found_active
);

   wire write_active_FFT_0, write_active_FFT_1, write_active_FFT_2;
   adc_measurements_to_FFT SELECT_AVAILABLE_FFT (
        .clk(clk),
        .reset(reset || !start),
        .adc_input_valid(adc_data_valid),
        .write_active_FFT_0(write_active_FFT_0),
        .write_active_FFT_1(write_active_FFT_1),
        .write_active_FFT_2(write_active_FFT_2)
   );

   wire FFT_0_all_done, FFT_1_all_done, FFT_2_all_done;
   wire [11:0] fft_input_from_adc;
   
   assign fft_input_from_adc = adc_data;

   reg [24:0] magnitude;
   reg magnitude_ready;
   reg [8:0] index = 0;

   assign magnitude_out = magnitude;
   assign magnitude_ready_out = magnitude_ready;
   assign index_out = index;

   wire magnitude_FFT_0_ready, magnitude_FFT_1_ready, magnitude_FFT_2_ready; 
   wire [15:0] magnitude_FFT_0, magnitude_FFT_1, magnitude_FFT_2; 
   reg all_magnitudes_ready;
   reg start_find_peaks = 0;
   
   always @(posedge clk) begin
      if(reset) begin
         all_magnitudes_ready <= 0;
         magnitude_ready <= 0;
         start_find_peaks <= 0;
         index <= 0;
         magnitude <= {25{1'b0}};
      end 
      else begin
         if(magnitude_FFT_0_ready == 1) begin
            magnitude_ready <= 1;
            magnitude <= {index, magnitude_FFT_0};
            index <= index + 1;
            all_magnitudes_ready <= index == 511;
         end  
         else if(magnitude_FFT_1_ready == 1) begin
            magnitude_ready <= 1;
            magnitude <= {index, magnitude_FFT_1};
            index <= index + 1;
            all_magnitudes_ready <= index == 511;
         end
         else if(magnitude_FFT_2_ready == 1) begin
            magnitude_ready <= 1;
            magnitude <= {index, magnitude_FFT_2};
            all_magnitudes_ready <= index == 511;
            index <= index + 1;

         end
         else magnitude_ready <= 0;

         if(all_magnitudes_ready == 1) begin 
            all_magnitudes_ready <= 0;
            start_find_peaks <= 1;
         end

         if(start_find_peaks == 1) start_find_peaks <= 0;
      end

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
        .input_real_i({fft_input_from_adc, 1'b0, 1'b0, 1'b0, 1'b0}),
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
        .input_real_i({fft_input_from_adc, 1'b0, 1'b0, 1'b0, 1'b0}),
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
        .input_real_i({fft_input_from_adc, 1'b0, 1'b0, 1'b0, 1'b0}),
        .input_imaginary_i(0),
        .index(index),
        .magnitude(magnitude_FFT_2),
        .magnitude_ready(magnitude_FFT_2_ready)
   );

   find_maximas FIND_MAXIM_MAGNITUDE (
      .clk(clk),
      .reset(reset),
      .load(magnitude_ready),
      .data_in(magnitude),
      .start(start_find_peaks),
      .data_out(maximas),
      .output_active(maximas_found_active)
   );
endmodule