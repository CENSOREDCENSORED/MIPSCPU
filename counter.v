module counter(
input clock,
input reset,
output reg [31:0] counter
);

initial begin
	counter <= 0;
end

always @(posedge clock or posedge reset)
begin
	if (reset) begin
		counter <= 0;
	end
	else begin
		counter <= counter + 1;
	end
end

endmodule
