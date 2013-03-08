module EXMEMPipe(
input clock,
input reset,

input[31:0] O_out,
input[31:0] o_RT_DataIDEX,
input re_inIDEX,
input we_inIDEX,
input[4:0] reg2IDEX,
input[4:0] reg3IDEX,
input mux1SelectIDEX,
input mux3SelectIDEX,
input linkRegIDEX,
input[31:0] pcPlus4IDEX,
input[31:0] instructionROMOutIDEX,
input i_Write_EnableIDEX,
input lhunsigned_outIDEX,
input lhsigned_outIDEX,
input lbunsigned_outIDEX,
input lbsigned_outIDEX,

output reg[31:0] O_outEXMEM,
output reg[31:0] o_RT_DataEXMEM,
output reg re_inEXMEM,
output reg we_inEXMEM,
output reg[4:0] reg2EXMEM,
output reg[4:0] reg3EXMEM,
output reg mux1SelectEXMEM,
output reg mux3SelectEXMEM,
output reg linkRegEXMEM,
output reg[31:0] pcPlus4EXMEM,
output reg[31:0] instructionROMOutEXMEM,
output reg i_Write_EnableEXMEM,
output reg lhunsigned_outEXMEM,
output reg lhsigned_outEXMEM,
output reg lbunsigned_outEXMEM,
output reg lbsigned_outEXMEM

);

always @(posedge clock or posedge reset)
begin
	if (reset)
	begin
		O_outEXMEM <= 0;
		o_RT_DataEXMEM <= 0;
		re_inEXMEM <= 0;
		we_inEXMEM <= 0;
		reg2EXMEM <= 0;
		reg3EXMEM <= 0;
		mux1SelectEXMEM <= 0;
		mux3SelectEXMEM <= 0;
		linkRegEXMEM <= 0;
		pcPlus4EXMEM <= 0;
		instructionROMOutEXMEM <= 0;
		i_Write_EnableEXMEM <= 0;
		lhunsigned_outEXMEM <= 0;
		lhsigned_outEXMEM <= 0;
		lbunsigned_outEXMEM <= 0;
		lbsigned_outEXMEM <= 0;
	end
	else 
	begin
		O_outEXMEM <= O_out;
		o_RT_DataEXMEM <= o_RT_DataIDEX;
		re_inEXMEM <= re_inIDEX;
		we_inEXMEM <= we_inIDEX;
		reg2EXMEM <= reg2IDEX;
		reg3EXMEM <= reg3IDEX;
		mux1SelectEXMEM <= mux1SelectIDEX;
		mux3SelectEXMEM <= mux3SelectIDEX;
		linkRegEXMEM <= linkRegIDEX;
		pcPlus4EXMEM <= pcPlus4IDEX;
		instructionROMOutEXMEM <= instructionROMOutIDEX;
		i_Write_EnableEXMEM <= i_Write_EnableIDEX;
		lhunsigned_outEXMEM <= lhunsigned_outIDEX;
		lhsigned_outEXMEM <= lhsigned_outIDEX;
		lbunsigned_outEXMEM <= lbunsigned_outIDEX;
		lbsigned_outEXMEM <= lbsigned_outIDEX;
	end
end

endmodule
