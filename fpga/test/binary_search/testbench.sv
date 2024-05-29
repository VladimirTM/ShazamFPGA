module testbench;
    reg clk = 0, reset = 0;
    always #10 clk = ~clk;
    `include "../../source/find_maximas/binary_search.sv"
    `include "../include/wait_clk.sv"

    reg [24:0] maximas [15:0];
    reg [24:0] current_number;
    reg start = 0;
    
    wire found, should_insert_in_maximas;
    wire [3:0] index_left, index_right;

    binary_search BS (
        .clk(clk),
        .reset(reset),
        .maximas(maximas),
        .start(start),
        .current_number(current_number),
        .found(found),
        .should_insert_in_maximas(should_insert_in_maximas),
        .index_left(index_left),
        .index_right(index_right)
    );

    integer i;
    reg [8:0] index = 0; 
    initial begin
        reset = 1;
        wait_clk(2);
        reset = 0;
        wait_clk(2);

        for (i = 0; i < 16; i = i + 1) begin
            maximas[i] = {25{1'b0}};
            wait_clk (20); // wait for another FFT to 'finish' 
        end

        wait_clk(1);
        current_number = {index, 16'b0000_0000_0000_1};
        start = 1;
        wait_clk(1);
        start = 0;
    end 


    // expect index_left == index_right == 15
endmodule