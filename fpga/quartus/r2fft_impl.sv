
module FFT_IMPLEMENTATION
  #(
    parameter FFT_LENGTH = 1024, // FFT Frame Length, 2^N
    parameter FFT_DW = 16,       // Data Bitwidth
    parameter PL_DEPTH = 3,      // Pipeline Stage Depth Configuration (0 - 3)
    parameter FFT_N = $clog2( FFT_LENGTH ) // Don't override this
    )
  (

   // system
   input wire 			  clk,
   input wire 			  reset,

    // status
   output reg 			            done,
   output reg [2:0] 		         status_o,
   output reg signed [7:0] 	   bfpexp_o,

    // input stream
   input wire 			             input_stream_active_i,
   input wire signed [FFT_DW-1:0]    input_real_i,
   input wire signed [FFT_DW-1:0]    input_imaginary_i,

   output reg [15:0]                magnitudes [1023:0],
   output reg                       magnitudes_ready
   );


   reg 				      reset_reg;
   reg         [32:0]   result;

   always @ ( posedge clk ) begin
      reset_reg <= reset;
   end
   
   // status
   wire 			               done_wire;
   wire [2:0] 			         status;
   wire signed [7:0] 		   bfpexp;

   always @ ( posedge clk ) begin
      done <= done_wire;
      status_o <= status;
      bfpexp_o <= bfpexp;
   end

   // input stream
   reg 			   input_stream_active;
   reg signed [FFT_DW-1:0] input_real;
   reg signed [FFT_DW-1:0] input_imaginary;

    // output / DMA bus
   reg 			   dmaact;
   reg [FFT_N-1:0] 	   dmaa;
   wire signed [FFT_DW-1:0] dmadr_real;
   wire signed [FFT_DW-1:0] dmadr_imag;

   always @ ( posedge clk ) begin
      input_stream_active <= input_stream_active_i;
      input_real <= input_real_i;
      input_imaginary <= input_imaginary_i;
   end
   
   // twiddle factor rom
   reg 			   twact;
   reg [FFT_N-1-2:0] 	   twa;
   reg [FFT_DW-1:0] 	   twdr_cos;
   
   // block ram0
   reg 			   ract_ram0;
   reg [FFT_N-1-1:0] 	   ra_ram0;
   wire [FFT_DW*2-1:0] 	   rdr_ram0;
   
   reg 			   wact_ram0;
   reg [FFT_N-1-1:0] 	   wa_ram0;
   reg [FFT_DW*2-1:0] 	   wdw_ram0;
   
   // block ram1
   reg 			   ract_ram1;
   reg [FFT_N-1-1:0] 	   ra_ram1;
   wire [FFT_DW*2-1:0] 	   rdr_ram1;
   
   reg 			   wact_ram1;
   reg [FFT_N-1-1:0] 	   wa_ram1;
   reg [FFT_DW*2-1:0] 	   wdw_ram1;
      

   typedef enum logic [2:0] {
      MAGNITUDES_NOT_READY = 3'd0,
      MAGNITUDES_IN_PROGRESS = 3'd1,
      MAGNITUDES_READY = 3'd2,
      MAGNITUDES_PROCESS_DATA = 3'd4,
      MAGNITUDES_ASK_RAM = 3'd5
   } states;

   states current_state = MAGNITUDES_NOT_READY, next_state = MAGNITUDES_NOT_READY;

   reg [33:0] magnitude_temp;
   
   reg [FFT_N - 1: 0] index = 0;

   wire product_done = 0, absolute_value_done = 0;
   wire [15: 0] P1, P2;
   fixed_point_multiplier #(.EXP_WIDTH_A(6), .EXP_WIDTH_B(6), .EXP_WIDTH_PRODUCT(5)) MULTIPLY_REAL_2 (
      .clk(clk),
      .enable(current_state == MAGNITUDES_PROCESS_DATA),
      .A(dmadr_real),
      .B(dmadr_real),
      .done(absolute_value_done),
      .product(P1)
   );

   fixed_point_multiplier #(.EXP_WIDTH_A(6), .EXP_WIDTH_B(6), .EXP_WIDTH_PRODUCT(5)) MULTIPLY_REAL_2 (
      .clk(clk),
      .enable(current_state == MAGNITUDES_PROCESS_DATA),
      .A(dmadr_imag),
      .B(dmadr_imag),
      .done(),
      .product(P2)
   );

   fixed_point_adder OUT_B_REAL (
      .clk(clk),
      .enable(stage_2_full),
      .A(real_1),
      .B(~real_2 + 1),
      .sum(out_B_real)
   );

   always @ (*) begin 
      if(reset) next_state = MAGNITUDES_NOT_READY;
      case (current_state)
         MAGNITUDES_NOT_READY: begin
            magnitudes_ready <= 0;
            index <= 0;
            if(done_wire) next_state <= MAGNITUDES_IN_PROGRESS;
            else next_state <= MAGNITUDES_NOT_READY;
         end
         MAGNITUDES_ASK_RAM: begin
            magnitudes_ready <= 0;
            dmaact <= 1;
            dmaa <= index;
            next_state <= MAGNITUDES_PROCESS_DATA;
         end
         MAGNITUDES_PROCESS_DATA: begin
            if(!absolute_value_done) begin 
               
               next_state <= MAGNITUDES_PROCESS_DATA
            end 
            // two numbers on 16 bits with 4 bits fractional parts: 0000_0000_0000.0000
            // the product of 2 of those numbers will be: xxxx_xxxx_xxxx_[0000_0000_0000.0000]_xxxx
            // to eliminate the 
            magnitude_temp <= (dmadr_real * dmadr_real + dmadr_imag * dmadr_imag);
         end
         // MAGNITUDESS_STORE_DATA: begin
            
         // end 
         MAGNITUDES_READY: begin
            magnitudes_ready = 1;
            next_state = MAGNITUDES_NOT_READY;
         end
      endcase
   end

   R2FFT
     #(
       .FFT_LENGTH(FFT_LENGTH),
       .FFT_DW(FFT_DW),
       .PL_DEPTH(PL_DEPTH)
       )
   uR2FFT
     (
      .clk( clk ),
      .reset( reset_reg ),
      
      .autorun(1),
      .run(0),
      .fin(0),
      .ifft(0),
      
      .done( done_wire ),
      .status( status ),
      .bfpexp( bfpexp ),

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

   twrom utwrom
     (
      .address( twa ),
      .clock( clk ),
      .q( twdr_cos )
      );

   dpram ram0
     (
      .clock( clk ),
      .data( wdw_ram0 ),
      .rdaddress( ra_ram0 ),
      .wraddress( wa_ram0 ),
      .q( rdr_ram0 )
      );

   dpram ram1
     (
      .clock( clk ),
      .data( wdw_ram1 ),
      .rdaddress( ra_ram1 ),
      .wraddress( wa_ram1 ),
      .q( rdr_ram1 )
      );
   
endmodule // r2fft_impl

