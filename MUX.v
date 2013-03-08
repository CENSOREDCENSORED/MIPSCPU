module MUX(
input[31:0] input1,
input[31:0] input2,
input select,

output reg[31:0] output1
);

always @ (*)
begin
	if (select == 1)
	begin
		output1 = input2;
	end
	else begin
		output1 = input1;
	end
end

endmodule
