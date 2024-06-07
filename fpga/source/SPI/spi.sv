module SPI (
    input sclk,
    input reset,
    input [8:0] data_in,
    input data_ready,
    input fifo_empty,
    output fifo_refresh_data,
    output reg mosi,
    output reg cs
);

    reg fifo_refresh_reg = 0;
    assign fifo_refresh_data = fifo_refresh_reg;

    // reg [8:0] synthetic_data = 0;
    // always @ (posedge sclk) begin
    //     if(fifo_refresh_reg) begin 
    //         if(synthetic_data == 9'd8) synthetic_data <= 0;
    //         else synthetic_data <= synthetic_data + 2;
    //     end 
    // end
    
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        FIFO_REFRESH = 3'b001,
        TRANSFER_1 = 3'b010,
        PAUSE = 3'b011
    } state_t;

    state_t state, next_state;

    reg [8:0] shift_reg;
    reg [3:0] bit_count;

    reg [4:0] pause = 0;

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
                if(!fifo_empty && (&pause)) next_state = TRANSFER_1;
                else next_state = IDLE;
            end
            TRANSFER_1: begin
                if (bit_count == 4'd7) begin
                    next_state = PAUSE;
                end else begin
                    next_state = TRANSFER_1;
                end
            end
            PAUSE: begin
                if(&pause) next_state = FIFO_REFRESH;
                else next_state = PAUSE;
            end
            FIFO_REFRESH: begin
                next_state = IDLE;
            end 
            default: next_state = IDLE;
        endcase
    end

    always @(negedge sclk) begin
        if (reset) begin
            cs <= 1;
            fifo_refresh_reg <= 0;
            mosi <= 0;
            shift_reg <= 0;
            bit_count <= 0;
            pause <= 0;
        end else begin
            case (state)
                IDLE: begin
                    bit_count <= 0;
                    fifo_refresh_reg <= 0;
                    mosi <= 0;
                    pause <= pause + 1;
                    shift_reg <= data_in;
                    cs <= 1;
                end
                TRANSFER_1: begin
                    pause <= 0;
                    cs <= 0;
                    bit_count <= bit_count + 1;
                    mosi <= shift_reg[8];
                    shift_reg <= shift_reg << 1;
                end
                PAUSE: begin
                    pause <= pause + 1;
                    cs <= 1;
                    mosi <= 0;
                    bit_count <= bit_count;
                end
                FIFO_REFRESH: begin
                    cs <= 1;
                    pause <= 0;
                    fifo_refresh_reg <= 1;
                end
            endcase
        end
    end
endmodule