module halfadder(
input a_in,
input b_in,
output sum,
output carry_out
);

assign sum = a_in ^ b_in;
assign carry_out = a_in & b_in;

endmodule
