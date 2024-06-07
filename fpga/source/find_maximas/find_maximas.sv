module find_maximas #(parameter MAXIMAS_COUNT = 11) (
  input clk,
  input start,
  input reset,
  input load,
  input [24:0] data_in,
  output reg [8:0] data_out [MAXIMAS_COUNT-1:0],
  output reg output_active
);
  
  reg start_find_peak;
  reg peak_output_active;
  wire [8:0] peak_index;
  wire [24:0] peak;
  reg [24:0] data [511:0];

  find_1_peak PEAK_FINDER (
    .clk(clk),
    .reset(reset),
    .start(start_find_peak),
    .data_in(data),
    .peak(peak),
    .peak_index(peak_index),
    .output_active(peak_output_active)
  );

  reg [3:0] index = 0;
  reg [8:0] load_index = 0;
  integer i;
  always @ (posedge clk) begin
    if(reset) begin
      start_find_peak <= 0;
      index <= 0;
      load_index <= 0;
      output_active <= 0;
      for (i = 0; i < MAXIMAS_COUNT; i++) data_out[i] = {9{1'b0}};
    end
    else if (load) begin
      output_active <= 0;
      data[load_index] = data_in;
      load_index <= load_index + 1;
    end 
    else if(start) begin 
      output_active <= 0;
      start_find_peak <= 1;
      index <= 0;
    end
    else begin
      if(peak_output_active) begin
        if(index == MAXIMAS_COUNT-1) begin
          output_active <= 1;
          data_out[index] <= peak[24:16];
          index <= index + 1;
        end
        else begin
          output_active <= 0;
          start_find_peak <= 1;
          data_out[index] <= peak[24:16];

          if(peak_index % 2 == 0) begin
            data[peak_index] <= {25{1'b0}};
            data[peak_index + 1] <= {25{1'b0}};
          end 
          else begin
            data[peak_index - 1] <= {25{1'b0}};
            data[peak_index] <= {25{1'b0}};
          end
          index <= index + 1;
        end 
      end
      else begin 
        start_find_peak <= 0;
        output_active <= 0;
      end 
    end 
  end
  
endmodule