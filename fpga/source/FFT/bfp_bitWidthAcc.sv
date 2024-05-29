
module bfp_bitWidthAcc
  #(
    parameter FFT_MAX_BIT_WIDTH = 5,
    parameter FFT_DW = 16
    )
  (
   input wire                             clk,
   input wire                             reset,

   input wire                             init,
   input wire [FFT_MAX_BIT_WIDTH-1:0]     bw_init,
   input wire                             update,
   input wire [FFT_MAX_BIT_WIDTH-1:0]     bw_new,

   output wire [FFT_MAX_BIT_WIDTH-1:0]    bfp_bw,
   output wire signed [7:0]               bfp_exponent
   );
   
   reg [FFT_MAX_BIT_WIDTH-1:0]      bfp_bw_f;
   assign bfp_bw = bfp_bw_f;

   always @ ( posedge clk ) begin
           if (reset)   bfp_bw_f <= 5'h0;
      else if (init)    bfp_bw_f <= bw_init;
      else if (update)  bfp_bw_f <= bw_new;
   end

   // the "." demilits the whole part from the fractional part in the binary representation (8b'0011.1010 = 3.6250). 
   // decide where the "." should be by appling a simple rule:
   // suppose N = 8b'1000_0110.
   // if (exponent_signed = -4) => (float) N = 0 * 2^-4 + 1 * 2^-3 + 1 * 2^-2 + 0 * 2^-1 + 0 * 2^0 + 0 * 2^1 + 0 * 2^2 + 0 * 2^3;     
   // if (exponent_signed = -2) => (float) N = 0 * 2^-2 + 1 * 2^-1 + 1 * 2^0 + 0 * 2^1 + 0 * 2^2 + 0 * 2^3 + 0 * 2^4 + 0 * 2^5; 
   // we can see it is a tradeoff between precision and scale.     
   reg signed [7:0]  bfp_exponent_signed; 
   
   reg signed  [FFT_MAX_BIT_WIDTH:0]       bfp_scale;
   
   // when at stage 0, take the max bit width from the ADC data, otherwise the max bit width after all butterflies
   wire        [FFT_MAX_BIT_WIDTH-1:0]     max_bit_width_per_FFT_stage = init ? bw_init : bw_new; 
   
   always_comb begin
      if ( max_bit_width_per_FFT_stage == FFT_DW )    bfp_scale = 5'h01;
      else if ( max_bit_width_per_FFT_stage == 5'h0 ) bfp_scale = 5'h00;
      else bfp_scale = (FFT_DW - 2) - max_bit_width_per_FFT_stage; // between 14 and -1
   end
   
   always @ ( posedge clk ) begin
           if (reset)   bfp_exponent_signed <= 8'h0;
           else bfp_exponent_signed <= 8'b1111_1101; // exponent = -3
      // ADAPTIVE VERSION:
      // we try to increase precision because we expect bfp_scale to be positive.
      // else if (init)    bfp_exponent_signed <= -bfp_scale;
      // else if (update)  bfp_exponent_signed <= bfp_exponent_signed - bfp_scale;
   end
   assign bfp_exponent = bfp_exponent_signed;

endmodule // bfp_bitWidthAcc

