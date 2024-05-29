
// given the maximum number of bits that a variable "A" (from an input stream) can be represented on "N" bits (example: 10 can be represented on 4 bits, 16 on 5, 927 on 10)
// find the maximum number "MAX" out of all of those "N"
module bfp_maxBitWidth
  #
  (
   parameter FFT_MAX_BIT_WIDTH = 5
   )
  (
   input wire        reset,
   input wire        clk,

   input wire        clr,
   
   input wire        max_bit_width_activate,
   input wire [FFT_MAX_BIT_WIDTH-1:0]  current_variable_bit_width, // this is "N"

   output wire [FFT_MAX_BIT_WIDTH-1:0] max_bit_width_all_stream // this is "MAX"
   );

   reg [FFT_MAX_BIT_WIDTH-1:0]         max_bit_width;
   
   assign max_bit_width_all_stream = max_bit_width;

   
   always @ ( posedge clk ) begin
      if ( reset ) max_bit_width <= 'h0;
      else if ( clr ) max_bit_width <= 'h0;
      else if ( max_bit_width_activate ) begin
         if ( max_bit_width < current_variable_bit_width ) begin
            max_bit_width <= current_variable_bit_width;
         end
      end
   end // always @ ( posedge clk )
   
endmodule // bfp_bitWidthDetector


