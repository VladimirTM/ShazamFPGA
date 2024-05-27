module Shazam (
    input MAX10_CLK1_50,
    input reset,
    input start
);

    wire [11:0] adc_data;
    wire adc_data_valid;

    ADC_samples GET_SOUNDS (
        .clk(MAX10_CLK1_50),
        .reset(reset),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid)
    );

    shazam_core SHAZAM_ANALYZE_SOUNDS (
        .clk(MAX10_CLK1_50),
        .reset(reset),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid),
        .start(start)
    );

endmodule 