
module ADC_show_data (
      output            [11:0]         adc_data,
      output            [15:0]         time_between_2_ADC_reads,
      
      ///////// Clocks /////////
      input              clk,

      ///////// HEX /////////
      output   [7:0]   HEX0,
      output   [7:0]   HEX1,
      output   [7:0]   HEX2,
      output   [7:0]   HEX3,
      output   [7:0]   HEX4,
      output   [7:0]   HEX5

   );
   
   wire clk_2MHz_wire, clk_2MHz_locked;
   clk_2MHz clk_2MHz_INSTANCE (
	   .inclk0(clk),
	   .c0(clk_2MHz_wire),
	   .locked(clk_2MHz_locked)
   );

   wire [11:0] response_data /* synthesis noprune */;
   wire response_valid/* synthesis keep */;
   
   reg adc_sample_data_valid /* synthesis noprune */;
   reg [11:0] adc_sample_data /* synthesis noprune */;
   reg [12:0] vol /* synthesis noprune */;
   assign adc_data = adc_sample_data;

   assign time_between_2_ADC_reads = time_between_2_ADC_reads_reg;
   reg [15:0] time_between_2_ADC_reads_reg = 0; // counter can go up to 2^17 - 1
   reg start_count = 0;

    always @ (posedge clk)
    begin
        if (response_valid)
        begin
            start_count <= ~start_count;
            time_between_2_ADC_reads_reg <= 1;
            adc_sample_data <= response_data;
            vol <= response_data * 2 * 2500 / 4095;
            adc_sample_data_valid <= 1;
        end
        else adc_sample_data_valid <= 0;

        if(start_count) begin
            time_between_2_ADC_reads_reg <= time_between_2_ADC_reads_reg + 1;
        end

        if(!start_count) begin
            time_between_2_ADC_reads_reg <= 0;
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
      .reset_sink_reset_n(1),
      .response_valid(response_valid),
      .response_channel(),
      .response_data(response_data),
      .response_startofpacket(),
      .response_endofpacket()
   );


   assign HEX5[7] = 1'b1; // low active
   assign HEX4[7] = 1'b1; // low active
   assign HEX3[7] = 1'b0; // low active
   assign HEX2[7] = 1'b1; // low active
   assign HEX1[7] = 1'b1; // low active
   assign HEX0[7] = 1'b1; // low active

   SEG7_LUT	SEG7_LUT_ch (
      .oSEG(HEX5),
      .iDIG(4'b0001)
   );

   assign HEX4 = 8'b10111111;

   SEG7_LUT	SEG7_LUT_v (
      .oSEG(HEX3),
      .iDIG(vol/1000)
   );

   SEG7_LUT	SEG7_LUT_v_1 (
      .oSEG(HEX2),
      .iDIG(vol/100 - (vol/1000)*10)
   );

   SEG7_LUT	SEG7_LUT_v_2 (
      .oSEG(HEX1),
      .iDIG(vol/10 - (vol/100)*10)
   );

   SEG7_LUT	SEG7_LUT_v_3 (
      .oSEG(HEX0),
      .iDIG(vol - (vol/10)*10)
   );
endmodule 
