module PISO #(parameter MAXIMAS_COUNT = 11) (
    input clk,
    input reset,
    input load,
    input [8:0] data_in [MAXIMAS_COUNT-1:0],
    output reg [8:0] serial_out,
    output reg output_active
);

    typedef enum reg {
        S_IDLE = 1'b0,
        S_LOAD = 1'b1
    } state_t;
    
    state_t state, next_state;

    reg [8:0] shift_reg [MAXIMAS_COUNT-1:0];
    reg [3:0] data_index;

    always @(posedge clk) begin
        if (reset) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            S_IDLE: begin
                if (load) begin
                    next_state = S_LOAD;
                end else begin
                    next_state = S_IDLE;
                end
            end
            S_LOAD: begin
                if(data_index == MAXIMAS_COUNT-1) 
                    next_state = S_IDLE;
                else next_state = S_LOAD;
            end 
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            serial_out <= {9{1'b0}};
            data_index <= 4'b0000;
            output_active <= 1'b0;
        end else begin
            if (state == S_LOAD) begin
                output_active <= 1;
                serial_out <= shift_reg[data_index];
                data_index <= data_index + 4'b0001;
            end else if (state == S_IDLE) begin
                data_index <= 4'b0000;
                output_active <= 0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            integer i;
            for (i = 0; i < MAXIMAS_COUNT; i = i + 1) begin
                shift_reg[i] <= 9'b0000_0000_0;
            end
        end else if (load) begin
            integer i;
            for (i = 0; i < MAXIMAS_COUNT; i = i + 1) begin
                shift_reg[i] <= data_in[i];
            end
        end
    end

endmodule