module my_data_memory(
	input clock,
	input reset,

	input		[31:0]	addr_in,
	input		[31:0]	writedata_in,
	input					re_in,
	input					we_in,
	input		[1:0]		size_in,
	output	reg [31:0]	readdata_out,
	
	//serial port connection that need to be routed out of the process
	input		[7:0]		serial_in,
	input					serial_ready_in,
	input					serial_valid_in,
	output	[7:0]		serial_out,
	output				serial_rden_out,
	output				serial_wren_out
);


endmodule
