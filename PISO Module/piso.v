module PISO_4x16x16 (
    input clk,
    input reset,
    input load,
    input [15:0] data_in [0:63],
    output reg [15:0] serial_out
);

    typedef enum reg [2:0] {
        S_IDLE = 3'b000,
        S_LOAD0 = 3'b001,
        S_LOAD1 = 3'b010,
        S_LOAD2 = 3'b011,
        S_LOAD3 = 3'b100
    } state_t;
    
    state_t state, next_state;

    reg [15:0] shift_reg [0:63];
    reg [3:0] data_index;
    reg [1:0] set_index;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= S_IDLE;
            data_index <= 4'b0000;
            set_index <= 2'b00;
            serial_out <= 16'b0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            S_IDLE: begin
                if (load) begin
                    next_state = S_LOAD0;
                end else begin
                    next_state = S_IDLE;
                end
            end
            S_LOAD0: begin
                serial_out = shift_reg[{set_index, data_index}];
                next_state = (data_index == 4'b1111) ? S_LOAD1 : S_LOAD0;
            end
            S_LOAD1: begin
                serial_out = shift_reg[{set_index, data_index}];
                next_state = (data_index == 4'b1111) ? S_LOAD2 : S_LOAD1;
            end
            S_LOAD2: begin
                serial_out = shift_reg[{set_index, data_index}];
                next_state = (data_index == 4'b1111) ? S_LOAD3 : S_LOAD2;
            end
            S_LOAD3: begin
                serial_out = shift_reg[{set_index, data_index}];
                next_state = (data_index == 4'b1111) ? S_IDLE : S_LOAD3;
            end
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_index <= 4'b0000;
            set_index <= 2'b00;
        end else begin
            if (state == S_LOAD0 || state == S_LOAD1 || state == S_LOAD2 || state == S_LOAD3) begin
                if (data_index == 4'b1111) begin
                    data_index <= 4'b0000;
                    set_index <= set_index + 2'b01;
                end else begin
                    data_index <= data_index + 4'b0001;
                end
            end else if (state == S_IDLE) begin
                data_index <= 4'b0000;
                set_index <= 2'b00;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            integer i;
            for (i = 0; i < 64; i = i + 1) begin
                shift_reg[i] <= 16'b0;
            end
        end else if (load) begin
            integer i;
            for (i = 0; i < 64; i = i + 1) begin
                shift_reg[i] <= data_in[i];
            end
        end
    end

endmodule
