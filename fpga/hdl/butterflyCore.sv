
module butterflyCore
  #(
    parameter FFT_N = 10,
    parameter FFT_DW = 16,
    parameter FFT_MAX_BIT_WIDTH = 5,
    parameter PL_DEPTH = 0
    )
  (
   input wire                 clk,
   input wire                 reset,

   input wire                 clr_bfp,
   input wire [FFT_MAX_BIT_WIDTH-1:0] ibfp,
   output wire [FFT_MAX_BIT_WIDTH-1:0] max_bit_width_after_butterfly,
   
   // triggers the following sequence:
   // (input data allignment -> radix 2 butterfly -> ram insert output -> find max bitwidth)
   input wire                 iact,

   // output active will be trigger only after the following sequence:
   // (input data allignment -> radix 2 butterfly -> ram insert output -> find max bitwidth)
   // has been completed
   output wire                oact,

   input wire [1:0]           ictrl,
   output wire [1:0]          octrl,

   input wire [FFT_N-1-1:0]   input_memory_address,
   
   input wire [FFT_DW*2-1:0]  input_A,
   input wire [FFT_DW*2-1:0]  input_B,

   output wire [FFT_N-1-1:0]  output_memory_address,
   output wire [FFT_DW*2-1:0] output_A,
   output wire [FFT_DW*2-1:0] output_B,

   input wire [FFT_DW-1:0]      twiddle_real,
   input wire [FFT_DW-1:0]      twiddle_imag
   
   );
   

  //  wire [FFT_DW*2-1:0]                  input_A_alligned;
  //  wire [FFT_DW*2-1:0]                  input_B_alligned;
   
  //  bfp_Shifter 
  //    #(
  //      .FFT_DW(FFT_DW),
  //      .FFT_MAX_BIT_WIDTH(FFT_MAX_BIT_WIDTH)
  //      )
  //    ushifter0
  //    ( 
  //       //
  //      .operand( input_A[FFT_DW*2-1:FFT_DW*2/2] ), 
  //      .bfp_operand( input_A_alligned[FFT_DW*2-1:FFT_DW*2/2] ),
  //      .current_variable_bit_width( ibfp )
  //      );
   
  //  bfp_Shifter
  //    #(
  //      .FFT_DW(FFT_DW),
  //      .FFT_MAX_BIT_WIDTH(FFT_MAX_BIT_WIDTH)
  //      )
  //    ushifter1
  //    (
  //     .operand( input_A[FFT_DW*2/2-1:0] ),
  //     .bfp_operand( input_A_alligned[FFT_DW*2/2-1:0] ),
  //     .current_variable_bit_width( ibfp )
  //     );
   
  //  bfp_Shifter 
  //    #(
  //      .FFT_DW(FFT_DW),
  //      .FFT_MAX_BIT_WIDTH(FFT_MAX_BIT_WIDTH)
  //      )
  //  ushifter2
  //    (
  //     .operand( input_B[FFT_DW*2-1:FFT_DW*2/2] ),
  //     .bfp_operand( input_B_alligned[FFT_DW*2-1:FFT_DW*2/2] ),
  //     .current_variable_bit_width( ibfp )
  //     );
   
  //  bfp_Shifter 
  //    #(
  //      .FFT_DW(FFT_DW),
  //      .FFT_MAX_BIT_WIDTH(FFT_MAX_BIT_WIDTH)
  //      )
  //  ushifter3
  //    (
  //     .operand( input_B[FFT_DW - 1:0] ),
  //     .bfp_operand( input_B_alligned[FFT_DW*2/2-1:0] ),
  //     .current_variable_bit_width( ibfp )
  //     );

   wire                         iact_calc;
   wire [1:0]                   ictrl_calc;

   wire                         oact_calc;
   wire [1:0]                   octrl_calc;
   
   wire [FFT_N-1-1:0]                  iMemAddrCalc;
   wire [FFT_N-1-1:0]                  oMemAddrCalc;

   wire [FFT_DW-1:0]                   A_real;
   wire [FFT_DW-1:0]                   A_imag;
   wire [FFT_DW-1:0]                   B_real;
   wire [FFT_DW-1:0]                   B_imag;
   
   ramPipelineBridge 
     #(
       .FFT_N(FFT_N),
       .FFT_DW(FFT_DW)
       )
     inputStagePipeline
     (
      .clk( clk ),
      .reset( reset ),
      
      .iact( iact ),
      .oact( iact_calc ),
      
      .ictrl( ictrl ),
      .octrl( ictrl_calc ),


      .input_memory_address( input_memory_address ),
      .input_A( input_A ),
      .input_B( input_B ),

      .output_memory_address( iMemAddrCalc ),
      .output_A( { A_imag, A_real } ),
      .output_B(  { B_imag, B_real } )
      
      );

   wire [FFT_DW-1:0]                   out_A_real;
   wire [FFT_DW-1:0]                   out_A_imag;
   wire [FFT_DW-1:0]                   out_B_real;
   wire [FFT_DW-1:0]                   out_B_imag;

   radix2Butterfly
     #(
       .FFT_DW(FFT_DW),
       .FFT_N(FFT_N)
       )
     uradix2bt
     (
      .clk( clk ),
      .reset( reset ),
      .iact(  iact_calc ),
      .ictrl( ictrl_calc ),

      .oact( oact_calc ),
      .octrl( octrl_calc ),

      .input_memory_address( iMemAddrCalc ),
      .output_memory_address( oMemAddrCalc ),
      
      .A_real( A_real ),
      .A_imag( A_imag ),
      .B_real( B_real ),
      .B_imag( B_imag ),
      
      .twiddle_real( twiddle_real ),
      .twiddle_imag( twiddle_imag ),
      
      .out_A_real( out_A_real ),
      .out_A_imag( out_A_imag ),
      .out_B_real( out_B_real ),
      .out_B_imag( out_B_imag )
      );

   
   ramPipelineBridge 
     #(
       .FFT_N(FFT_N),
       .FFT_DW(FFT_DW)
       )
   outputStagePipeline
     (
      .clk( clk ),
      .reset( reset ),

      .iact( oact_calc ),
      .oact( oact ),

      .ictrl( octrl_calc ),
      .octrl( octrl ),

      .input_memory_address( oMemAddrCalc ),
      .input_A( { out_A_imag, out_A_real } ),
      .input_B( { out_B_imag, out_B_real } ),

      .output_memory_address( output_memory_address ),
      .output_A( output_A ),
      .output_B( output_B )      
      
      );

   bfp_bitWidthDetector 
     #(
       .FFT_MAX_BIT_WIDTH(FFT_MAX_BIT_WIDTH),
       .FFT_DW(FFT_DW)
       )
     ubfp_bitWidth
     (
      .operand0( output_A[FFT_DW*2-1:FFT_DW*2/2] ),
      .operand1( output_A[FFT_DW*2/2-1:0] ),
      .operand2( output_B[FFT_DW*2-1:FFT_DW*2/2] ),
      .operand3( output_B[FFT_DW*2/2-1:0] ),
      .min_bit_width( max_bit_width_after_butterfly )
      );
   

endmodule // butterflyUnit


