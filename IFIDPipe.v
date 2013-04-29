module IFIDPipe(
input clock,
input reset,
input stall,

input[31:0] instructionROMOut,
input[31:0] pcPlus4,
input Branch_out,
input Jump_out,
input prediction,

output reg[31:0] instructionROMOutIFID,
output reg[31:0] pcPlus4IFID,
output reg predictionIFID
);

always @(posedge clock or posedge reset)
begin
	if (reset == 1)
	begin
		instructionROMOutIFID <= 0;
		pcPlus4IFID <= 0;
		predictionIFID <= 0;
	end
	else begin 
		if (Branch_out == 1)
		begin
			instructionROMOutIFID <= 0;
			pcPlus4IFID <= 0;
			predictionIFID <= 0;
		end
		else begin
			if (Jump_out == 1)
			begin
				instructionROMOutIFID <= 0;
				pcPlus4IFID <= 0;
				predictionIFID <= 0;
			end
			else
			begin
				if (!stall) begin
					instructionROMOutIFID <= instructionROMOut;
					pcPlus4IFID <= pcPlus4;
					predictionIFID <= prediction;
				end
			end
		end
	end
end

endmodule
