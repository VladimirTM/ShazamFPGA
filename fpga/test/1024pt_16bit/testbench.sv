
`timescale 1ns/1ps

`include "../include/dpram.sv"
`include "../include/twrom.sv"

module testbench;

   localparam FFT_LENGTH = 1024;
   localparam FFT_DW = 16;
   localparam PL_DEPTH = 2;
   localparam FFT_N = $clog2( FFT_LENGTH );  
   
   localparam SAMPLING_RATE = 10_000;
   localparam FREQUENCY_HOP = 9.76; 

`include "../include/header.sv"
`include "../include/simtask.sv"

   
   integer i;
   integer inputReal;
   integer inputImag;
   integer fftBfpExp;
   integer output_file;
   integer magnitudes_raw;
   integer input_file;

   initial begin
      rst_reg = 1;
      autorun_reg = 1;
      fin_reg = 0;
      run_reg = 0;
      ifft_reg = 0;
      wait_clk( 10 );
      rst_reg = 0;
      wait_clk( 10 );

      output_file = $fopen("output_testbench.txt", "w");
      magnitudes_raw = $fopen("magnitudes_raw.txt", "w");
      input_file = $fopen("arduino_input.txt", "r");

      $fwrite(output_file, "INPUT DATA:\n");

      for ( i = 0; i < FFT_LENGTH; i++ ) begin
	      input_stream_active_reg <= 1'b1;
	      $fscanf(input_file, "%d,", inputReal);
	      inputImag = 0;
         $fwrite(output_file, "REAL DATA: %d, IMAGINARY DATA: %d\n", inputReal, inputImag);
	      input_real_reg <= inputReal;
	      output_real_reg <= inputImag;
	      wait_clk( 1 );
      end
      
      input_stream_active_reg <= 1'b0;

      while ( !done ) begin
	      wait_clk( 1 );
      end

      fftBfpExp = bfpexp;

      // TODO: see what this is doing
      dumpFromDmaBus();

      $fwrite(output_file, "FFT RESULT:\n");
      for ( i = 0; i < FFT_LENGTH; i++ ) begin
         $fwrite(magnitudes_raw, "%f,", $sqrt(
			 1.0 * resultReal[i] * resultReal[i] + 
			 1.0 * resultImag[i] * resultImag[i]
			 ) 
		   * (2.0**(fftBfpExp))
         );

	      $fwrite(output_file,  "%dHz. REAL: %f, IMAGINARY: %f, MAGNITUDE: %f\n", 
         FREQUENCY_HOP * i,
		   resultReal[i] * (2.0**(fftBfpExp)), 
		   resultImag[i] * (2.0**(fftBfpExp)),
		   $sqrt(
			 1.0 * resultReal[i] * resultReal[i] + 
			 1.0 * resultImag[i] * resultImag[i]
			 ) 
		   * (2.0**(fftBfpExp))
		   );
      end
      $fclose(output_file);
      $stop();
   end
   
   
   
   
   
endmodule // testbench



