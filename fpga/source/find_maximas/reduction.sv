module reduction #(parameter SIZE = 511)(
  input reset,
  input [24:0] in [SIZE - 1: 0],
  output [24:0] out [SIZE / 2 - 1: 0]
);
  
genvar i;
generate
for(i = 0; i <= SIZE/2 - 1; i = i + 1) begin: gen_comparator_stage_2
  comparator comp(
    .reset(reset),
    .a(in[i]),
    .b(in[SIZE - i - 1]),
    .max(out[i])
  );
end
endgenerate  
endmodule