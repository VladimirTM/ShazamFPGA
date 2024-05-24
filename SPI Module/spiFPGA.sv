module spiFPGA (
    input clk,
    input rst,
    output mosi,
    output sclk,
    output cs
);
    reg mosi_reg, cs_reg, done_reg;
    assign mosi = mosi_reg;
    assign cs = cs_reg;
    reg enable = 1;
    reg [7:0] data_in = 8'b10010011;

    reg [2:0] parity = 3'b000;
        
    typedef enum logic [1:0] {
        IDLE,
        TRANSFER,
        DONE
    } state_t;

    state_t state, next_state;

    reg [7:0] shift_reg;
    reg [2:0] bit_count;

    clk_4MHz CLK_4MHZ_INSTANCE (
        .inclk0(clk),
        .c0(sclk)
    );

    always @(negedge sclk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
            parity <= 0;
        end else begin
            state <= next_state;
            parity <= parity + 1;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if(enable && parity != 3'd7) next_state = IDLE;
                else next_state = TRANSFER;
            end
            TRANSFER: begin
                if (bit_count == 3'd7) begin
                    next_state = DONE;
                end else begin
                    next_state = TRANSFER;
                end
            end
            DONE: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    always @(negedge sclk or negedge rst) begin
        if (!rst) begin
            cs_reg <= 1;
            mosi_reg <= 0;
            shift_reg <= 0;
            bit_count <= 0;
            done_reg <= 0;

        end else begin
            case (state)
                IDLE: begin
                    if(parity == 3'd7) cs_reg <= 0;
                    else cs_reg <= 1;

                    done_reg <= 0;
                    bit_count <= 0;
                    shift_reg <= data_in;
                end
                TRANSFER: begin
                    cs_reg <= 0;
                    mosi_reg <= shift_reg[7];
                    shift_reg <= shift_reg << 1;
                    bit_count <= bit_count + 1;
                end
                DONE: begin
                    cs_reg <= 1;
                    done_reg <= 1;
                end
            endcase
        end
    end
endmodule
