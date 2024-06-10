module main (
    input clk,
    input reset,
    input start,
    output mosi,
    output cs,
    output sclk
);

    wire [11:0] adc_data;
    wire adc_data_valid;
    ADC_samples GET_SOUNDS (
        .clk(clk),
        .reset(reset),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid)
    );

    shazam SHAZAM (
        .clk(clk),
        .reset(reset),
        .start(start),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid),
        .mosi(mosi),
        .cs(cs),
        .sclk(sclk)
    );

endmodule