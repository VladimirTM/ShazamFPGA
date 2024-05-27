module reduction_stage_1 #(parameter SIZE = 512)(
  input clk,
  input load,
  input reset,
  output reg out_active,
  input [15:0] in [SIZE - 1: 0],
  output [24:0] out [SIZE / 2 - 1: 0]
);
    
  reg [8:0] index = 0;
  reg [24:0] normalized_input [SIZE - 1: 0];
  reg loaded = 0;
  reg compared = 0;
  always @(posedge clk) begin
    if(reset) begin
      out_active <= 0;
      compared <= 0;
      loaded <= 0;
    end 
    else begin 
      loaded <= load;
      compared <= loaded;
      out_active <= compared;
    end 
  end

  genvar i;
  generate
  for(i = 0; i < 1024; i++) begin : input_normalizer
    reg [8:0]index = i[8:0];
    always @ (posedge clk) begin
      if(load) begin
          if(i == 0) begin
            normalized_input[i] = {25{1'b0}};
          end 
          else normalized_input[i] <= {index,in[i]};
      end
    end       
  end
  endgenerate
  
genvar j;
generate
    for(j = 0; j < SIZE/2; j = j + 1) begin: gen_comparator_stage_1
      comparator comp(
        .a(normalized_input[j]),
        .b(normalized_input[SIZE - j - 1]),
        .max(out[j])
      );
    end
endgenerate
  
endmodule