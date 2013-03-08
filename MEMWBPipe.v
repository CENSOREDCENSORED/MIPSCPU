module MEMWBPipe(
input clock,
input reset,

input[31:0] O_outEXMEM,
input[31:0] o_RT_DataEXMEM,
input[4:0] reg2EXMEM,
input[4:0] reg3EXMEM,
input mux1SelectEXMEM,
input mux3SelectEXMEM,
input linkRegEXMEM,
input[31:0] pcPlus4EXMEM,
input[31:0] instructionROMOutEXMEM,
input i_Write_EnableEXMEM,
input[31:0] readdata_out,

output reg[31:0] O_outMEMWB,
output reg[31:0] o_RT_DataMEMWB,
output reg[4:0] reg2MEMWB,
output reg[4:0] reg3MEMWB,
output reg mux1SelectMEMWB,
output reg mux3SelectMEMWB,
output reg linkRegMEMWB,
output reg[31:0] pcPlus4MEMWB,
output reg[31:0] instructionROMOutMEMWB,
output reg i_Write_EnableMEMWB,
output reg[31:0] readdata_outMEMWB
);

always @(posedge clock or posedge reset)
begin
	if (reset)
	begin
		O_outMEMWB <= 0;
		o_RT_DataMEMWB <= 0;
		reg2MEMWB <= 0;
		reg3MEMWB <= 0;
		mux1SelectMEMWB <= 0;
		mux3SelectMEMWB <= 0;
		linkRegMEMWB <= 0;
		pcPlus4MEMWB <= 0;
		instructionROMOutMEMWB <= 0;
		i_Write_EnableMEMWB <= 0;
		readdata_outMEMWB <= 0;
	end
	else
	begin
		O_outMEMWB <= O_outEXMEM;
		o_RT_DataMEMWB <= o_RT_DataEXMEM;
		reg2MEMWB <= reg2EXMEM;
		reg3MEMWB <= reg3EXMEM;
		mux1SelectMEMWB <= mux1SelectEXMEM;
		mux3SelectMEMWB <= mux3SelectEXMEM;
		linkRegMEMWB <= linkRegEXMEM;
		pcPlus4MEMWB <= pcPlus4EXMEM;
		instructionROMOutMEMWB <= instructionROMOutEXMEM;
		i_Write_EnableMEMWB <= i_Write_EnableEXMEM;
		readdata_outMEMWB <= readdata_out;
	end
end

endmodule
