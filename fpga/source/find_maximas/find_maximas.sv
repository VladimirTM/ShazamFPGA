module find_maximas (
  input clk,
  input start,
  input reset,
  input [15:0] data_in [511:0],
  output [24:0] data_out [15:0],
  output wire output_active
);
  wire [24:0] stage_1_output [255:0];
  wire [24:0] stage_2_output [127:0];
  wire [24:0] stage_3_output [63:0];
  wire [24:0] stage_4_output [31:0];
  wire [24:0] stage_5_output [15:0];

  wire stage_1_output_active;

 reduction_stage_1 stage1(
    .clk(clk),
    .load(start),
    .in(data_in),
    .out(stage_1_output),
    .out_active(stage_1_output_active),
    .reset(reset)
 );
  
  reg [24:0] stage_2_input [255:0];
  reg stage_2_output_active;
  always @(posedge clk) begin
   if(reset) begin
    	stage_2_output_active <= 0;
    end 
    else begin
      stage_2_input <= stage_1_output;
      stage_2_output_active <= stage_1_output_active;
    end  
 end 
  
reduction #(256) stage2(
  .in(stage_2_input),
  .out(stage_2_output)
);
  
  reg [24:0] stage_3_input [127:0];
  reg stage_3_output_active;
  always @(posedge clk) begin
   if(reset) begin
    	stage_3_output_active <= 0;
    end 
    else begin
      stage_3_input <= stage_2_output;
      stage_3_output_active <= stage_2_output_active;
    end 
  end 
  reduction #(128) stage3(
  .in(stage_3_input),
  .out(stage_3_output)
);

  reg [24:0] stage_4_input [63:0];
  reg stage_4_output_active;
  always @(posedge clk) begin
   if(reset) begin
    	stage_4_output_active <= 0;
    end 
    else begin
      stage_4_input <= stage_3_output;
      stage_4_output_active <= stage_3_output_active;
    end 
   end
reduction #(64) stage4(
  .in(stage_4_input),
  .out(stage_4_output)
);
  
  reg [24:0] stage_5_input [31:0];
  reg stage_5_output_active;
  always @(posedge clk) begin
   if(reset) begin
    	stage_5_output_active <= 0;
    end 
    else begin
      stage_5_input <= stage_4_output;
      stage_5_output_active <= stage_4_output_active;
  	end
  end 
reduction #(32) stage5(
  .in(stage_5_input),
  .out(stage_5_output)
);
  
  reg [24:0] result [15:0];
  reg output_active_reg;
  always @(posedge clk) begin
    if(reset) begin
      	output_active_reg <= 0;
    end else begin 
      result <= stage_5_output;
      output_active_reg <= stage_5_output_active;
    end  
 end 
  
  assign data_out = result;
  assign output_active = output_active_reg;
  
endmodule