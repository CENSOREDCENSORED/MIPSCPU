module signextender(
input enable,
input[15:0] input1,
output reg [31:0] output1
);

always @ (*)
begin
	output1[15:0] = input1;
	output1[31:16] = 0;
	if (enable)
	begin
		output1[31:16] = {16{input1[15]}};
	end
end

endmodule
