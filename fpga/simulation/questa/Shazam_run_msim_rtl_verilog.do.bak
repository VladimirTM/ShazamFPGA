transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/fiftyfivenm_ver
vmap fiftyfivenm_ver ./verilog_libs/fiftyfivenm_ver
vlog -vlog01compat -work fiftyfivenm_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/fiftyfivenm_atoms.v}
vlog -vlog01compat -work fiftyfivenm_ver {c:/intelfpga_lite/23.1std/quartus/eda/sim_lib/mentor/fiftyfivenm_atoms_ncrypt.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlib adc_core
vmap adc_core adc_core
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis {C:/Users/ratas/apps/Shazam/adc_core/synthesis/adc_core.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_avalon_st_adapter_001.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_avalon_st_adapter.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_adc_monitor_internal.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_reset_controller.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_reset_synchronizer.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_trace_adc_monitor_wa_inst.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_modular_adc_control.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_modular_adc_control_avrg_fifo.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_modular_adc_control_fsm.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/chsel_code_converter_sw_to_hw.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/fiftyfivenm_adcblock_primitive_wrapper.v}
vlog -vlog01compat -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/fiftyfivenm_adcblock_top_wrapper.v}
vlog -vlog01compat -work work +incdir+C:/Users/ratas/apps/Shazam/ram {C:/Users/ratas/apps/Shazam/ram/ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/ratas/apps/Shazam/clk_pll {C:/Users/ratas/apps/Shazam/clk_pll/clk_pll.v}
vlog -vlog01compat -work work +incdir+C:/Users/ratas/apps/Shazam/db {C:/Users/ratas/apps/Shazam/db/clk_pll_altpll.v}
vlog -vlog01compat -work work +incdir+C:/Users/ratas/apps/Shazam {C:/Users/ratas/apps/Shazam/main.v}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_avalon_st_adapter_001_timing_adapter_1.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_avalon_st_adapter_001_timing_adapter_0.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_avalon_st_adapter_001_data_format_adapter_0.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_avalon_st_adapter_timing_adapter_1.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_avalon_st_adapter_timing_adapter_0.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/adc_core_modular_adc_0_avalon_st_adapter_data_format_adapter_0.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_avalon_st_splitter.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_trace_monitor_endpoint_wrapper.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_trace_adc_monitor_core.sv}
vlog -sv -work adc_core +incdir+C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules {C:/Users/ratas/apps/Shazam/adc_core/synthesis/submodules/altera_trace_adc_monitor_wa.sv}

vlog -vlog01compat -work work +incdir+C:/Users/ratas/apps/Shazam/simulation/questa {C:/Users/ratas/apps/Shazam/simulation/questa/shazam.testbench.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -L adc_core -voptargs="+acc"  shazam_testbench

add wave *
view structure
view signals
run -all
