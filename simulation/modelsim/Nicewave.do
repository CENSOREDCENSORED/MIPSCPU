onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix decimal /testbench/dut/counter
add wave -noupdate -radix decimal /testbench/dut/instructioncounter
add wave -noupdate -radix hexadecimal /testbench/dut/instructionROMOut
add wave -noupdate -radix hexadecimal /testbench/dut/instructionROMOutIFID
add wave -noupdate -radix hexadecimal /testbench/dut/instructionROMOutIDEX
add wave -noupdate -radix hexadecimal /testbench/dut/instructionROMOutEXMEM
add wave -noupdate -radix hexadecimal /testbench/dut/instructionROMOutMEMWB
add wave -noupdate /testbench/dut/reset
add wave -noupdate /testbench/dut/clock
add wave -noupdate -radix hexadecimal /testbench/dut/pcIn
add wave -noupdate -radix hexadecimal -childformat {{{/testbench/dut/regfile/Register[0]} -radix hexadecimal} {{/testbench/dut/regfile/Register[1]} -radix hexadecimal} {{/testbench/dut/regfile/Register[2]} -radix hexadecimal} {{/testbench/dut/regfile/Register[3]} -radix hexadecimal} {{/testbench/dut/regfile/Register[4]} -radix hexadecimal} {{/testbench/dut/regfile/Register[5]} -radix hexadecimal} {{/testbench/dut/regfile/Register[6]} -radix hexadecimal} {{/testbench/dut/regfile/Register[7]} -radix hexadecimal} {{/testbench/dut/regfile/Register[8]} -radix hexadecimal} {{/testbench/dut/regfile/Register[9]} -radix hexadecimal} {{/testbench/dut/regfile/Register[10]} -radix hexadecimal} {{/testbench/dut/regfile/Register[11]} -radix hexadecimal} {{/testbench/dut/regfile/Register[12]} -radix hexadecimal} {{/testbench/dut/regfile/Register[13]} -radix hexadecimal} {{/testbench/dut/regfile/Register[14]} -radix hexadecimal} {{/testbench/dut/regfile/Register[15]} -radix hexadecimal} {{/testbench/dut/regfile/Register[16]} -radix hexadecimal} {{/testbench/dut/regfile/Register[17]} -radix hexadecimal} {{/testbench/dut/regfile/Register[18]} -radix hexadecimal} {{/testbench/dut/regfile/Register[19]} -radix hexadecimal} {{/testbench/dut/regfile/Register[20]} -radix hexadecimal} {{/testbench/dut/regfile/Register[21]} -radix hexadecimal} {{/testbench/dut/regfile/Register[22]} -radix hexadecimal} {{/testbench/dut/regfile/Register[23]} -radix hexadecimal} {{/testbench/dut/regfile/Register[24]} -radix hexadecimal} {{/testbench/dut/regfile/Register[25]} -radix hexadecimal} {{/testbench/dut/regfile/Register[26]} -radix hexadecimal} {{/testbench/dut/regfile/Register[27]} -radix hexadecimal} {{/testbench/dut/regfile/Register[28]} -radix hexadecimal} {{/testbench/dut/regfile/Register[29]} -radix hexadecimal} {{/testbench/dut/regfile/Register[30]} -radix hexadecimal} {{/testbench/dut/regfile/Register[31]} -radix hexadecimal}} -expand -subitemconfig {{/testbench/dut/regfile/Register[0]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[1]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[2]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[3]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[4]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[5]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[6]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[7]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[8]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[9]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[10]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[11]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[12]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[13]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[14]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[15]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[16]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[17]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[18]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[19]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[20]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[21]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[22]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[23]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[24]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[25]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[26]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[27]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[28]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[29]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[30]} {-height 15 -radix hexadecimal} {/testbench/dut/regfile/Register[31]} {-height 15 -radix hexadecimal}} /testbench/dut/regfile/Register
add wave -noupdate -divider HDS
add wave -noupdate -radix hexadecimal /testbench/dut/hds/funcRead
add wave -noupdate -radix hexadecimal /testbench/dut/hds/opcodeRead
add wave -noupdate -radix hexadecimal /testbench/dut/hds/opcodeWrite
add wave -noupdate -radix hexadecimal /testbench/dut/hds/reg1
add wave -noupdate -radix hexadecimal /testbench/dut/hds/reg2
add wave -noupdate -radix hexadecimal /testbench/dut/hds/reg2write
add wave -noupdate -radix hexadecimal /testbench/dut/hds/stall
add wave -noupdate -divider HDNSWB
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsWB/func
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsWB/hazardReg1
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsWB/hazardReg2
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsWB/opcode
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsWB/reg1
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsWB/reg2
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsWB/writeReg2
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsWB/writeReg3
add wave -noupdate -divider HDNSMEM
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsMEM/func
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsMEM/hazardReg1
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsMEM/hazardReg2
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsMEM/opcode
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsMEM/reg1
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsMEM/reg2
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsMEM/writeReg2
add wave -noupdate -divider HDNS
add wave -noupdate -radix hexadecimal /testbench/dut/hdns/func
add wave -noupdate -radix hexadecimal /testbench/dut/hdns/hazardReg1
add wave -noupdate -radix hexadecimal /testbench/dut/hdns/hazardReg2
add wave -noupdate -radix hexadecimal /testbench/dut/hdns/opcode
add wave -noupdate -radix hexadecimal /testbench/dut/hdns/reg1
add wave -noupdate -radix hexadecimal /testbench/dut/hdns/reg2
add wave -noupdate -radix hexadecimal /testbench/dut/hdns/writeReg2
add wave -noupdate -radix hexadecimal /testbench/dut/hdns/writeReg3
add wave -noupdate -radix hexadecimal /testbench/dut/hdnsMEM/writeReg3
add wave -noupdate -divider {Serial IO}
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/addr_in
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/clock
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/data_in
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/data_out
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/re_in
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/read_en
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/reset
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/s_data_in
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/s_data_out
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/s_data_ready_in
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/s_data_valid_in
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/s_rden_out
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/s_wren_out
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/sbyte
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/we_in
add wave -noupdate -radix hexadecimal /testbench/dut/dmem/ser/write_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {21098750 ps} 0}
configure wave -namecolwidth 281
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {21051451 ps} {21146049 ps}
