module Shazam (
    input MAX10_CLK1_50,
    input reset
);

   wire clk_2MHz_wire, clk_2MHz_locked;
   clk_2MHz clk_2MHz_INSTANCE (
	   .inclk0(MAX10_CLK1_50),
	   .c0(clk_2MHz_wire),
	   .locked(clk_2MHz_locked)
   );

   wire[11:0] adc_data;
   wire response_valid;

   ADC ADC_INSTANCE (
      .adc_pll_clock_clk(clk_2MHz_wire),
      .adc_pll_locked_export(clk_2MHz_locked),
      .clock_clk(MAX10_CLK1_50),
      .command_valid(1),
      .command_channel(1),
      .command_startofpacket(1),
      .command_endofpacket(1),
      .command_ready(),
      .reset_sink_reset_n(~reset),
      .response_valid(response_valid),
      .response_channel(),
      .response_data(response_data),
      .response_startofpacket(),
      .response_endofpacket()
   );

    wire write_active_FFT_0, write_active_FFT_1, write_active_FFT_2, write_active_FFT_3;
   adc_measurements_to_FFT SELECT_AVAILABLE_FFT (
        .clk(clk),
        .reset(reset),
        .write_active_FFT_0(write_active_FFT_0),
        .write_active_FFT_1(write_active_FFT_1),
        .write_active_FFT_2(write_active_FFT_2),
        .write_active_FFT_3(write_active_FFT_3)
   );

   // reg FFT_0_done, FFT_1_done, FFT_2_done, FFT_3_done;
   // reg [7:0] exponent_FFT_0, ;
   
   // reg [16:0] magnitudes_FFT_0 [1023:0];
   // FFT_IMPLEMENTATION FFT_0 (
   //      .clk(clk),
   //      .reset(reset),
   //      .done(FFT_0_done),
   //      .input_stream_active_i(write_active_FFT_0),
   //      .input_real_i({adc_data[11], 0, 0, 0, 0, adc_data[10:0]}),
   //      .input_imaginary_i(0),
   //      .
   //      .dmaact(),
   //      .dmaa()
   // );
   // FFT_IMPLEMENTATION FFT_1 ();
   // FFT_IMPLEMENTATION FFT_2 ();
   // FFT_IMPLEMENTATION FFT_3 ();


endmodule