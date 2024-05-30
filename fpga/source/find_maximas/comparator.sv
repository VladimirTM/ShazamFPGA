module comparator(
  input reset,
  input [24:0] a,
  input [24:0] b,
  output reg [24:0] max
);
// we are using unsigned numbers:
always_comb begin
  if(reset) max = 0;
  else begin
    if(a[15:0] == b[15:0]) begin
      if(a[24:16] < b[24:16]) max = a;
      else max = b;
    end 
    else max = (a[15:0] > b[15:0]) ? a : b;
  end 
end
  
endmodule