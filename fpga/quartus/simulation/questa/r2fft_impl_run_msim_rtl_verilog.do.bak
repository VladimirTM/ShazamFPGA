transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {c:/intelfpga_lite/22.1std/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {c:/intelfpga_lite/22.1std/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {c:/intelfpga_lite/22.1std/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {c:/intelfpga_lite/22.1std/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {c:/intelfpga_lite/22.1std/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/fiftyfivenm_ver
vmap fiftyfivenm_ver ./verilog_libs/fiftyfivenm_ver
vlog -vlog01compat -work fiftyfivenm_ver {c:/intelfpga_lite/22.1std/quartus/eda/sim_lib/fiftyfivenm_atoms.v}
vlog -vlog01compat -work fiftyfivenm_ver {c:/intelfpga_lite/22.1std/quartus/eda/sim_lib/mentor/fiftyfivenm_atoms_ncrypt.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/sergi/apps/FFT/quartus {C:/Users/sergi/apps/FFT/quartus/twrom.v}
vlog -vlog01compat -work work +incdir+C:/Users/sergi/apps/FFT/quartus {C:/Users/sergi/apps/FFT/quartus/dpram.v}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/quartus {C:/Users/sergi/apps/FFT/quartus/r2fft_impl.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/writeBusMux.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/twiddleFactorRomBridge.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/readBusMux.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/ramPipelineBridge.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/radix2Butterfly.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/R2FFT.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/fftAddressGenerator.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/butterflyUnit.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/butterflyCore.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/bitReverseCounter.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/bfp_Shifter.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/bfp_maxBitWidth.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/bfp_bitWidthDetector.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/hdl {C:/Users/sergi/apps/FFT/hdl/bfp_bitWidthAcc.sv}

vlog -sv -work work +incdir+C:/Users/sergi/apps/FFT/quartus/../test/1024pt_16bit {C:/Users/sergi/apps/FFT/quartus/../test/1024pt_16bit/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run -all
