// expects 2's complement numbers and outputs 2's complement
module fixed_point_multiplier # (
    parameter EXP_WIDTH_A = 15, 
    parameter EXP_WIDTH_B = 15,
    parameter EXP_WIDTH_PRODUCT = 15
    ) (
    input clk,
    input reset,
    input enable,
    input wire signed [15:0] A,
    input wire signed [15:0] B,
    output reg signed [15:0] product,
    output wire done
);

 reg signed [31:0] full_product = 0;
 reg computed_full_product = 0;
 reg done_reg = 0;
 
 assign done = done_reg;

 // check if the output of the multiplication will be positive or negative.
 reg result_is_negative = 0;
 reg last_digit;
 
 always @(posedge clk) begin
    if(reset) begin
        product <= 0;
        computed_full_product <= 0;
        done_reg <= 0;
    end 
    else begin
        computed_full_product <= enable;
        done_reg <= computed_full_product;
        
        if(enable) begin
            full_product <= (A * B);
            result_is_negative <= A[15] ^ B[15];
        end 
        if(computed_full_product) begin
            if(full_product == 0) begin
                product <= 0;
            end
            else begin  
                if(result_is_negative) begin
                    // has overflow
                    if((&full_product[31:((EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT) + 15)]) == 0) product <= {1'b1, {15{1'b0}}};
                    // doesn't have overflow
                    else product <= (full_product >> (EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT)) + full_product[EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT - 1];
                end 
                else begin 
                    // has overflow
                    if(full_product[31:((EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT) + 15)] != 0) product <= {1'b0, {15{1'b1}}};
                    else if (full_product[((EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT) + 15)] == 1) product <= ~(full_product[((EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT) + 15) : (EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT)] + full_product[EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT - 1]) + 1'b1;
                    else product <= (full_product >> (EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT)) + full_product[EXP_WIDTH_A + EXP_WIDTH_B - EXP_WIDTH_PRODUCT - 1];
                end 
            end 
        end
    end 
 end 

endmodule