
create_clock -name MAX10_CLK1_50 -period 20 [ get_ports MAX10_CLK1_50 ]

set_input_delay -clock { MAX10_CLK1_50 } 0  [ remove_from_collection [ all_inputs] [get_ports MAX10_CLK1_50] ]
set_output_delay -clock { MAX10_CLK1_50 } 0 [ all_outputs ]
