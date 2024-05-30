module testbench;
  reg clk = 0, reset = 0, start = 0;
  always #10 clk = ~clk;
  reg [24:0] data_in [511:0];
  wire [24:0] data_out [15:0];
  wire output_active;

  `include "../include/wait_clk.sv"
  
  find_maximas PEAK_FINDER (
    .clk(clk),
    .start(start),
    .reset(reset),
    .data_in(data_in),
    .data_out(data_out),
    .output_active(output_active)
  );

  integer input_file;
  integer output_file;
    reg [8:0] i = 0;
    reg [15:0] number;

  initial begin
    reset = 1;
    wait_clk(10);
    reset = 0;
    wait_clk(10);
    input_file = $fopen("../../../data/comparator/input.txt", "r");
    output_file = $fopen("../../../data/comparator/output.txt", "w");

    for (i = 0; i < 511; i = i + 1) begin
        $fscanf(input_file, "%d, ", number);
        data_in[i] = {i, number};
        wait_clk (1);
    end 

    $fscanf(input_file, "%d, ", number);
    data_in[511] = {i, number};

    wait_clk(1);

    start = 1;
    wait_clk(1);
    start = 0;

    wait_clk(20000000);
  end

  always @(posedge output_active) begin
    for (i = 0; i < 16; i = i + 1) begin
        $fwrite(output_file, "%d: %d\n", data_out[i][24:16], data_out[i][15:0]);
    end 
  end 

endmodule