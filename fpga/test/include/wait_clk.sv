real 		    clk_period = 20;

always begin
    clk = 1'b1;
    #(clk_period/2);
    clk = 1'b0;
    #(clk_period/2);
end

task automatic wait_clk;
    input integer cnt;
    integer 	    i;
    begin
        for ( i = 0; i < cnt; i++ ) begin
            @ ( posedge clk ); #1;
        end
    end
endtask
