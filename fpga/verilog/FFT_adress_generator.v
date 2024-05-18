module FFT_address_generator (
    // system 
   input wire        clk,
   input wire        rst,

   input wire [4:0]  stageCount,
   input wire        should_run,
   output wire       done,
   
   // asserts if the "FFT_address_generator" is active (i.e. is still generating memory addresses)
   output wire       active,
   output wire [1:0] ctrl,
   output wire       evenOdd, // even/odd cycle control
   output wire [FFT_N-1-1:0] MEMORY_ADDRESS,
   output wire [FFT_N-1-1:0] TWIDDLE_ADDRESS
   );
   
   reg [FFT_N-1-1:0] runCount;
   wire [FFT_N-1-1:0] runCount_pp = runCount + 1;
   wire       runCount_full = &runCount;
   assign evenOdd  = runCount[0];
   
   always @ ( posedge clk ) begin
      if ( rst ) begin
         runCount <= 0;
      end

      // start generating addresses 
      else if ( should_run ) begin
         if ( runCount_full ) begin
            runCount <= runCount;
         end else begin
            runCount <= runCount_pp;
         end
      end

      // "idle" state
      else begin
         runCount <= 0;
      end
   end

   reg runCount_full_f;
   always @ ( posedge clk ) begin
      if ( rst ) begin
         runCount_full_f <= 1'b0;
      end else begin
         runCount_full_f <= runCount_full;
      end
   end

   assign done = runCount_full_f;
   assign active = should_run && !done;

    // 2'h2 = 10
    // {runCount[0], runCount[0]} = {00} or {11}
   assign ctrl = (stageCount == 4'h0) ? 2'h2 : {runCount[0],runCount[0]};

   reg [FFT_N-1-1:0] twiddleFactorCounter;

   always_comb begin
      twiddleFactorCounter = runCount >> stageCount;
   end

   wire [FFT_N-1-1:0] twiddleFactorReversed;
   assign TWIDDLE_ADDRESS =  twiddleFactorReversed ;
   generate
      genvar  i;
      for ( i = 0; i <= (FFT_N-1-1); i++ ) begin : BITREV_BLOCK
         assign twiddleFactorReversed[i] = twiddleFactorCounter[FFT_N-1-1-i];
      end
   endgenerate

   // memory address generation
   reg [FFT_N-1-1:0] memAddr_w;
   assign MEMORY_ADDRESS = memAddr_w;

   reg [FFT_N-1:0]   memAddrLowerMask_;
   always_comb begin
      if ( (stageCount == 0) ||
	   (stageCount == 1) ) begin
	 memAddrLowerMask_ = 0;
      end else begin
	 memAddrLowerMask_ = (('b01) << (stageCount-1)) - 1;
      end
   end
   
   reg [FFT_N-1-1:0] runCountLsbShift_;
   always_comb begin
      if ( (stageCount == 0) ||
	   (stageCount == 1) ) begin
	 runCountLsbShift_ = 0;
      end else begin
	 runCountLsbShift_ = ( runCount[0] << (stageCount-1) );
      end
   end

   reg [FFT_N-1:0] memAddrHigherMask_;
   always_comb begin
      if ( (stageCount == 0) ||
	   (stageCount == 1) ) begin
	 memAddrHigherMask_ = -1;
      end else begin
	 memAddrHigherMask_ = ~(('b01 << (stageCount)) - 1);
      end
   end   
   always_comb begin
      case ( stageCount )
	0,1: memAddr_w = runCount;
	default:
	  begin
	     memAddr_w = 
			 (memAddrLowerMask_  & {1'b0,runCount[FFT_N-1-1:1]} )|
			 (runCountLsbShift_)|
			 (memAddrHigherMask_ & runCount[FFT_N-1-1:0]);
	  end
      endcase
   end
   
endmodule

