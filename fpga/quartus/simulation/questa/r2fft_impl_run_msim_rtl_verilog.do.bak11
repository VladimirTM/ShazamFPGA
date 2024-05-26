transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/helper {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/helper/fixed_point_multiplier.v}
vlog -vlog01compat -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/helper {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/helper/fixed_point_adder.v}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/writeBusMux.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/twiddleFactorRomBridge.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/readBusMux.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/ramPipelineBridge.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/radix2Butterfly.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/R2FFT.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/fftAddressGenerator.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/butterflyUnit.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/butterflyCore.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/bitReverseCounter.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/bfp_Shifter.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/bfp_maxBitWidth.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/bfp_bitWidthDetector.sv}
vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/hdl {C:/Users/sergi/apps/shazam-vladimir/fpga/hdl/bfp_bitWidthAcc.sv}

vlog -sv -work work +incdir+C:/Users/sergi/apps/shazam-vladimir/fpga/quartus/../test/1024pt_16bit {C:/Users/sergi/apps/shazam-vladimir/fpga/quartus/../test/1024pt_16bit/testbench.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  testbench

add wave *
view structure
view signals
run 2 sec
