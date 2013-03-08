module bigMemory(
	input clock,
	input reset,
	input [31:0] programcounter,
	output reg [31:0] instruction_out,
	
	input		[31:0]	addr_in,
	output	[31:0]	data_out,
	input		[31:0]	data_in,
	input		[1:0]		size_in, //0=byte, 1=2-byte, 2=unaligned, 3=word
	input					we_in,
	input					re_in
);

//8 KB address space
reg [32:0] memory[0:(2**22) - 1];

assign data_out = memory[addr_in];

always @(posedge clock or posedge reset)
begin
	instruction_out <= memory[programcounter];
	
end

endmodule
