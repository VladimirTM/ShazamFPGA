
// this modules computes the minimum numbers of bits that can represent accurately represent all operands given as input
module bfp_bitWidthDetector
  #(
    parameter FFT_MAX_BIT_WIDTH = 5,
    parameter FFT_DW = 16
    )
  (
   input wire [FFT_DW-1:0] operand0,
   input wire [FFT_DW-1:0] operand1,
   input wire [FFT_DW-1:0] operand2,
   input wire [FFT_DW-1:0] operand3,
   output wire [FFT_MAX_BIT_WIDTH-1:0] min_bit_width
   );

   reg [FFT_MAX_BIT_WIDTH-1:0]         min_bit_width_reg;
   assign min_bit_width = min_bit_width_reg;

   function [FFT_DW-1:0] ToAbsValue;
      input [FFT_DW-1:0]   operand;
      begin
         ToAbsValue = (operand[FFT_DW-1] == 1'b1) ?
                           (0 - operand[FFT_DW-1:0]) :
                           (operand[FFT_DW-1:0]);
      end
   endfunction
   
   wire [FFT_DW-1:0] operand_abs = 
               ToAbsValue( operand0 ) |
               ToAbsValue( operand1 ) |
               ToAbsValue( operand2 ) |
               ToAbsValue( operand3 );

   integer i;
   always_comb begin
      min_bit_width_reg = 0;
      for ( i = (FFT_DW-1); i >= 0; i-- ) begin
         if ( operand_abs[i] ) begin
            // iterate the number from MSB TO LSB and find the first occurance of 1: "i"
            // then the min_bit_width = i + 1
            min_bit_width_reg = i + 1;
            break;
         end
      end
   end
   
endmodule // bfp_bitWidth

