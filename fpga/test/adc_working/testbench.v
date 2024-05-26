`timescale 1ns/1ps
module testbench;

    reg clk = 0, reset = 0;
    wire [11:0] adc_data;
    always #1 clk = ~clk;
    

   wire clk_10MHz_wire, clk_10MHz_locked;
   clk_10MHz CLK_10MHZ_INSTANCE (
	   .inclk0(clk),
	   .c0(clk_10MHz_wire),
	   .locked(clk_10MHz_locked)
   );

   ADC ADC_INSTANCE (
      .adc_pll_clock_clk(clk_10MHz_wire),
      .adc_pll_locked_export(clk_10MHz_locked),
      .clock_clk(clk),
      .command_valid(1),
      .command_channel(0),
      .command_startofpacket(1),
      .command_endofpacket(1),
      .command_ready(),
      .reset_sink_reset_n(~reset),
      .response_valid(),
      .response_channel(),
      .response_data(adc_data),
      .response_startofpacket(),
      .response_endofpacket()
   );

   initial begin
    reset = 1;

    #15;

    reset = 0;

    #15;
   end

endmodule 