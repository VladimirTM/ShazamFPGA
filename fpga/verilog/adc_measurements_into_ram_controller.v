module adc_measurements_into_ram (
    input enable,
    input [11:0] adc_measurements,
    input reset,
    input clk
);

ram RAM_CONTROLLER (
    .address(0),
    .clock(CLOCK),
    .data(adc_measurements),
    .wren(can_write_current_bank),
    .q(q_out)
);
endmodule
