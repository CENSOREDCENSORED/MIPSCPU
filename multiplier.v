module multiplier #(
parameter size = 32
)
(
input clock,
input reset,

input dosigned,
input [size-1:0] A_in,
input [size-1:0] B_in,

output reg [2*size-1:0] O_out
);

wire A_inComplemented = ~A_in;



endmodule
