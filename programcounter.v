module programcounter(
input clock,
input reset,
input stall,

input[31:0] input1,
output reg[31:0] output1
);

always @(posedge clock or posedge reset)
begin
	if (reset == 1)
	begin
		output1 <= 32'h003FFFFC;
	end
	else
	begin
		if (!stall) begin
			output1 <= input1;
		end
		else
		begin
			output1 <= output1;
		end
	end
end

endmodule