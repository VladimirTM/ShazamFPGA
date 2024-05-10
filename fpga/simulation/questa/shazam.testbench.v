`timescale 1 ns/ 1 ns

module shazam_testbench();
    reg RESET = 0;
    reg CLOCK = 0;

// to acheive a 50MHz clock we need a period of 20ms 
    always #10 CLOCK = ~CLOCK;

    Shazam SHAZAM_UNDER_TEST (
        .RESET(RESET),
        .CLOCK(CLOCK)
    );

    initial begin
        RESET = 1;

        #15;

        RESET = 0;
        
        #15;
    end
endmodule