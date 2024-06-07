// Purpose:	This routine caculates a butterfly for a decimation
//	in frequency version of an FFT.  Specifically, given
//	complex Left and Right values together with a Twiddle (C), the output
//	of this routine is given by:
//		L' = L + R
//		R' = (L - R)*C
module radix2Butterfly
  #(
    parameter FFT_DW = 16,
    parameter FFT_N = 10,
    parameter FFT_STAGE = 0
   )
  (
   input wire                     clk,
   input wire                     reset,
   
   input wire                     iact,
   input wire [1:0]               ictrl,

   output reg                     oact,
   output reg [1:0]               octrl,

   input wire [FFT_N-1-1:0]       input_memory_address,
   output reg [FFT_N-1-1:0]       output_memory_address,
   
   // input
   input wire signed [FFT_DW-1:0] A_real,
   input wire signed [FFT_DW-1:0] A_imag,
   input wire signed [FFT_DW-1:0] B_real,
   input wire signed [FFT_DW-1:0] B_imag,
  
   // twiddle factor
   input wire signed [FFT_DW-1:0]   twiddle_real,
   input wire signed [FFT_DW-1:0]   twiddle_imag,

   // output
   output reg signed [FFT_DW-1:0] out_A_real,
   output reg signed [FFT_DW-1:0] out_A_imag,
   output reg signed [FFT_DW-1:0] out_B_real,
   output reg signed [FFT_DW-1:0] out_B_imag 
   );

   reg stage_1_half = 0, stage_1_full = 0, stage_2_half = 0, stage_2_full = 0, stage_3_half = 0;
   reg [1:0] stage_1_half_ctrl = 0, stage_1_full_ctrl = 0, stage_2_half_ctrl = 0, stage_2_full_ctrl = 0, stage_3_half_ctrl = 0;
   reg [FFT_N-1-1:0] memory_address_stage_1_half, memory_address_stage_1_full, memory_address_stage_2_half, memory_address_stage_2_full, memory_address_stage_3_half;
   always @(posedge clk) begin
      if(reset) begin
         stage_1_half <= 0;
         stage_1_full <= 0;
         stage_2_half <= 0;
         stage_2_full <= 0;
         stage_3_half <= 0;
         oact <= 0;
      end 
      else begin
         stage_1_half <= iact;
         stage_1_full <= stage_1_half;
         stage_2_half <= stage_1_full;
         stage_2_full <= stage_2_half;
         stage_3_half <= stage_2_full;
         oact <= stage_3_half;

         stage_1_half_ctrl <= ictrl;
         stage_1_full_ctrl <= stage_1_half_ctrl;
         stage_2_half_ctrl <= stage_1_full_ctrl;
         stage_2_full_ctrl <= stage_2_half_ctrl;
         stage_3_half_ctrl <= stage_2_full_ctrl;
         octrl <= stage_3_half_ctrl;

         memory_address_stage_1_half <= input_memory_address;
         memory_address_stage_1_full <= memory_address_stage_1_half;
         memory_address_stage_2_half <= memory_address_stage_1_full;
         memory_address_stage_2_full <= memory_address_stage_2_half;
         memory_address_stage_3_half <= memory_address_stage_2_full;
         output_memory_address <= memory_address_stage_3_half;
      end 
   end 

   wire signed [FFT_DW-1:0] sum_real, sum_imag, diff_real, diff_imag;
   // stage 1 is computing the sum (A + B) and difference (A - B)
   reg signed [15:0] twiddle_real_reg_1, twiddle_imag_reg_1;
   reg signed [15:0] twiddle_real_reg_2, twiddle_imag_reg_2;
   always @ (posedge clk) begin
      // stage 1 and half
      twiddle_real_reg_1 <= twiddle_real;
      twiddle_imag_reg_1 <= twiddle_imag;

      // stage 1 full
      twiddle_real_reg_2 <= twiddle_real_reg_1;
      twiddle_imag_reg_2 <= twiddle_imag_reg_1;
   end
   fixed_point_adder SUM_REAL (
      .clk(clk),
      .enable(iact),
      .reset(reset),
      .A(A_real),
      .B(B_real),
      .sum(sum_real)
   );

   fixed_point_adder SUM_IMAG (
      .clk(clk),
      .enable(iact),
      .reset(reset),
      .A(A_imag),
      .B(B_imag),
      .sum(sum_imag)
   );

   fixed_point_adder DIFF_REAL (
      .clk(clk),
      .enable(iact),
      .reset(reset),
      .A(A_real),
      .B(~B_real + 1'b1),
      .sum(diff_real)   
   );

   fixed_point_adder DIFF_IMAG (
      .clk(clk),
      .enable(iact),
      .reset(reset),
      .A(A_imag),
      .B(~B_imag + 1'b1),
      .sum(diff_imag)
   );

   // to compute A * B (where A and B are complex numbers) we have to do:
   // real(A * B) = A_real * B_real - A_imag * B_imag
   // imaginary(A * B) = A_real * B_imag + A_imag * B_real
   // this implies the need for 2 more stages (3 if following the "documentation"):
   // stage 2: compute "A_real * B_real", "A_imag * B_imag", "A_real * B_imag", "A_imag * B_real"
   // stage 3: save those intermediary values in flip-flops
   // stage 4: compute out_B_real, out_B_imag

   // starting stage 2: save the sum in a reg to prevent mixing up the data
   reg signed [FFT_DW-1:0] sum_stage_2_real, sum_stage_2_imag;
   reg signed [FFT_DW-1:0] sum_stage_2_real_reupload, sum_stage_2_imag_reupload;

   always @(posedge clk) begin
      // stage 2 and half
      sum_stage_2_real <= sum_real;
      sum_stage_2_imag <= sum_imag;

      // stage 2 full
      sum_stage_2_real_reupload <= sum_stage_2_real;
      sum_stage_2_imag_reupload <= sum_stage_2_imag;
   end 

   localparam EXP_WIDTH_TWIDDLE = 15;
   localparam EXP_WIDTH_INPUT = FFT_DW - FFT_STAGE - 2;
   // stage 2: compute "A_real * B_real", "A_imag * B_imag", "A_real * B_imag", "A_imag * B_real"
   wire signed [FFT_DW-1:0] real_1, real_2, imag_1, imag_2;
   fixed_point_multiplier #(.EXP_WIDTH_A(EXP_WIDTH_TWIDDLE), .EXP_WIDTH_B(EXP_WIDTH_INPUT), .EXP_WIDTH_PRODUCT(EXP_WIDTH_INPUT)) MULTIPLY_REAL_1 (
      .clk(clk),
      .enable(stage_1_full),
      .A(twiddle_real_reg_2),
      .B(diff_real),
      .product(real_1)
   );

   fixed_point_multiplier #(.EXP_WIDTH_A(EXP_WIDTH_TWIDDLE), .EXP_WIDTH_B(EXP_WIDTH_INPUT), .EXP_WIDTH_PRODUCT(EXP_WIDTH_INPUT)) MULTIPLY_REAL_2 (
      .clk(clk),
      .enable(stage_1_full),
      .reset(reset),
      .A(twiddle_imag_reg_2),
      .B(diff_imag),
      .product(real_2)
   );

   fixed_point_multiplier #(.EXP_WIDTH_A(EXP_WIDTH_TWIDDLE), .EXP_WIDTH_B(EXP_WIDTH_INPUT), .EXP_WIDTH_PRODUCT(EXP_WIDTH_INPUT)) MULTIPLY_IMAG_1 (
      .clk(clk),
      .enable(stage_1_full),
      .reset(reset),
      .A(twiddle_real_reg_2),
      .B(diff_imag), 
      .product(imag_1)
   );

   fixed_point_multiplier #(.EXP_WIDTH_A(EXP_WIDTH_TWIDDLE), .EXP_WIDTH_B(EXP_WIDTH_INPUT), .EXP_WIDTH_PRODUCT(EXP_WIDTH_INPUT)) MULTIPLY_IMAG_2 (
      .clk(clk),
      .enable(stage_1_full),
      .reset(reset),
      .A(twiddle_imag_reg_2),
      .B(diff_real),
      .product(imag_2)   
   );

   reg signed [FFT_DW-1:0] sum_stage_3_real, sum_stage_3_imag;
   always @ (posedge clk) begin
      // stage 3 and half
      sum_stage_3_real <= sum_stage_2_real_reupload;
      sum_stage_3_imag <= sum_stage_2_imag_reupload;

      // output (stage 3 full)
      out_A_real <= sum_stage_3_real;
      out_A_imag <= sum_stage_3_imag;
   end 

   fixed_point_truncation_adder OUT_B_REAL (
      .clk(clk),
      .enable(stage_2_full),
      .reset(reset),
      .A(real_1),
      .B(~real_2 + 1'b1),
      .sum(out_B_real)
   );

   fixed_point_truncation_adder OUT_B_IMAG (
      .clk(clk),
      .enable(stage_2_full),
      .reset(reset),
      .A(imag_1),
      .B(imag_2),
      .sum(out_B_imag)
   );

endmodule

