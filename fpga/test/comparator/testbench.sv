module testbench;
  reg clk = 0, reset = 0, start = 0;

  `include "../include/wait_clk.sv"

  localparam EXP = 0.0625;
  parameter MAXIMAS_COUNT = 11;
  
  reg [24:0] data_in;
  wire [8:0] data_out [MAXIMAS_COUNT-1:0];
  wire output_active;
  reg load = 0;

  find_maximas #(.MAXIMAS_COUNT(MAXIMAS_COUNT)) PEAK_FINDER (
    .clk(clk),
    .start(start),
    .reset(reset),
    .data_in(data_in),
    .load(load),
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
    input_file = $fopen("../../../test/comparator/data/input.txt", "r");
    output_file = $fopen("../../../test/comparator/data/output.txt", "w");

    for (i = 0; i < 511; i = i + 1) begin
        $fscanf(input_file, "%d, ", number);
        data_in = {i, number};
        load = 1;
        wait_clk (1);

        load = 0;
        wait_clk(4);
    end 
    
    load = 1;
    data_in = {i, number};

    wait_clk(1);

    load = 0;
    start = 1;

    wait_clk(1);

    start = 0;
  end

  always @(posedge PEAK_FINDER.peak_output_active) begin
    $fwrite(output_file, "%d: %f\n", PEAK_FINDER.peak[24:16], PEAK_FINDER.peak[15:0] * EXP);
  end 

endmodule