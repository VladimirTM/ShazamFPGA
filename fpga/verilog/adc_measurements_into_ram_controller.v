module adc_measurements_into_ram (
    input [11: 0] adc_measurements,  // voltage measurements from the ADC describing the sound
    input RESET,
    input CLOCK);

ram RAM_CONTROLLER (
    .address(0),
    .clock(CLOCK),
    .data(adc_measurements),
    .wren(can_write_current_bank),
    .q(q_out)
);
endmodule
