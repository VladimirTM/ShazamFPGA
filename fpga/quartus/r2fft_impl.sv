
module FFT_IMPLEMENTATION
  #(
    parameter FFT_LENGTH = 1024, // FFT Frame Length, 2^N
    parameter FFT_DW = 16,       // Data Bitwidth
    parameter PL_DEPTH = 3,      // Pipeline Stage Depth Configuration (0 - 3)
    parameter FFT_N = $clog2( FFT_LENGTH ) // Don't override this
    )
  (

   // system
   // input wire 			  clk,
   // input wire 			  rst_i,

   //  // control
   // input wire 			  autorun_i,
   // input wire 			  run_i,
   // input wire 			  fin_i,
   // input wire 			  ifft_i,
    
   //  // status
   // output reg 			  done_o,
   // output reg [2:0] 		  status_o,
   // output reg signed [7:0] 	  bfpexp_o,

   //  // input stream
   // input wire 			             input_stream_active_i,
   // input wire signed [FFT_DW-1:0] input_real_i,
   // input wire signed [FFT_DW-1:0] output_real_i,

   //  // output / DMA bus
   // input wire 			               dmaact_i,
   // input wire [FFT_N-1:0] 	         dmaa_i,
   // output reg signed [FFT_DW-1:0]   dmadr_real_o,
   // output reg signed [FFT_DW-1:0]   dmadr_imag_o,
      output            [11:0]         adc_data,
    ///////// Clocks /////////
      input              ADC_CLK_10,
      input              MAX10_CLK1_50,
      input              MAX10_CLK2_50,

      ///////// KEY /////////
      input    [ 1: 0]   KEY,

      ///////// SW /////////
      input    [ 9: 0]   SW,

      ///////// LEDR /////////
      output   [ 9: 0]   LEDR,

            ///////// HEX /////////
      output   [ 7: 0]   HEX0,
      output   [ 7: 0]   HEX1,
      output   [ 7: 0]   HEX2,
      output   [ 7: 0]   HEX3,
      output   [ 7: 0]   HEX4,
      output   [ 7: 0]   HEX5

   );
   
   wire clk_2MHz_wire, clk_2MHz_locked;
   clk_2MHz clk_2MHz_INSTANCE (
	   .inclk0(MAX10_CLK1_50),
	   .c0(clk_2MHz_wire),
	   .locked(clk_2MHz_locked)
   );

   wire command_valid;
   wire [4:0] command_channel;
   wire command_startofpacket;
   wire command_ready;

   assign command_startofpacket = 1'b1; // // ignore in altera_adc_control core
   assign command_endofpacket = 1'b1; // ignore in altera_adc_control core
   assign command_valid = 1'b1; // 
   assign command_channel = SW[2:0]+1; // SW2/SW1/SW0 down: map to arduino ADC_IN0

   wire response_valid/* synthesis keep */;
   wire [4:0] response_channel;
   wire [11:0] response_data;
   wire response_startofpacket;
   wire response_endofpacket;
   reg [4:0]  cur_adc_ch /* synthesis noprune */;
   reg [11:0] adc_sample_data /* synthesis noprune */;
   reg [12:0] vol /* synthesis noprune */;

   assign adc_data = adc_sample_data;

always @ (posedge MAX10_CLK1_50)
begin
	if (response_valid)
	begin
		adc_sample_data <= response_data;
		cur_adc_ch <= response_channel;
		
		vol <= response_data * 2 * 2500 / 4095;
	end
