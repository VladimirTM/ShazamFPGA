
module ramPipelineBridge
  #(

    parameter FFT_N = 10,
    parameter FFT_DW = 16
    )
  (

   input wire                   clk,
   input wire                   reset,

   input wire                   iact,
   output wire                  oact,

   input wire [1:0]             ictrl,
   output wire [1:0]            octrl,
   // operand mux control
   // 10: 1st Stage
   // 00: 2nd-n Stage EvenCycle
   // 11: 2nd-n Stage OddCycle

   input wire [FFT_N-1-1:0]  input_memory_address,
   input wire [FFT_DW*2-1:0]  input_A,
   input wire [FFT_DW*2-1:0]  input_B,

   output wire [FFT_N-1-1:0] output_memory_address,
   output wire [FFT_DW*2-1:0] output_A,
   output wire [FFT_DW*2-1:0] output_B
   
   );


   reg [FFT_N-1-1:0]         memPipeAddr;
   reg [FFT_DW*2-1:0]         evenPipeData;
   reg [FFT_DW*2-1:0]         oddPipeData;

   always @ ( posedge clk ) begin
      memPipeAddr <= input_memory_address;
      evenPipeData <= input_A;
      oddPipeData <= input_B;
   end

   reg actPipe;
   reg [1:0] ctrlPipe;
   always @ ( posedge clk ) begin
      if ( reset ) begin
         actPipe <= 1'b0;
         ctrlPipe <= 2'h0;
      end else begin
         actPipe <= iact;
         ctrlPipe <= ictrl;
      end
   end

   reg oact_f;
   assign oact = oact_f;
   reg [1:0] ctrl_f;
   assign octrl = ctrl_f;
   always @ ( posedge clk ) begin
      if ( reset ) begin
         oact_f <= 1'b0;
         ctrl_f <= 2'h0;
      end else begin
         oact_f <= actPipe;
         ctrl_f <= ctrlPipe;     
      end
   end

   reg [FFT_N-1-1:0] mem0Addr;
   reg [FFT_DW*2-1:0] ev0Data;
   reg [FFT_DW*2-1:0] od0Data;
   reg [FFT_DW*2-1:0] od1Data;

   always @ ( posedge clk ) begin
      mem0Addr <= memPipeAddr;
      ev0Data <= evenPipeData;
      od0Data <= oddPipeData;
      od1Data <= od0Data;
   end

   assign output_A = ( ctrl_f[0] == 1'b0 ) ? ev0Data      : od1Data;
   assign output_B  = ( ctrl_f[1] == 1'b0 ) ? evenPipeData : od0Data;
   assign output_memory_address = mem0Addr;


endmodule // ramBridgePipeline

  

