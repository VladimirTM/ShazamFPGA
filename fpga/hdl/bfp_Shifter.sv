
module bfp_Shifter
  #(
    parameter FFT_DW = 16,
    parameter FFT_MAX_BIT_WIDTH = 5
    )
  (

   // input "A" on 16 bits: 0000_0000_0000_0000 with a fractional part (i.e: 0000_0000_0000.0000 -> the least significant 4 bits will represent construct the fractinal part)
   input wire [FFT_DW-1:0]  operand,

   // output "A"
   output wire [FFT_DW-1:0] bfp_operand,

   // exponent width: decides where the . is (i.e: current_variable_bit_width = 4 => 0000_0000_0001.1000 -> 1.5)
   input wire [FFT_MAX_BIT_WIDTH-1:0]  current_variable_bit_width
   );

   reg [FFT_DW-1:0]            bfp_operand_r;
   
   assign bfp_operand = bfp_operand_r;

   always_comb begin
      if (  (current_variable_bit_width == FFT_DW) ||    // -1.0 only
            (current_variable_bit_width == FFT_DW-1 ) || // [1.0, 0.5)
            (current_variable_bit_width == 0)
         ) begin
         bfp_operand_r = operand;
      end else begin
         bfp_operand_r = operand << ((FFT_DW-1)-current_variable_bit_width);
      end
   end
   
endmodule // bfp_Shifter

