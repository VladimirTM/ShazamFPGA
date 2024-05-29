module comparator(
  input [24:0] a,
  input [24:0] b,
  output [24:0] max
);
// we are using unsigned numbers:
always_comb begin
  
end
assign max = (a[15:0] > b[15:0]) ? a : b;  
  
endmodule