module spiFPGA (
    input clk,
    input rst,
    input [7:0] data_in,
    input start,
    output reg mosi,
    output reg sclk,
    output reg cs,
    output reg done
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        TRANSFER,
        DONE
    } state_t;

    state_t state, next_state;

    reg [7:0] shift_reg;
    reg [2:0] bit_count;

    reg [3:0] clk_div;
    parameter CLK_DIV = 13; // Clock division for ~4 MHz SPI clock

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            clk_div <= 0;
            sclk <= 0;
        end else if (clk_div == CLK_DIV - 1) begin
            clk_div <= 0;
            sclk <= ~sclk;
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (start) begin
                    next_state = LOAD;
                end else begin
                    next_state = IDLE;
                end
            end
            LOAD: begin
                next_state = TRANSFER;
            end
            TRANSFER: begin
                if (bit_count == 3'd7 && sclk) begin
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

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cs <= 1;
            mosi <= 0;
            shift_reg <= 0;
            bit_count <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    cs <= 1;
                    mosi <= 0;
                    done <= 0;
                end
                LOAD: begin
                    cs <= 0;
                    shift_reg <= data_in;
                    bit_count <= 0;
                end
                TRANSFER: begin
                    if (sclk) begin
                        mosi <= shift_reg[7];
                        shift_reg <= shift_reg << 1;
                        bit_count <= bit_count + 1;
                    end
                end
                DONE: begin
                    cs <= 1;
                    done <= 1;
                end
            endcase
        end
    end
endmodule
