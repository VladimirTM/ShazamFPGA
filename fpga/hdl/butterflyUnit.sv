
module butterflyUnit
  #(
    parameter FFT_N = 10,
    parameter FFT_DW = 16,
    parameter FFT_MAX_BIT_WIDTH = 5,
    parameter PL_DEPTH = 3
    )
  (
   input wire                  clk,
   input wire                  reset,

   input wire                  clr_bfp,
   input wire [FFT_MAX_BIT_WIDTH-1:0]  ibfp,
   output wire [FFT_MAX_BIT_WIDTH-1:0] max_bit_width_current_FFT_stage,
   
   input wire                  iact,
   output reg                  oact,

   input wire [1:0]            ictrl,
   output reg [1:0]            octrl,

   // from FFT Index generator
   input wire [FFT_N-1-1:0]    MemAddr,
   input wire [FFT_N-1-1:0]    twiddleFactorAddr,

   input wire                  evenOdd,
   input wire                  ifft,

   // twiddle rom
   output wire                 twact,
   output wire [FFT_N-1-2:0]   twa,
   input wire [FFT_DW-2:0]   twdr_cos,
   
   // block ram0 32-bit x 512 words
   output wire                 ract_ram0,
   output wire [FFT_N-1-1:0]   ra_ram0,
   input wire [FFT_DW*2-1:0]   rdr_ram0,
   
   output reg                  wact_ram0,
   output reg [FFT_N-1-1:0]    wa_ram0,
   output reg [FFT_DW*2-1:0]   wdw_ram0,
   
   // block ram1 32-bit x 512 words
   output wire                 ract_ram1,
   output wire [FFT_N-1-1:0]   ra_ram1,
   input wire [FFT_DW*2-1:0]   rdr_ram1,
   
   output reg                  wact_ram1,
   output reg [FFT_N-1-1:0]    wa_ram1,
   output reg [FFT_DW*2-1:0]   wdw_ram1
   
   );

   wire [FFT_DW-1:0]    tdr_rom_real;
   wire [FFT_DW-1:0]    tdr_rom_imag;

   // Twiddle Factor ROM Access
   twiddleFactorRomBridge 
     #(
       .FFT_N(FFT_N),
       .FFT_DW(FFT_DW)
       )
     utwiddleFactorRomBridge
     (
      .clk( clk ),
      .reset( reset ),

      .tact_rom( iact ),
      .evenOdd( evenOdd ),
      .ifft( ifft ),
      
      .ta_rom( twiddleFactorAddr ),
      .tdr_rom_real( tdr_rom_real ),
      .tdr_rom_imag( tdr_rom_imag ),

      // rom port
      .twact( twact ),
      .twa( twa ),
      .twdr_cos( twdr_cos )
      
      );
   
     
   // SRAM Read Access
   assign ract_ram0 = iact;
   assign ra_ram0 = MemAddr;

   assign ract_ram1 = iact;
   assign ra_ram1 = MemAddr;

   wire [FFT_DW*2-1:0]       input_A = rdr_ram0;
   wire [FFT_DW*2-1:0]       input_B = rdr_ram1;
   
   reg                         act;
   reg [1:0]                   ctrl;
   reg [FFT_N-1-1:0]        input_memory_address;

   always @ ( posedge clk ) begin
      if ( reset ) begin
         act <= 1'b0;
         ctrl <= 2'h0;
      end else begin
         act <= iact;
         ctrl <= ictrl;
      end
   end // always @ ( posedge clk )

   always @ ( posedge clk ) begin
         input_memory_address <= MemAddr;
   end
   
   // twiddle factor rom access
   reg [FFT_DW-1:0]                   twiddle_real;
   reg [FFT_DW-1:0]                   twiddle_imag;

   always_comb begin
      twiddle_real = tdr_rom_real;
      twiddle_imag = tdr_rom_imag;
   end

   wire [FFT_N-1-1:0] output_memory_address;
   wire [FFT_DW*2-1:0] output_A;
   wire [FFT_DW*2-1:0] output_B;

   wire                oactCore;
   wire [1:0]          octrlCore;
   
   wire [FFT_MAX_BIT_WIDTH-1:0] max_bit_width_after_butterfly;
   
   butterflyCore 
     #(
       .FFT_N(FFT_N),
       .FFT_DW(FFT_DW),
       .FFT_MAX_BIT_WIDTH(FFT_MAX_BIT_WIDTH),
       .PL_DEPTH(PL_DEPTH)
       )
   ubutterflyCore
     (
      .clk( clk ),
      .reset( reset ),
      .clr_bfp( clr_bfp ),
      .max_bit_width_after_butterfly( max_bit_width_after_butterfly ),
      
      .ibfp( ibfp ),
      
      .iact( act ),
      .ictrl( ctrl ),

      .oact( oactCore ),
      .octrl( octrlCore ),
      
      .input_memory_address( input_memory_address ),
      .input_A( input_A ),
      .input_B( input_B ),
      
      .output_memory_address( output_memory_address ),
      .output_A( output_A ),
      .output_B( output_B ),
      
      .twiddle_real( twiddle_real ),
      .twiddle_imag( twiddle_imag )
      );

   reg [FFT_MAX_BIT_WIDTH-1:0]  max_bit_width_after_butterfly_reg;


   generate if ( PL_DEPTH >= 3 ) begin
   
      always @ ( posedge clk ) begin
         oact <= reset ? 1'b0 : oactCore;
         octrl <= octrlCore;
         
         wact_ram0 <= oactCore;
         wa_ram0 <= output_memory_address;
         wdw_ram0 <= output_A;
         
         wact_ram1 <= oactCore;
         wa_ram1 <= output_memory_address;
         wdw_ram1 <= output_B;
         
         max_bit_width_after_butterfly_reg <= max_bit_width_after_butterfly;
      end

   end else begin

      always_comb begin
         oact = oactCore;
         octrl = octrlCore;   
         wact_ram0 = oactCore;
         wa_ram0 = output_memory_address;
         wdw_ram0 = output_A;
         
         wact_ram1 = oactCore;
         wa_ram1 = output_memory_address;
         wdw_ram1 = output_B;
         
         max_bit_width_after_butterfly_reg = max_bit_width_after_butterfly;
      end // always @ ( posedge clk )
      
   end endgenerate // else: !if( PL_DEPTH >= 3 )
   

   bfp_maxBitWidth 
     #(
       .FFT_MAX_BIT_WIDTH(FFT_MAX_BIT_WIDTH)
       )
     ubfp_maxBitWidth
     (
      .clk( clk ),
      .reset( reset ),
      .clr( clr_bfp ),
      
      // oact will be HIGH only after the butterfly has been computed and stored to ram
      // so this can find the max bit width of all this FFT stage
      .max_bit_width_activate( oact ),
      .current_variable_bit_width( max_bit_width_after_butterfly_reg ),
      .max_bit_width_all_stream( max_bit_width_current_FFT_stage )
      );
   
   
endmodule // butterflyUnit


