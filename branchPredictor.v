module branchPredictor(
input clock,
input reset,

input [31:0] addressToWrite,
input branchoutcome,

input [31:0] addressToPredict,
output prediction
);
parameter width = 6;
parameter offset = 2;
integer i;

wire[(width-1):0] addressToPredictWOffset;
wire[(width-1):0] addressToWriteWOffset;
assign addressToPredictWOffset = addressToPredict[(width+offset - 1):offset];
assign addressToWriteWOffset = addressToWrite[(width+offset - 1):offset];

reg [1:0] twobitpredictors[0:(2**width)-1];
//reg [31:0] branchTargetBuffer[0:(2**width)-1];
wire[1:0] twobitprediction;


assign twobitprediction = twobitpredictors[addressToPredictWOffset];
assign prediction = twobitprediction[1];

initial begin
	for (i = 0; i < (2**width); i = i +1) begin
			twobitpredictors[i] <= 0;
		end
end

always @(posedge clock or posedge reset)
begin
	if (reset) begin
		for (i = 0; i < (2**width); i = i +1) begin
			twobitpredictors[i] <= 0;
		end
	end
	// 00 = strongly not taken, 01 = weakly not taken
	// 10 = weakly taken, 11 = strongly taken
	else begin
		//taken
		if (branchoutcome) begin
			if (twobitpredictors[addressToWriteWOffset] < 3) begin
				twobitpredictors[addressToWriteWOffset] <= twobitpredictors[addressToWriteWOffset] + 1;
			end
		end
		//not taken
		else begin
			if (twobitpredictors[addressToWriteWOffset] > 0) begin
				twobitpredictors[addressToWriteWOffset] <= twobitpredictors[addressToWriteWOffset] - 1;
			end
		end
	end
end

endmodule
