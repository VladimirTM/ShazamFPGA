module shazam #(parameter MAXIMAS_COUNT = 11) (
    input clk,
    input reset,
    input start,
    input [11:0] adc_data,
    input adc_data_valid,
    output mosi,
    output cs,
    output sclk
);
    wire [8:0] maximas [MAXIMAS_COUNT-1:0];
    wire maximas_found_active;

    reg reset_reg;
    always @(posedge clk) begin
      reset_reg = reset || !start;
    end 

    shazam_core #(.MAXIMAS_COUNT(MAXIMAS_COUNT)) SHAZAM_ANALYZE_SOUNDS (
        .clk(clk),
        .reset(reset),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid),
        .start(start),
        .maximas(maximas),
        .maximas_found_active(maximas_found_active)
    );

   wire [8:0] significant_frequency;
   wire PISO_output_active;
   PISO #(.MAXIMAS_COUNT(MAXIMAS_COUNT)) parallel_in_serial_out (
      .clk(clk),
      .reset(reset_reg),
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
      .inclk0(clk),
      .c0(generated_sclk)
   );

   reg should_read, data_ready;
   reg [8:0] frequency_input_for_arduino;
   
   wire fifo_refresh_data;
   
   always @ (negedge generated_sclk) begin
      if(reset_reg) frequency_input_for_arduino <= 0;
      else frequency_input_for_arduino <= frequency;
   end 
   
   DUAL_CLK_FIFO #(.DSIZE(9), .ASIZE(16)) fifo (
      .wclk(clk),
      .wrst_n(~reset_reg),
      .winc(PISO_output_active && !fifo_full),
      .wdata(significant_frequency),
      .wfull(fifo_full),
      .rclk(generated_sclk),
      .rrst_n(~reset_reg),
      .rinc(fifo_refresh_data),
      .rdata(frequency),
      .rempty(fifo_empty)
   );

   SPI send_to_arduino (
      .sclk(generated_sclk),
      .reset(reset_reg),
      .fifo_empty(fifo_empty),
      .fifo_refresh_data(fifo_refresh_data),
      .data_ready(data_ready),
      .data_in(frequency_input_for_arduino),
      .mosi(mosi),
      .cs(cs)
   );

endmodule 