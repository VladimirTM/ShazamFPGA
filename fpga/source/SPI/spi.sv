module SPI (
    input sclk,
    input reset,
    input [8:0] data_in,
    input data_ready,
    input fifo_empty,
    output fifo_read_enable,
    output reg mosi,
    output reg cs
);

    reg fifo_read_enable_reg = 0;
    assign fifo_read_enable = fifo_read_enable_reg;
    
    typedef enum logic [1:0] {
        IDLE = 2'b00,
        ASK_FIFO = 2'b01,
        TRANSFER = 2'b10
    } state_t;

    state_t state, next_state;

    reg [8:0] shift_reg;
    reg [3:0] bit_count;

    always @(negedge sclk) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if(!fifo_empty) next_state = ASK_FIFO;
                else next_state = IDLE;
            end
            ASK_FIFO: begin
                next_state = TRANSFER;
            end 
            TRANSFER: begin
                if (bit_count == 4'd15) begin
                    next_state = IDLE;
                end else begin
                    next_state = TRANSFER;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    always @(negedge sclk) begin
        if (reset) begin
            cs <= 1;
            fifo_read_enable_reg <= 0;
            mosi <= 0;
            shift_reg <= 0;
            bit_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    cs <= 1;
                    bit_count <= 0;
                    fifo_read_enable_reg <= 0;
                    shift_reg <= 0;
                    mosi <= 0;
                end
                ASK_FIFO: begin
                    cs <= 1;
                    fifo_read_enable_reg <= 1;
                    shift_reg <= 9'b1_0101_0010;
                end 
                TRANSFER: begin
                    fifo_read_enable_reg <= 0;
                    cs <= 0;
                    bit_count <= bit_count + 1;
                    
                    if(bit_count == 4'd9) begin
                        mosi <= 0;
                    end
                    else begin  
                        mosi <= shift_reg[8];
                        shift_reg <= shift_reg << 1;
                    end
                end
            endcase
        end
    end
endmodule