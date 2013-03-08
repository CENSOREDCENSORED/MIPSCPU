module hazardDetectionStall(

input[4:0] reg2write,
input[4:0] reg1,
input[4:0] reg2,
input[5:0] opcodeWrite,
input[5:0] opcodeRead,
input[5:0] funcRead,

output reg stall

);

always @(*)
begin
	stall <= 0;
	if (opcodeWrite[5:2] == 4'b1000) 
	begin
		if (reg1 == reg2write)
		begin
			stall <= 1;
		end
		
		if (opcodeRead == 0)
		begin
			if (funcRead != 0)
			begin
				if (reg2 == reg2write)
				begin
					stall <= 1;
				end
			end
		end
	end
end

endmodule
