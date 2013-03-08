module instructioncounter(
input clock,
input reset,
input [31:0] instruction,
output reg [31:0] instructioncounter
);

initial begin
	instructioncounter <= 0;
end

always @(posedge clock or posedge reset)
begin
	if (reset) begin
		instructioncounter <= 0;
	end
	else begin
		if (instruction != 0) begin
			instructioncounter <= instructioncounter + 1;
		end
	end
end

endmodule
