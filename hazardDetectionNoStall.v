module hazardDetectionNoStall(

input[4:0] writeReg2,
input[4:0] writeReg3,
input[4:0] reg1,
input[4:0] reg2,
input[5:0] opcode,
input[5:0] func,

output reg hazardReg1,
output reg hazardReg2

);

always @(*)
begin
	hazardReg1 <= 0;
	hazardReg2 <= 0;
	
	if (opcode == 0) begin
		//not a shift operation
		if (func != 0) begin
			if (func != 8) begin
				if (writeReg3 != 0 && reg1 == writeReg3)
				begin
					hazardReg1 <= 1;
				end
				if (writeReg3 != 0 && reg2 == writeReg3)
				begin
					hazardReg2 <= 1;
				end
			end
		end
		//is a shift operation
		else begin
			if (writeReg3 != 0 && reg1 == writeReg3)
			begin
				hazardReg1 <= 1;
			end
			if (writeReg3 != 0 && reg2 == writeReg3)
			begin
				hazardReg2 <= 1;
			end
		end
	end
	else begin
		if (opcode[5:2] != 4'b1010) 
		begin
			if (writeReg2 != 0 && reg1 == writeReg2)
			begin
				hazardReg1 <= 1;
			end
			if (writeReg2 != 0 && reg2 == writeReg2)
			begin
				hazardReg2 <= 1;
			end
		end
	end
end

endmodule
