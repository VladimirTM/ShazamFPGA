module ADC_samples (
    input clk,
    input reset,
    output [11:0] adc_data,
    output adc_data_valid
);

   wire clk_2MHz_wire, clk_2MHz_locked;
   clk_2MHz clk_2MHz_INSTANCE (
	   .inclk0(clk),
	   .c0(clk_2MHz_wire),
	   .locked(clk_2MHz_locked)
   );

   wire[11:0] response_data;
   wire response_valid;

   reg  adc_data_valid_reg = 0;
   reg[11:0] adc_data_reg = 0;
   assign adc_data = adc_data_reg;
   assign adc_data_valid = adc_data_valid_reg;

    always @(posedge clk) begin
        if(reset) begin 
            adc_data_reg <= 0;
            adc_data_valid_reg <= 0;
        end 
        if(response_valid) begin
            adc_data_valid_reg <= 1;
            adc_data_reg <= response_data;
        end 
        else begin
            adc_data_valid_reg <= 0;
        end 
    end 

   ADC ADC_INSTANCE (
      .adc_pll_clock_clk(clk_2MHz_wire),
      .adc_pll_locked_export(clk_2MHz_locked),
      .clock_clk(clk),
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

endmodule