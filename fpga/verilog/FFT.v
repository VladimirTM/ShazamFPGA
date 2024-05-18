module FFT
  #(
    parameter FFT_LENGTH = 1024,     // FFT Frame Length, 2^N
    parameter DATA_WIDTH = 16,       // Data width in bits
    parameter PL_DEPTH = 3,          // Pipeline Stage Depth Configuration (0 - 3)
    parameter FFT_N = 10
  )
   (
    // system
    input wire 			    clk,
    input wire 			    rst,

    // status
    output wire 		             done,
    output wire [2:0] 		         status,
    output wire signed [7:0] 	     bfpexp,

    // input stream
    input wire 			                input_stream_active, // input data bus active.
    input wire signed [DATA_WIDTH-1:0]  real_input,
    input wire signed [DATA_WIDTH-1:0]  imaginary_input,

    // output / DMA bus
    input wire 			                dmaact,
    input wire [FFT_N-1:0] 	            dmaa,
    output wire signed [DATA_WIDTH-1:0] dmadr_real,
    output wire signed [DATA_WIDTH-1:0] dmadr_imag,
    
    // twiddle factor rom
    output wire 		                twact,
    output wire [FFT_N-1-2:0] 	        twa,
    input wire [DATA_WIDTH-1:0] 	    twdr_cos, // can be used in testbench instead of initializing memory with .mif file 
    
    // block ram0
    output wire 		                ram0_read_active, // dual port ram0 read bus active.
    output wire [FFT_N-1-1:0] 	        ram0_read_address, // dual port ram0 read address. 
    input wire [DATA_WIDTH*2-1:0] 	    ram0_read_data, // dual port ram0 read data (used in testbench to show what data is in the memory that "ram0_read_address" point to)
   
    output wire 		                ram0_write_active, // dual port ram0 write bus active.
    output wire [FFT_N-1-1:0] 	        ram0_write_address, // dual port ram0 write address
    output wire [DATA_WIDTH*2-1:0] 	    ram0_write_data, // dual port ram0 write data.
   
    // block ram1
    output wire 		                ram1_read_active,
    output wire [FFT_N-1-1:0] 	        ram1_read_address,
    input wire [DATA_WIDTH*2-1:0] 	    ram1_read_data,

    output wire 		                ram1_write_active,
    output wire [FFT_N-1-1:0] 	        ram1_write_address,
    output wire [DATA_WIDTH*2-1:0] 	    ram1_write_data
   
    );
   
   // fft status
   typedef enum logic [2:0] {
        IDLE = 3'd0,
        READING_INPUT_STREAM = 3'd1,
        RUN_FFT = 3'd2,
        DONE = 3'd3
    } STATE;
   
   STATE current_state;
   STATE next_state;
   
   assign done = current_state[2];
   assign status = current_state;
   
   ////////////////////////////////
   // Main State Machine
   ///////////////////////////////
   
   wire      current_FFT_is_done;
   wire      streamBufferFull;
   
   always_comb begin
      case ( current_state )
        IDLE:
          begin
             next_state = READING_INPUT_STREAM;
          end
        
        READING_INPUT_STREAM:
          begin
            if ( streamBufferFull && input_stream_active ) begin
                next_state = RUN_FFT;
            end
            else begin
                next_state = READING_INPUT_STREAM;
            end
          end

        RUN_FFT:
          begin
             if ( current_FFT_is_done ) begin
                next_state = DONE;
             end else begin
                next_state = RUN_FFT;
             end
          end

        DONE: begin
            next_state = DONE;
        end
        
        default:
          begin
             next_state = IDLE;
          end
        
      endcase
   end

   always @ ( posedge clk ) begin
      if ( rst ) begin
         current_state <= IDLE;
      end else begin
         current_state <= next_state;
      end
   end
   
   localparam MODE_READING_INPUT_STREAM = 0;
   localparam MODE_RUN_FFT = 1;
   localparam MODE_DMA = 2;
   localparam MODE_DISABLE = 3;
   
   reg [1:0] ramAccessMode;
   always_comb begin
      case ( current_state )
        READING_INPUT_STREAM:   ramAccessMode = MODE_READING_INPUT_STREAM;
        RUN_FFT:                ramAccessMode = MODE_RUN_FFT;
        DONE:                   ramAccessMode = MODE_DMA;
        default:                ramAccessMode = MODE_DISABLE;
      endcase
   end

   wire [FFT_N-1:0] address_of_FFT_input;
   
   // signal for resetting the memory pointer when we are done reading from an input stream
   wire is_reading_input_stream = (current_state == READING_INPUT_STREAM);
   
   bit_reversed_address_locations MAKE_BIT_REVERSE_OF_INPUT_STREAM
     (
      .rst( rst ),
      .clk( clk ),
      // do NOT clear while reading from an input stream. 
      // when "reading": current_state = READING_INPUT_STREAM, hence "is_reading_input_stream" == true and clr == false 
      // when "streamBufferFull == true": current_state = RUN_FFT, "is_reading_input_stream" == false and clr == true
      .clr( !is_reading_input_stream ),
      .inc( input_stream_active ),
      .bit_reversed_address( address_of_FFT_input ),
      .count(),
      .countFull( streamBufferFull )
      );

   
   ///////////////////////
   // fft sub sequencer
   ///////////////////////
   wire        run_fft = ( current_state == RUN_FFT );

   localparam MAX_FFT_STAGE = (FFT_N-1);

   typedef enum {
        SUB_STATE_FFT_IDLE,
        SUB_STATE_FFT_SETUP,
        SUB_STATE_FFT_RUN,
        SUB_STATE_FFT_WAIT_PIPELINE,
        SUB_STATE_FFT_NEXT_STAGE,
        SUB_STATE_FFT_DONE
} SUB_STATE_FFT;
   
   SUB_STATE_FFT  sub_state_fft_CURRENT_STATE;
   SUB_STATE_FFT  sub_state_fft_NEXT_STATE;
       
   assign current_FFT_is_done = ( sub_state_fft_CURRENT_STATE == SUB_STATE_FFT_DONE );

   // bits needed to count in binary what FFT stage we are at.
   // because we can have 10 stages we need 4 bits to represent each stage: 0 -> [0000], 1 -> [0001], 2 -> [0010], ..., 9 -> [1001] 
   localparam STAGE_COUNT_BW = 4; 
   
   reg [STAGE_COUNT_BW-1:0] fftStageCount = 0;

   wire        fftStageCountFull = (fftStageCount == MAX_FFT_STAGE);
   
   wire        memory_generator_DONE;
   wire        oactFftUnit;
   
   always_comb begin
      if ( !run_fft ) begin
         sub_state_fft_NEXT_STATE = SUB_STATE_FFT_IDLE;
      end else begin
         case ( sub_state_fft_CURRENT_STATE )
           SUB_STATE_FFT_IDLE:  sub_state_fft_NEXT_STATE = SUB_STATE_FFT_SETUP;
           SUB_STATE_FFT_SETUP: sub_state_fft_NEXT_STATE = SUB_STATE_FFT_RUN;

           SUB_STATE_FFT_RUN:
             begin
                if ( memory_generator_DONE ) begin
                   sub_state_fft_NEXT_STATE = SUB_STATE_FFT_WAIT_PIPELINE;
                end else begin
                   sub_state_fft_NEXT_STATE = SUB_STATE_FFT_RUN;
                end
             end

           SUB_STATE_FFT_WAIT_PIPELINE:
             begin
                if ( oactFftUnit ) begin
                   sub_state_fft_NEXT_STATE = SUB_STATE_FFT_WAIT_PIPELINE;
                end else begin
                   sub_state_fft_NEXT_STATE = SUB_STATE_FFT_NEXT_STAGE;
                end
             end

           SUB_STATE_FFT_NEXT_STAGE:
             begin
                if ( fftStageCountFull ) begin
                   sub_state_fft_NEXT_STATE = SUB_STATE_FFT_DONE;
                end else begin
                   sub_state_fft_NEXT_STATE = SUB_STATE_FFT_RUN;
                end
             end

           SUB_STATE_FFT_DONE:
             begin
                sub_state_fft_NEXT_STATE = SUB_STATE_FFT_DONE;
             end

           default: sub_state_fft_NEXT_STATE = SUB_STATE_FFT_IDLE;
           
         endcase // case ( sub_state_fft_CURRENT_STATE )
      end
   end

   always @ ( posedge clk ) begin
      if ( rst ) begin
         sub_state_fft_CURRENT_STATE <= SUB_STATE_FFT_IDLE;
      end else begin
         sub_state_fft_CURRENT_STATE <= sub_state_fft_NEXT_STATE;
      end
   end

   always @ ( posedge clk ) begin
      if ( rst ) begin
         fftStageCount <= 0;
      end else begin
         case ( sub_state_fft_CURRENT_STATE )
           SUB_STATE_FFT_IDLE,SUB_STATE_FFT_SETUP: fftStageCount <= 0;
           SUB_STATE_FFT_NEXT_STAGE:    fftStageCount <= fftStageCount + 1;
         endcase // case ( sub_state_fft_CURRENT_STATE )
      end
   end
      
   wire FFT_unit_active;
   wire [1:0] ictrlFftUnit;
   wire       evenOdd;

   wire [FFT_N-1-1:0] MEMORY_ADDRESS;
   wire [FFT_N-1-1:0] TWIDDLE_ADDRESS;
   
   FFT_address_generator GENERATE_MEMORY_ADDRESSES
     (
      .clk( clk ),
      .rst( rst ),
      .stageCount( fftStageCount ),
      .should_run( sub_state_fft_CURRENT_STATE == SUB_STATE_FFT_RUN ),
      .done( memory_generator_DONE ),

      .active( FFT_unit_active ),
      .ctrl( ictrlFftUnit ),
      .evenOdd( evenOdd ),
      .MEMORY_ADDRESS( MEMORY_ADDRESS ),
      .TWIDDLE_ADDRESS( TWIDDLE_ADDRESS )
      
      );
   
   // block ram0
   wire       ract_fft0;
   wire [FFT_N-1-1:0] ra_fft0;
   wire [DATA_WIDTH*2-1:0] rdr_fft0;
   
   wire        wact_fft0;
   wire [FFT_N-1-1:0]  wa_fft0;
   wire [DATA_WIDTH*2-1:0] wdw_fft0;
   
   // block ram1
   wire        ract_fft1;
   wire [FFT_N-1-1:0]  ra_fft1;
   wire [DATA_WIDTH*2-1:0] rdr_fft1;

   wire        wact_fft1;
   wire [FFT_N-1-1:0]  wa_fft1;
   wire [DATA_WIDTH*2-1:0] wdw_fft1;
   
   butterflyUnit 
     #(
       .FFT_N(FFT_N),
       .DATA_WIDTH(DATA_WIDTH),
       .PL_DEPTH(PL_DEPTH)
       )
   ubutterflyUnit
     (
      
      .clk( clk ),
      .rst( rst ),
      
      .clr_bfp( sub_state_fft_CURRENT_STATE == SUB_STATE_FFT_NEXT_STAGE ),
      
      .ibfp( currentBfpBw ),
      .obfp( nextBfpBw ),
      
      .iact( FFT_unit_active ),
      .oact( oactFftUnit ),
      
      .ictrl( ictrlFftUnit ),
      .octrl( ),
      
      .MEMORY_ADDRESS( MEMORY_ADDRESS ),
      .TWIDDLE_ADDRESS( TWIDDLE_ADDRESS ),

      .evenOdd( evenOdd ),

      .twact( twact ),
      .twa( twa ),
      .twdr_cos( twdr_cos ),
      
      .ram0_read_active( ract_fft0 ),
      .ram0_read_address( ra_fft0 ),
      .ram0_read_data( rdr_fft0 ),
      
      .ram0_write_active( wact_fft0 ),
      .ram0_write_address( wa_fft0 ),
      .ram0_write_data( wdw_fft0 ),
      
      .ram1_read_active( ract_fft1 ),
      .ram1_read_address( ra_fft1 ),
      .ram1_read_data( rdr_fft1 ),
      
      .ram1_write_active( wact_fft1 ),
      .ram1_write_address( wa_fft1 ),
      .ram1_write_data( wdw_fft1 )
      
      );

   reg         dmaa_lsb;
   always @ ( posedge clk ) begin
      dmaa_lsb <= dmaa[0];
   end

   wire [DATA_WIDTH*2-1:0] rdr_dma0;
   readBusMux 
     #(
       .FFT_N(FFT_N),
       .DATA_WIDTH(DATA_WIDTH),
       .MODE_READING_INPUT_STREAM(MODE_READING_INPUT_STREAM),
       .MODE_RUN_FFT(MODE_RUN_FFT),
       .MODE_DMA(MODE_DMA),
       .MODE_DISABLE(MODE_DISABLE)
       )
     readBusMuxEven
     (
      .mode( ramAccessMode ),
      
      .ract_fft( ract_fft0 ),
      .ra_fft( ra_fft0 ),
      .rdr_fft( rdr_fft0 ),
      
      .ract_dma( dmaact && (dmaa[0] == 1'b0) ),
      .ra_dma( dmaa[FFT_N-1:1] ),
      .rdr_dma( rdr_dma0 ),

      .ract_ram( ram0_read_active ),
      .ra_ram( ram0_read_address ),
      .rdr_ram( ram0_read_data )
      );

   wire [DATA_WIDTH*2-1:0] rdr_dma1;
   readBusMux 
     #(
       .FFT_N(FFT_N),
       .DATA_WIDTH(DATA_WIDTH),
       .MODE_READING_INPUT_STREAM(MODE_READING_INPUT_STREAM),
       .MODE_RUN_FFT(MODE_RUN_FFT),
       .MODE_DMA(MODE_DMA),
       .MODE_DISABLE(MODE_DISABLE)
       )
   readBusMuxOdd
     (
      .mode( ramAccessMode ),

      .ract_fft( ract_fft1 ),
      .ra_fft( ra_fft1 ),
      .rdr_fft( rdr_fft1 ),

      .ract_dma( dmaact && (dmaa[0] == 1'b1) ),
      .ra_dma( dmaa[FFT_N-1:1] ),
      .rdr_dma( rdr_dma1 ),

      .ract_ram( ram1_read_active ),
      .ra_ram( ram1_read_address ),
      .rdr_ram( ram1_read_data )
      );

   assign { dmadr_imag, dmadr_real } = (dmaa_lsb == 1'b0) ? rdr_dma0 : rdr_dma1;
   
   writeBusMux 
     #(
       .FFT_N(FFT_N),
       .DATA_WIDTH(DATA_WIDTH),
       .MODE_READING_INPUT_STREAM(MODE_READING_INPUT_STREAM),
       .MODE_RUN_FFT(MODE_RUN_FFT),
       .MODE_DMA(MODE_DMA),
       .MODE_DISABLE(MODE_DISABLE)
       )
   writeBusMuxEven
     (
      .mode( ramAccessMode ),

      .wact_fft( wact_fft0 ),
      .wa_fft( wa_fft0 ),
      .wdw_fft( wdw_fft0 ),

      .wact_istream( input_stream_active && (address_of_FFT_input[0] == 1'b0) ),
      .wa_istream( address_of_FFT_input[FFT_N-1:1] ),
      .wdw_istream( { imaginary_input, real_input } ),

      .wact_ram( ram0_write_active ),
      .wa_ram( ram0_write_address ),
      .wdw_ram( ram0_write_data )      
      );

   writeBusMux 
     #(
       .FFT_N(FFT_N),
       .DATA_WIDTH(DATA_WIDTH),
       .MODE_READING_INPUT_STREAM(MODE_READING_INPUT_STREAM),
       .MODE_RUN_FFT(MODE_RUN_FFT),
       .MODE_DMA(MODE_DMA),
       .MODE_DISABLE(MODE_DISABLE)
       )
     writeBusMuxOdd
     (
      .mode ( ramAccessMode ),

      .wact_fft( wact_fft1 ),
      .wa_fft( wa_fft1 ),
      .wdw_fft( wdw_fft1 ),

      .wact_istream( input_stream_active && (address_of_FFT_input[0] == 1'b1) ),
      .wa_istream( address_of_FFT_input[FFT_N-1:1] ),
      .wdw_istream( { imaginary_input, real_input } ),

      .wact_ram( ram1_write_active ),
      .wa_ram( ram1_write_address ),
      .wdw_ram( ram1_write_data )
      
      );
   
endmodule // R2FFT
