
module butterflyCore
  #(
    parameter FFT_N = 10,
    parameter FFT_DW = 16,
    parameter STAGE_COUNT_BW = 4
    )
  (
   input wire                 clk,
   input wire                 reset,

   input wire [STAGE_COUNT_BW-1:0] fft_stage,
   
   input wire                 iact,
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
   
   // pipelines the input to account for the delay in the twiddle pipeline
   ramPipelineBridge 
     #(
       .FFT_N(FFT_N),
       .FFT_DW(FFT_DW)
       )
     inputStagePipeline
     (
      .clk( clk ),
      .rst( reset ),
      
      .iact( iact ),
      .oact( iact_calc ),
      
      .ictrl( ictrl ),
      .octrl( ictrl_calc ),


      .iMemAddr( input_memory_address ),
      .iEvenData( input_A ),
      .iOddData( input_B ),

      .oMemAddr( iMemAddrCalc ),
      .oEvenData( {A_imag, A_real} ),
      .oOddData(  {B_imag, B_real} )
      
      );

   wire [FFT_DW-1:0]                   out_A_real;
   wire [FFT_DW-1:0]                   out_A_imag;
   wire [FFT_DW-1:0]                   out_B_real;
   wire [FFT_DW-1:0]                   out_B_imag;

    integer i;
    reg butterfly_unit_active [0:9];

    always @ (posedge clk) begin 
      if(reset) begin
        for(i = 0; i < 10; i = i + 1) butterfly_unit_active[i] <= 0;
      end
      else begin
        if(fft_stage < 4'd10) begin
          if(iact_calc)  butterfly_unit_active[fft_stage] <= 1;
          else for(i = 0; i < 10; i = i + 1) butterfly_unit_active[i] <= 0;
        end 
        else for(i = 0; i < 10; i = i + 1) butterfly_unit_active[i] <= 0;
      end 
    end

   wire butterfly_output_active [0:9];
   wire [1:0] butterfly_octrl [0:9];
   wire [FFT_N-1-1:0] butterfly_address_memory_calc [0:9];
   wire [FFT_DW-1:0] butterfly_out_A_real [0:9];
   wire [FFT_DW-1:0] butterfly_out_A_imag [0:9];
   wire [FFT_DW-1:0] butterfly_out_B_real [0:9];
   wire [FFT_DW-1:0] butterfly_out_B_imag [0:9];

   assign oact_calc = butterfly_output_active[fft_stage];
   assign octrl_calc = butterfly_octrl[fft_stage];
   assign oMemAddrCalc = butterfly_address_memory_calc[fft_stage];
   assign out_A_real = butterfly_out_A_real[fft_stage];
   assign out_A_imag = butterfly_out_A_imag[fft_stage];
   assign out_B_real = butterfly_out_B_real[fft_stage];
   assign out_B_imag = butterfly_out_B_imag[fft_stage];

   genvar stage;
   generate
    for (stage = 0; stage < 10; stage = stage + 1) begin : radix2instances
      radix2Butterfly #(.FFT_DW(FFT_DW), .FFT_N(FFT_N), .FFT_STAGE(stage)) uradix2bt (
      .clk( clk ),
      .reset( reset ),
      .iact(  butterfly_unit_active[stage] ),
      .ictrl( ictrl_calc ),

      .oact( butterfly_output_active[stage] ),
      .octrl( butterfly_octrl[stage] ),

      .input_memory_address( iMemAddrCalc ),
      .output_memory_address( butterfly_address_memory_calc[stage] ),
      
      .A_real( A_real ),
      .A_imag( A_imag ),
      .B_real( B_real ),
      .B_imag( B_imag ),
      
      .twiddle_real( twiddle_real ),
      .twiddle_imag( twiddle_imag ),
      
      .out_A_real( butterfly_out_A_real[stage] ),
      .out_A_imag( butterfly_out_A_imag[stage] ),
      .out_B_real( butterfly_out_B_real[stage] ),
      .out_B_imag( butterfly_out_B_imag[stage] )
      );
    end 
   endgenerate
  

   
   ramPipelineBridge 
     #(
       .FFT_N(FFT_N),
       .FFT_DW(FFT_DW)
       )
   outputStagePipeline
     (
      .clk( clk ),
      .rst( reset ),

      .iact( oact_calc ),
      .oact( oact ),

      .ictrl( octrl_calc ),
      .octrl( octrl ),

      .iMemAddr( oMemAddrCalc ),
      .iEvenData( { out_A_imag, out_A_real } ),
      .iOddData( { out_B_imag, out_B_real } ),

      .oMemAddr( output_memory_address ),
      .oEvenData( output_A ),
      .oOddData( output_B )
      );

endmodule // butterflyUnit


