module fulladder(
input a_in,
input b_in,
input carry_in,
output sum,
output carry_out
);

assign sum = a_in ^ b_in ^ carry_in;
assign carry_out = (a_in & b_in) | (a_in & carry_in) | (carry_in & b_in);

endmodule
