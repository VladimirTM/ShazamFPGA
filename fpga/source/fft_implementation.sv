
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

   output wire                   done_all_processing,
   output reg [2:0] 		         status_o,
   output reg signed [7:0] 	   bfpexp_o,
   output                        done_FFT,

    // input stream
   input wire 			               input_stream_active_i,
   input wire signed [FFT_DW-1:0]    input_real_i,
   input wire signed [FFT_DW-1:0]    input_imaginary_i,

   output wire [15:0]               dmadr_real_output,
   output wire [15:0]               dmadr_imag_output,
   output wire                      dmadr_ready,
   
   output wire [15:0]               P1_out,
   output wire [15:0]               P2_out,
   output wire [15:0]               P_active,

   input wire  [8:0]               index,                
   output reg   [15:0]              magnitude,
   output reg                       magnitude_ready
   );


   reg         done_all_processing_reg = 0;
   assign      done_all_processing = done_all_processing_reg;

   reg         reset_reg;
   reg [32:0]  result;

   always @ ( posedge clk ) begin
      reset_reg <= reset;
   end
   
   // status
   wire   done_FFT_wire;
   assign done_FFT = done_FFT_wire;

   wire [2:0] 			         status;
   wire signed [7:0] 		   bfpexp;


   always @ ( posedge clk ) begin
      status_o <= status;
      bfpexp_o <= bfpexp;
   end

   // input stream
   reg 			   input_stream_active;
   reg signed [FFT_DW-1:0] input_real;
   reg signed [FFT_DW-1:0] input_imaginary;

    // output / DMA bus
   reg 			               dmaact;
   reg [FFT_N-1:0] 	         dmaa;
   wire signed [FFT_DW-1:0]   dmadr_real;
   wire signed [FFT_DW-1:0]   dmadr_imag;

   assign dmadr_real_output = dmadr_real;
   assign dmadr_imag_output = dmadr_imag;

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
      MAGNITUDES_ASK_RAM = 3'd2,
      MAGNITUDES_WAIT_RAM = 3'd3,
      MAGNITUDES_PROCESS_DATA = 3'd4,
      MAGNITUDES_STORE_DATA = 3'd5,
      MAGNITUDES_FINISH = 3'd6
   } states;

   states current_state = MAGNITUDES_NOT_READY;
   

   wire product_done, absolute_value_done;
   wire signed [15: 0] P1, P2, absolute_value;

   assign dmadr_ready = current_state == MAGNITUDES_PROCESS_DATA;
   assign P1_out = P1;
   assign P2_out = P2;
   assign P_active = product_done;

   fixed_point_multiplier #(.EXP_WIDTH_A(5), .EXP_WIDTH_B(5), .EXP_WIDTH_PRODUCT(0)) MULTIPLY_REAL (
      .clk(clk),
      .enable(current_state == MAGNITUDES_PROCESS_DATA),
      .reset(reset),
      .A(dmadr_real),
      .B(dmadr_real),
      .done(product_done),
      .product(P1)
   );

   fixed_point_multiplier #(.EXP_WIDTH_A(5), .EXP_WIDTH_B(5), .EXP_WIDTH_PRODUCT(0)) MULTIPLY_IMAG (
      .clk(clk),
      .reset(reset),
      .enable(current_state == MAGNITUDES_PROCESS_DATA),
      .A(dmadr_imag),
      .B(dmadr_imag),
      .product(P2)
   );

   fixed_point_adder ADD (
      .clk(clk),
      .enable(product_done),
      .A(P1),
      .B(P2),
      .sum(absolute_value),
      .done(absolute_value_done)
   );

   always @ (posedge clk) begin 
      if(reset) begin 
         current_state <= MAGNITUDES_NOT_READY;
         dmaact <= 0;
      end 
      case (current_state)
         MAGNITUDES_NOT_READY: begin
            if(!done_FFT_wire) begin
               done_all_processing_reg <= 0;
               dmaact <= 0;
            end
            magnitude_ready <= 0;
            dmaact <= 0;
            if(done_FFT_wire && !done_all_processing) current_state <= MAGNITUDES_ASK_RAM;
            else current_state <= MAGNITUDES_NOT_READY;
         end
         MAGNITUDES_ASK_RAM: begin
            current_state <= MAGNITUDES_WAIT_RAM;
            dmaact <= 1;
            magnitude_ready <= 0;
            dmaa <= {1'b0, index};
         end
         MAGNITUDES_WAIT_RAM: begin
            dmaact <= 0;
            magnitude_ready <= 0;
            current_state <= MAGNITUDES_PROCESS_DATA;
         end 
         MAGNITUDES_PROCESS_DATA: begin
            magnitude_ready <= 0;
            dmaact <= 0;
            if(!absolute_value_done) begin 
               current_state <= MAGNITUDES_PROCESS_DATA;
            end 
            else current_state <= MAGNITUDES_STORE_DATA;
         end
         MAGNITUDES_STORE_DATA: begin
            dmaact <= 0;
            magnitude_ready <= 1;
            magnitude <= absolute_value;

            if(index == 511) current_state <= MAGNITUDES_FINISH;
            else current_state <= MAGNITUDES_ASK_RAM;
         end
         MAGNITUDES_FINISH: begin
            dmaact <= 0;
            magnitude_ready <= 0;
            done_all_processing_reg <= 1;
            current_state <= MAGNITUDES_NOT_READY;
         end 
      endcase
   end

   R2FFT
     #(
       .FFT_LENGTH(FFT_LENGTH),
       .FFT_DW(FFT_DW)
       )
   uR2FFT
     (
      .clk( clk ),
      .rst( reset_reg ),
      
      .autorun(1),
      .run(0),
      .fin(0),
      .ifft(0),
      
      .done( done_FFT_wire ),
      .status( status ),
      .bfpexp( bfpexp ),

      .sact_istream( input_stream_active ),
      .sdw_istream_real( input_real ),
      .sdw_istream_imag( input_imaginary ),

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
      .wren(wact_ram0),
      .q( rdr_ram0 )
      );

   dpram ram1
     (
      .clock( clk ),
      .data( wdw_ram1 ),
      .rdaddress( ra_ram1 ),
      .wraddress( wa_ram1 ),
      .wren(wact_ram1),
      .q( rdr_ram1 )
      );
   
endmodule // r2fft_impl

