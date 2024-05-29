// expects 2's complement numbers and outputs 2's
module fixed_point_adder (
    input clk,
    input enable,
    input reset,
    input wire signed [15:0] A,
    input wire signed [15:0] B,
    output reg signed [15:0] sum,
    output wire done
);

    reg extra;
    reg done_reg = 0;
    reg intermediary_done = 0;

    reg signed [15:0] temp_sum = 0;

    assign done = done_reg;

    reg compute_sum_and_overflow = 0;

    // to understand this algorithm of overflow detection refer to: https://stackoverflow.com/questions/24586842/signed-multiplication-overflow-detection-in-verilog
    always @(posedge clk) begin
        if(reset) begin
            done_reg <= 0;
            intermediary_done <= 0;
            sum <= 0;
        end 
        else begin
            intermediary_done <= enable;
            done_reg <= intermediary_done;
            if(enable) begin
                {extra, temp_sum} <= {A[15], A} + {B[15], B};
                compute_sum_and_overflow <= 1;
            end 
            if(compute_sum_and_overflow) begin
                if ({extra, temp_sum[15]} == 2'b01) sum <= {{1'b0, {15{1'b1}}}};
                else if ({extra, temp_sum[15]} == 2'b10) sum <=  {1'b1, {15{1'b0}}};
                else sum <= temp_sum;
                compute_sum_and_overflow <= 0;
            end
        end 
    end

endmodule 