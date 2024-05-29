module binary_search(
    input clk, 
    input reset,
    input [24:0] maximas [15:0],
    input start,
    input [24:0] current_number,
    output reg found,
    output reg should_insert_in_maximas,
    output reg [3:0] index_left,
    output reg [3:0] index_right
);

typedef enum reg [1:0] {
    S_IDLE = 2'b00,
    S_START = 2'b01,
    S_COMPUTING = 2'b10
} state_t;
    
state_t state, next_state;

wire [4:0] middle;

reg [24:0] number;

always @(posedge clk) begin
    if(reset) state <= S_IDLE;
    else state <= next_state;
end 

always @(*) begin
    case (state)
        S_IDLE: begin
            if(start) next_state = S_START;
            else next_state = S_IDLE;
        end 
        S_START: begin
            next_state = S_COMPUTING;
        end 
        S_COMPUTING: begin
            if(found) next_state = S_IDLE;
            else next_state = S_COMPUTING;
        end
        default: next_state = S_IDLE;
    endcase
end

assign middle = (index_left + index_right) >> 1; // shifting the sum is equivalent with a division by 2

always @(posedge clk) begin
    if(reset) begin
        found <= 0;
        index_left <= 15;
        index_right <= 0;
    end
    else begin 
        if(state == S_IDLE) begin
            found <= 0;
            should_insert_in_maximas <= 0;
            index_left <= 0;
            index_right <= 0;
        end 
        if(state == S_START) begin
            found <= 0;
            should_insert_in_maximas <= 0;
            index_left <= 0;
            index_right <= 0;
            number <= current_number;
        end
        if(state == S_COMPUTING) begin
            if(middle == 0) begin
                found <= 1;
                should_insert_in_maximas <= 0;
                index_left <= 0;
                index_right <= 0;
            end
            else if (middle == 15) begin
                found <= 1;
                should_insert_in_maximas <= 1;
                index_left <= 15;
                index_right <= 15;
            end 
            else if(number[15:0] > maximas[middle][15:0]) begin
                found <= 0;
                index_right <= middle;
            end
            else if(number[15:0] < maximas[middle - 1][15:0]) begin
                found <= 0;
                index_left <= middle; 
            end 
            else if (number[15:0] <= maximas[middle][15:0] && number[15:0] >= maximas[middle - 1][15:0]) begin
                found <= 1;
                index_left <= middle;
                index_right <= middle - 1;
            end 
        end 
    end 
end


endmodule