end

   ADC ADC_INSTANCE (
      .adc_pll_clock_clk(clk_2MHz_wire),
      .adc_pll_locked_export(clk_2MHz_locked),
      .clock_clk(MAX10_CLK1_50),
      .command_valid(command_valid),
      .command_channel(command_channel),
      .command_startofpacket(command_startofpacket),
      .command_endofpacket(command_endofpacket),
      .command_ready(command_ready),
      .reset_sink_reset_n(1),
      .response_valid(response_valid),
      .response_channel(response_channel),
      .response_data(response_data),
      .response_startofpacket(response_startofpacket),
      .response_endofpacket(response_endofpacket)
   );


   assign LEDR[9:0] = vol[12:3];  // led is high active

   assign HEX5[7] = 1'b1; // low active
   assign HEX4[7] = 1'b1; // low active
   assign HEX3[7] = 1'b0; // low active
   assign HEX2[7] = 1'b1; // low active
   assign HEX1[7] = 1'b1; // low active
   assign HEX0[7] = 1'b1; // low active

   SEG7_LUT	SEG7_LUT_ch (
      .oSEG(HEX5),
      .iDIG(SW[2:0])
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


   // reg 				   rst;
 
   // reg 				   autorun;
   // reg 				   run;
   // reg 				   fin;
   // reg 				   ifft;

   // always @ ( posedge clk ) begin
   //    rst <= rst_i;
   //    autorun <= autorun_i;
   //    run <= run_i;
   //    fin <= fin_i;
   //    ifft <= ifft_i;
   // end
   
   // // status
   // wire 			               done;
   // wire [2:0] 			         status;
   // wire signed [7:0] 		   bfpexp;

   // always @ ( posedge clk ) begin
   //    done_o <= done;
   //    status_o <= status;
   //    bfpexp_o <= bfpexp;
   // end

   // // input stream
   // reg 			   input_stream_active;
   // reg signed [FFT_DW-1:0] input_real;
   // reg signed [FFT_DW-1:0] output_real;

   //  // output / DMA bus
   // reg 			   dmaact;
   // reg [FFT_N-1:0] 	   dmaa;
   // wire signed [FFT_DW-1:0] dmadr_real;
   // wire signed [FFT_DW-1:0] dmadr_imag;

   // always @ ( posedge clk ) begin
   //    input_stream_active <= input_stream_active_i;
   //    input_real <= input_real_i;
   //    output_real <= output_real_i;
   //    dmaact <= dmaact_i;
   //    dmaa <= dmaa_i;
   // end

   // always @ ( posedge clk ) begin
   //    dmadr_real_o <= dmadr_real;
   //    dmadr_imag_o <= dmadr_imag;
   // end
   
   // // twiddle factor rom
   // reg 			   twact;
   // reg [FFT_N-1-2:0] 	   twa;
   // reg [FFT_DW-1:0] 	   twdr_cos;
   
   // // block ram0
   // reg 			   ract_ram0;
   // reg [FFT_N-1-1:0] 	   ra_ram0;
   // wire [FFT_DW*2-1:0] 	   rdr_ram0;
   
   // reg 			   wact_ram0;
   // reg [FFT_N-1-1:0] 	   wa_ram0;
   // reg [FFT_DW*2-1:0] 	   wdw_ram0;
   
   // // block ram1
   // reg 			   ract_ram1;
   // reg [FFT_N-1-1:0] 	   ra_ram1;
   // wire [FFT_DW*2-1:0] 	   rdr_ram1;
   
   // reg 			   wact_ram1;
   // reg [FFT_N-1-1:0] 	   wa_ram1;
   // reg [FFT_DW*2-1:0] 	   wdw_ram1;
      

   // R2FFT
   //   #(
   //     .FFT_LENGTH(FFT_LENGTH),
   //     .FFT_DW(FFT_DW),
   //     .PL_DEPTH(PL_DEPTH)
   //     )
   // uR2FFT
   //   (
   //    .clk( clk ),
   //    .rst( rst ),
      
   //    .autorun( autorun ),
   //    .run( run ),
   //    .fin( fin ),
   //    .ifft( ifft ),
      
   //    .done( done ),
   //    .status( status ),
   //    .bfpexp( bfpexp ),

   //    .input_stream_active( input_stream_active ),
   //    .input_real( input_real ),
   //    .output_real( output_real ),

   //    .dmaact( dmaact ),
   //    .dmaa( dmaa ),
   //    .dmadr_real( dmadr_real ),
   //    .dmadr_imag( dmadr_imag ),

   //    .twact( twact ),
   //    .twa( twa ),
   //    .twdr_cos( twdr_cos ),

   //    .ract_ram0( ract_ram0 ),
   //    .ra_ram0( ra_ram0 ),
   //    .rdr_ram0( rdr_ram0 ),

   //    .wact_ram0( wact_ram0 ),
   //    .wa_ram0( wa_ram0 ),
   //    .wdw_ram0( wdw_ram0 ),

   //    .ract_ram1( ract_ram1 ),
   //    .ra_ram1( ra_ram1 ),
   //    .rdr_ram1( rdr_ram1 ),

   //    .wact_ram1( wact_ram1 ),
   //    .wa_ram1( wa_ram1 ),
   //    .wdw_ram1( wdw_ram1 )
      
   //    );

   // twrom utwrom
   //   (
   //    .address( twa ),
   //    .clock( clk ),
   //    .q( twdr_cos )
   //    );

   // dpram ram0
   //   (
   //    .clock( clk ),
   //    .data( wdw_ram0 ),
   //    .rdaddress( ra_ram0 ),
   //    .wraddress( wa_ram0 ),
   //    .q( rdr_ram0 )
   //    );

   // dpram ram1
   //   (
   //    .clock( clk ),
   //    .data( wdw_ram1 ),
   //    .rdaddress( ra_ram1 ),
   //    .wraddress( wa_ram1 ),
   //    .q( rdr_ram1 )
   //    );
   
endmodule // r2fft_impl

