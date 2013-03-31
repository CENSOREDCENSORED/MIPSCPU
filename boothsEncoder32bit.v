module boothsEncoder32bit(
input[32:0] multiplier,

output[31:0] op1,
output[31:0] op0
);



boothsEncoder boothsencoder0(
	.multiplierstring(multiplier[2:0]),
	
	.op1(op1[1:0]),
	.op0(op0[1:0])
);

boothsEncoder boothsencoder1(
	.multiplierstring(multiplier[4:2]),
	
	.op1(op1[3:2]),
	.op0(op0[3:2])
);

boothsEncoder boothsencoder2(
	.multiplierstring(multiplier[6:4]),
	
	.op1(op1[5:4]),
	.op0(op0[5:4])
);

boothsEncoder boothsencoder3(
	.multiplierstring(multiplier[8:6]),
	
	.op1(op1[7:6]),
	.op0(op0[7:6])
);

boothsEncoder boothsencoder4(
	.multiplierstring(multiplier[10:8]),
	
	.op1(op1[9:8]),
	.op0(op0[9:8])
);

boothsEncoder boothsencoder5(
	.multiplierstring(multiplier[12:10]),
	
	.op1(op1[11:10]),
	.op0(op0[11:10])
);

boothsEncoder boothsencoder6(
	.multiplierstring(multiplier[14:12]),
	
	.op1(op1[13:12]),
	.op0(op0[13:12])
);

boothsEncoder boothsencoder7(
	.multiplierstring(multiplier[16:14]),
	
	.op1(op1[15:14]),
	.op0(op0[15:14])
);

boothsEncoder boothsencoder8(
	.multiplierstring(multiplier[18:16]),
	
	.op1(op1[17:16]),
	.op0(op0[17:16])
);

boothsEncoder boothsencoder9(
	.multiplierstring(multiplier[20:18]),
	
	.op1(op1[19:18]),
	.op0(op0[19:18])
);

boothsEncoder boothsencoder10(
	.multiplierstring(multiplier[22:20]),
	
	.op1(op1[21:20]),
	.op0(op0[21:20])
);

boothsEncoder boothsencoder11(
	.multiplierstring(multiplier[24:22]),
	
	.op1(op1[23:22]),
	.op0(op0[23:22])
);

boothsEncoder boothsencoder12(
	.multiplierstring(multiplier[26:24]),
	
	.op1(op1[25:24]),
	.op0(op0[25:24])
);

boothsEncoder boothsencoder13(
	.multiplierstring(multiplier[28:26]),
	
	.op1(op1[27:26]),
	.op0(op0[27:26])
);

boothsEncoder boothsencoder14(
	.multiplierstring(multiplier[30:28]),
	
	.op1(op1[29:28]),
	.op0(op0[29:28])
);

boothsEncoder boothsencoder15(
	.multiplierstring(multiplier[32:30]),
	
	.op1(op1[31:30]),
	.op0(op0[31:30])
);

endmodule
