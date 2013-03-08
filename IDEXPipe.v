module IDEXPipe(
input clock,
input reset,
input stall,

input[31:0] pcPlus4IFID,
input[5:0] Func_in,
input mux1Select,
input mux2Select,
input mux3Select,
input re_in,
input we_in,
input i_Write_Enable,
input linkReg,
input jumpReg,
input[31:0] o_RS_Data,
input[31:0] o_RT_Data,
input [4:0] reg1,
input [4:0] reg2,
input [4:0] reg3,
input[31:0] signextended,
input[31:0] jumpAddress,
input[31:0] branchAddress,
input[31:0] instructionROMOutIFID,
input Branch_out,
input Jump_out,
input muxShiftSelect,
input upper,
input predictionIFID,
input lhunsigned_out,
input lhsigned_out,
input lbunsigned_out,
input lbsigned_out,

output reg[31:0] pcPlus4IDEX,
output reg[5:0] Func_inIDEX,
output reg mux1SelectIDEX,
output reg mux2SelectIDEX,
output reg mux3SelectIDEX,
output reg re_inIDEX,
output reg we_inIDEX,
output reg i_Write_EnableIDEX,
output reg linkRegIDEX,
output reg jumpRegIDEX,
output reg[31:0] o_RS_DataIDEX,
output reg[31:0] o_RT_DataIDEX,
output reg[4:0] reg1IDEX,
output reg[4:0] reg2IDEX,
output reg[4:0] reg3IDEX,
output reg[31:0] signextendedIDEX,
output reg[31:0] jumpAddressIDEX,
output reg[31:0] branchAddressIDEX,
output reg[31:0] instructionROMOutIDEX,
output reg muxShiftSelectIDEX,
output reg upperIDEX,
output reg predictionIDEX,
output reg lhunsigned_outIDEX,
output reg lhsigned_outIDEX,
output reg lbunsigned_outIDEX,
output reg lbsigned_outIDEX
);

