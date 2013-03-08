transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/hazardDetectionStall.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/hazardDetectionNoStall.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/serial_buf.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/async_memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/inst_rom.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/data_memory.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/alu.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/processor.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/programcounter.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/adder.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/regfile.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/MUX.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/signextender.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/controlunit.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/IFIDPipe.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/IDEXPipe.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/EXMEMPipe.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/MEMWBPipe.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/counter.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/instructioncounter.v}
vlog -vlog01compat -work work +incdir+C:/Users/Raymond/Desktop/UCSD/MIPSCPU {C:/Users/Raymond/Desktop/UCSD/MIPSCPU/branchPredictor.v}
