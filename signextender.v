module signextender(
input[15:0] input1,
output[31:0] output1
);

assign output1[15:0] = input1;
assign output1[31:16] = {16{input1[15]}};

endmodule
