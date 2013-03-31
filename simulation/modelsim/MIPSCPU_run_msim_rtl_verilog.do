transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/hazardDetectionStall.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/hazardDetectionNoStall.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/serial_buf.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/async_memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/inst_rom.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/data_memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/alu.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/processor.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/programcounter.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/adder.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/regfile.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/MUX.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/signextender.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/controlunit.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/IFIDPipe.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/IDEXPipe.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/EXMEMPipe.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/MEMWBPipe.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/counter.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/instructioncounter.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Documents/GitHub/MIPSCPU {C:/Users/Raymond/Documents/GitHub/MIPSCPU/branchPredictor.v}

