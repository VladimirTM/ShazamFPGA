module shazam (
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

    wire [24:0] maximas [15:0];
    wire maximas_found_active;

    shazam_core SHAZAM_ANALYZE_SOUNDS (
        .clk(MAX10_CLK1_50),
        .reset(reset),
        .adc_data(adc_data),
        .adc_data_valid(adc_data_valid),
        .start(start),
        .maximas(maximas),
        .maximas_found_active(maximas_found_active)
    );

endmodule 