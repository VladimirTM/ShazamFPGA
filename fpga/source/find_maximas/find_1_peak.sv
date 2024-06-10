module find_1_peak (
  input clk,
  input start,
  input reset,
  input [24:0] data_in [511:0],
  output reg [24:0] peak,
  output reg [8:0] peak_index,
  output wire output_active
);

  wire [24:0] stage_1_output [255:0];
  wire [24:0] stage_2_output [127:0];
  wire [24:0] stage_3_output [63:0];
  wire [24:0] stage_4_output [31:0];
  wire [24:0] stage_5_output [15:0];
  wire [24:0] stage_6_output [7:0];
  wire [24:0] stage_7_output [3:0];
  wire [24:0] stage_8_output [1:0];

  reg stage_1_output_active;
  always @(posedge clk) begin
   if(reset) begin
    	stage_1_output_active <= 0;
    end 
    else begin
      stage_1_output_active <= start;
    end  
 end 
  
  reduction #(512) stage1(
    .reset(reset),
    .in(data_in),
    .out(stage_1_output)
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
    .reset(reset),
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
    .reset(reset),
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
    .reset(reset),
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
    .reset(reset),
  .in(stage_5_input),
  .out(stage_5_output)
);

  reg [24:0] stage_6_input [15:0];
  reg stage_6_output_active;
 reduction #(16) stage6(
    .reset(reset),
  .in(stage_6_input),
  .out(stage_6_output)
);
  
  always @(posedge clk) begin
    if(reset) begin
      	stage_6_output_active <= 0;
    end else begin 
      stage_6_input <= stage_5_output;
      stage_6_output_active <= stage_5_output_active;
    end  
 end

  reg [24:0] stage_7_input [7:0];
  reg stage_7_output_active;
 reduction #(8) stage7(
    .reset(reset),
  .in(stage_7_input),
  .out(stage_7_output)
);
  
  always @(posedge clk) begin
    if(reset) begin
      	stage_7_output_active <= 0;
    end else begin 
      stage_7_input <= stage_6_output;
      stage_7_output_active <= stage_6_output_active;
    end  
 end

  reg [24:0] stage_8_input [3:0];
  reg stage_8_output_active;
  reduction #(4) stage8(
    .reset(reset),
  .in(stage_8_input),
  .out(stage_8_output)
  );
  
  always @(posedge clk) begin
    if(reset) begin
      	stage_8_output_active <= 0;
    end else begin 
      stage_8_input <= stage_7_output;
      stage_8_output_active <= stage_7_output_active;
    end  
 end

  reg [24:0] stage_9_input [1:0];
  wire [24:0] stage_9_output [0:0];
  reduction #(2) stage9(
    .reset(reset),
    .in(stage_9_input),
    .out(stage_9_output)
  );

  localparam THRESHOLD = 64; // 4 * 2^4
  
  reg output_active_reg;
  always @(posedge clk) begin
    if(reset) begin
      	output_active_reg <= 0;
    end else begin 
      stage_9_input <= stage_8_output;
      output_active_reg <= stage_8_output_active;
      peak <= (stage_9_output[0][15:0] > THRESHOLD) ? stage_9_output[0] : 0;
      peak_index <= (stage_9_output[0][15:0] > THRESHOLD) ? stage_9_output[0][24:16] : 0;
    end  
 end
  
  assign output_active = output_active_reg;
  
endmodule