always @(posedge clock or posedge reset)
begin
	if (reset)
	begin
		pcPlus4IDEX <= 0;
		Func_inIDEX <= 0;
		mux1SelectIDEX <= 0;
		mux2SelectIDEX <= 0;
		mux3SelectIDEX <= 0;
		re_inIDEX <= 0;
		we_inIDEX <= 0;
		i_Write_EnableIDEX <= 0;
		linkRegIDEX <= 0;
		jumpRegIDEX <= 0;
		o_RS_DataIDEX <= 0;
		o_RT_DataIDEX <= 0;
		reg1IDEX <= 0;
		reg2IDEX <= 0;
		reg3IDEX <= 0;
		signextendedIDEX <= 0;
		jumpAddressIDEX <= 0;
		branchAddressIDEX <= 0;
		instructionROMOutIDEX <= 0;
		muxShiftSelectIDEX <= 0;
		upperIDEX <= 0;
		predictionIDEX <= 0;
		lhunsigned_outIDEX <= 0;
		lhsigned_outIDEX <= 0;
		lbunsigned_outIDEX <= 0;
		lbsigned_outIDEX <= 0;
	end
	else begin 
		if (stall)
		begin
			pcPlus4IDEX <= 0;
			Func_inIDEX <= 0;
			mux1SelectIDEX <= 0;
			mux2SelectIDEX <= 0;
			mux3SelectIDEX <= 0;
			re_inIDEX <= 0;
			we_inIDEX <= 0;
			i_Write_EnableIDEX <= 0;
			linkRegIDEX <= 0;
			jumpRegIDEX <= 0;
			o_RS_DataIDEX <= 0;
			o_RT_DataIDEX <= 0;
			reg1IDEX <= 0;
			reg2IDEX <= 0;
			reg3IDEX <= 0;
			signextendedIDEX <= 0;
			jumpAddressIDEX <= 0;
			branchAddressIDEX <= 0;
			instructionROMOutIDEX <= 0;
			muxShiftSelectIDEX <= 0;
			upperIDEX <= 0;
			predictionIDEX <= 0;
			lhunsigned_outIDEX <= 0;
			lhsigned_outIDEX <= 0;
			lbunsigned_outIDEX <= 0;
			lbsigned_outIDEX <= 0;
		end
	
		else begin
			if (Branch_out)
			begin
				pcPlus4IDEX <= 0;
				Func_inIDEX <= 0;
				mux1SelectIDEX <= 0;
				mux2SelectIDEX <= 0;
				mux3SelectIDEX <= 0;
				re_inIDEX <= 0;
				we_inIDEX <= 0;
				i_Write_EnableIDEX <= 0;
				linkRegIDEX <= 0;
				jumpRegIDEX <= 0;
				o_RS_DataIDEX <= 0;
				o_RT_DataIDEX <= 0;
				reg1IDEX <= 0;
				reg2IDEX <= 0;
				reg3IDEX <= 0;
				signextendedIDEX <= 0;
				jumpAddressIDEX <= 0;
				branchAddressIDEX <= 0;
				instructionROMOutIDEX <= 0;
				muxShiftSelectIDEX <= 0;
				upperIDEX <= 0;
				predictionIDEX <= 0;
				lhunsigned_outIDEX <= 0;
				lhsigned_outIDEX <= 0;
				lbunsigned_outIDEX <= 0;
				lbsigned_outIDEX <= 0;
			end
			else begin
				if (Jump_out)
				begin
					pcPlus4IDEX <= 0;
					Func_inIDEX <= 0;
					mux1SelectIDEX <= 0;
					mux2SelectIDEX <= 0;
					mux3SelectIDEX <= 0;
					re_inIDEX <= 0;
					we_inIDEX <= 0;
					i_Write_EnableIDEX <= 0;
					linkRegIDEX <= 0;
					jumpRegIDEX <= 0;
					o_RS_DataIDEX <= 0;
					o_RT_DataIDEX <= 0;
					reg1IDEX <= 0;
					reg2IDEX <= 0;
					reg3IDEX <= 0;
					signextendedIDEX <= 0;
					jumpAddressIDEX <= 0;
					branchAddressIDEX <= 0;
					instructionROMOutIDEX <= 0;
					muxShiftSelectIDEX <= 0;
					upperIDEX <= 0;
					predictionIDEX <= 0;
					lhunsigned_outIDEX <= 0;
					lhsigned_outIDEX <= 0;
					lbunsigned_outIDEX <= 0;
					lbsigned_outIDEX <= 0;
				end
				else begin
					pcPlus4IDEX <= pcPlus4IFID;
					Func_inIDEX <= Func_in;
					mux1SelectIDEX <= mux1Select;
					mux2SelectIDEX <= mux2Select;
					mux3SelectIDEX <= mux3Select;
					re_inIDEX <= re_in;
					we_inIDEX <= we_in;
					i_Write_EnableIDEX <= i_Write_Enable;
					linkRegIDEX <= linkReg;
					jumpRegIDEX <= jumpReg;
					o_RS_DataIDEX <= o_RS_Data;
					o_RT_DataIDEX <= o_RT_Data;
					reg1IDEX <= reg1;
					reg2IDEX <= reg2;
					reg3IDEX <= reg3;
					signextendedIDEX <= signextended;
					jumpAddressIDEX <= jumpAddress;
					branchAddressIDEX <= branchAddress;
					instructionROMOutIDEX <= instructionROMOutIFID;
					muxShiftSelectIDEX <= muxShiftSelect;
					upperIDEX <= upper;
					predictionIDEX <= predictionIFID;
					lhunsigned_outIDEX <= lhunsigned_out;
					lhsigned_outIDEX <= lhsigned_out;
					lbunsigned_outIDEX <= lbunsigned_out;
					lbsigned_outIDEX <= lbsigned_out;
				end
			end
	end
	end
end

endmodule
