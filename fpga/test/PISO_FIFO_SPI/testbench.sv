`timescale 1ns/1ps
module testbench;
    reg clk = 0, reset = 0;
    always #10 clk = ~clk;

    `include "../include/wait_clk.sv"
    
    integer i, j;
    integer input_file;
    integer mosi_output_file;

    reg [8:0] frequency_read;

    wire mosi, cs, sclk;

    reg [24:0] maximas [15:0];
    reg maximas_found_active;

     wire [8:0] significant_frequency;
   wire PISO_output_active;
   
   PISO parallel_in_serial_out (
      .clk(clk),
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
      .inclk0(clk),
      .c0(generated_sclk)
   );

   reg should_read, data_ready;
   reg [8:0] frequency_input_for_arduino;
   
   wire fifo_refresh_data;
   
   always @ (negedge generated_sclk) begin
      if(reset) frequency_input_for_arduino <= 0;
      else frequency_input_for_arduino <= frequency;
   end 
   
   DUAL_CLK_FIFO #(.DSIZE(9), .ASIZE(13)) fifo (
      .wclk(clk),
      .wrst_n(~reset),
      .winc(PISO_output_active),
      .wdata(significant_frequency),
      .wfull(fifo_full),
      .rclk(generated_sclk),
      .rrst_n(~reset),
      .rinc(fifo_refresh_data),
      .rdata(frequency),
      .rempty(fifo_empty)
   );

   SPI send_to_arduino (
      .sclk(generated_sclk),
      .reset(reset),
      .fifo_empty(fifo_empty),
      .fifo_refresh_data(fifo_refresh_data),
      .data_ready(data_ready),
      .data_in(frequency_input_for_arduino),
      .mosi(mosi),
      .cs(cs)
   );

    initial begin 
        reset = 1;
        wait_clk( 20 );
        reset = 0;
        wait_clk(20);        

        mosi_output_file = $fopen("../../../data/PISO_FIFO_SPI/OUTPUT_MOSI.txt", "w");
        input_file = $fopen("../../../data/inputs/PISO_input.txt", "r");

        for (i = 0; i < 16; i = i + 1 ) begin
            $fscanf(input_file, "%d,", frequency_read);
            maximas[i] = {frequency_read, {16{1'b0}}};
            wait_clk (200); // wait for another FFT to 'finish' 
        end

        maximas_found_active = 1;
        wait_clk(1);
        maximas_found_active = 0;
    end
endmodule
