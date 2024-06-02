   real M_PI = 3.1415926535897932384626433832795029;

   reg clk_reg = 1'b0;
   wire clk = clk_reg;

   reg 	rst_reg = 1'b1;
   wire reset = rst_reg;

   reg 	autorun_reg = 1'b0;
   wire autorun = autorun_reg;

   reg 	run_reg = 1'b0;
   wire run = run_reg;
   
   reg 	fin_reg = 1'b0;
   wire fin = fin_reg;

   reg 	ifft_reg = 1'b0;

   reg 	done_reg = 1'bZ;
   wire done = done_reg;
   
   reg [2:0] status_reg = 3'bZZZ;
   wire [2:0] status = status_reg;

   reg signed [7:0] bfpexp_reg;
   wire signed [7:0] bfpexp = bfpexp_reg;

   reg 		     input_stream_active_reg = 1'b0;
   wire 	     input_stream_active = input_stream_active_reg;

   reg signed [FFT_DW-1:0] input_real_reg;
   wire signed [FFT_DW-1:0] input_real = input_real_reg;
   
   reg signed [FFT_DW-1:0]  input_imaginary_reg;
   wire signed [FFT_DW-1:0] input_imaginary = input_imaginary_reg;

   reg 			    dmaact_reg = 1'b0;
   wire 		    dmaact = dmaact_reg;

   reg [FFT_N-1:0] 	    dmaa_reg = {FFT_N{1'b0}};
   wire [FFT_N-1:0] 	    dmaa = dmaa_reg;

   wire signed [FFT_DW-1:0] dmadr_real;
   wire signed [FFT_DW-1:0] dmadr_imag;

   // twiddle factor rom
   wire 		    twact;
   wire [FFT_N-1-2:0] 	    twa;
   wire [FFT_DW-1:0] 	    twdr_cos;
   
   // block ram0
   wire 		    ract_ram0;
   wire [FFT_N-1-1:0] 	    ra_ram0;
   wire [FFT_DW*2-1:0] 	    rdr_ram0;
   
   wire 		    wact_ram0;
   wire [FFT_N-1-1:0] 	    wa_ram0;
   wire [FFT_DW*2-1:0] 	    wdw_ram0;
   
   // block ram1
   wire 		    ract_ram1;
   wire [FFT_N-1-1:0] 	    ra_ram1;
   wire [FFT_DW*2-1:0] 	    rdr_ram1;
   
   wire 		    wact_ram1;
   wire [FFT_N-1-1:0] 	    wa_ram1;
   wire [FFT_DW*2-1:0] 	    wdw_ram1;
   
   R2FFT
     #(
       .FFT_LENGTH(FFT_LENGTH),
       .FFT_DW(FFT_DW),
       .PL_DEPTH(PL_DEPTH)
       )
   uR2FFT
     (
      .clk( clk ),
      .reset( reset ),

      .autorun(1),
      .run(1),
      .fin(0),

      .done( done ),
      .status( status ),
      .bfpexp( bfpexp_reg ),

      .input_stream_active( input_stream_active ),
      .input_real( input_real ),
      .input_imaginary( input_imaginary ),

      .dmaact( dmaact ),
      .dmaa( dmaa ),
      .dmadr_real( dmadr_real ),
      .dmadr_imag( dmadr_imag ),

      .twact( twact ),
      .twa( twa ),
      .twdr_cos( twdr_cos ),

      .ract_ram0( ract_ram0 ),
      .ra_ram0( ra_ram0 ),
      .rdr_ram0( rdr_ram0 ),

      .wact_ram0( wact_ram0 ),
      .wa_ram0( wa_ram0 ),
      .wdw_ram0( wdw_ram0 ),

      .ract_ram1( ract_ram1 ),
      .ra_ram1( ra_ram1 ),
      .rdr_ram1( rdr_ram1 ),

      .wact_ram1( wact_ram1 ),
      .wa_ram1( wa_ram1 ),
      .wdw_ram1( wdw_ram1 )      
      
      );

   twrom utwrom (
	.clk( clk ),
	.twact( twact ),
	.twa( twa ),
	.twdr_cos( twdr_cos )
	);


   dpram
     #(
       .ADDR_WIDTH(FFT_N-1),
       .DATA_WIDTH(FFT_DW*2)
       )
   ram0
     (
      .clk( clk ),
      
      .ract( ract_ram0 ),
      .ra( ra_ram0 ),
      .rdr( rdr_ram0 ),

      .wact( wact_ram0 ),
      .wa( wa_ram0 ),
      .wdw( wdw_ram0 )
      
      );
   

   dpram
     #(
       .ADDR_WIDTH(FFT_N-1),
       .DATA_WIDTH(FFT_DW*2)
       )
   ram1
     (
      .clk( clk ),
      
      .ract( ract_ram1 ),
      .ra( ra_ram1 ),
      .rdr( rdr_ram1 ),

      .wact( wact_ram1 ),
      .wa( wa_ram1 ),
      .wdw( wdw_ram1 )
      
      );
