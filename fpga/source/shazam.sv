module shazam (
    input MAX10_CLK1_50,
    input reset,
    input start,
    input [11:0] adc_data,
    input adc_data_valid,
    output mosi,
    output cs,
    output sclk
);
    wire [24:0] maximas [15:0];
    wire maximas_found_active;

    shazam_core SHAZAM_ANALYZE_SOUNDS (
        .clk(MAX10_CLK1_50),
        .reset(reset),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid),
        .start(start),
        .maximas(maximas),
        .maximas_found_active(maximas_found_active)
    );

   wire [8:0] significant_frequency;
   wire PISO_output_active;
   PISO parallel_in_serial_out (
      .clk(MAX10_CLK1_50),
      .reset(reset),
      .load(maximas_found_active),
      .data_in(maximas),
      .serial_out(significant_frequency),
      .output_active(PISO_output_active)
   );

   wire [8:0] frequency;
   wire fifo_empty, fifo_full;

   wire generated_sclk;
   assign sclk = generated_sclk;
   clk_4MHz CLK_4MHZ_INSTANCE (
      .inclk0(MAX10_CLK1_50),
      .c0(generated_sclk)
   );

   reg should_read, data_ready;
   reg [8:0] frequency_input_for_arduino;
   
   wire fifo_read_enable;
   
   always @ (negedge generated_sclk) begin
      if(reset) frequency_input_for_arduino <= 0;
      else frequency_input_for_arduino <= frequency;
   end 
   
   DUAL_CLK_FIFO #(.DSIZE(9), .ASIZE(13)) fifo (
      .wclk(MAX10_CLK1_50),
      .wrst_n(~reset),
      .winc(PISO_output_active),
      .wdata(significant_frequency),
      .wfull(fifo_full),
      .rclk(generated_sclk),
      .rrst_n(~reset),
      .rinc(fifo_read_enable),
      .rdata(frequency),
      .rempty(fifo_empty)
   );

   SPI send_to_arduino (
      .sclk(generated_sclk),
      .reset(reset),
      .fifo_empty(fifo_empty),
      .fifo_read_enable(fifo_read_enable),
      .data_ready(data_ready),
      .data_in(frequency_input_for_arduino),
      .mosi(mosi),
      .cs(cs)
   );

endmodule 