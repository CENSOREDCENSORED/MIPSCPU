module boothsEncoder(
input [2:0] multiplierstring,

output reg[1:0] op1,
output reg[1:0] op0
);

/*
 * 00 -> nop
 * 01 -> addition
 * 10 -> subtraction
 */
always @(*)
begin
	case (multiplierstring)
		3'b000:
		begin
			op1 <= 2'b00;
			op0 <= 2'b00;
		end
		3'b001:
		begin
			op1 <= 2'b00;
			op0 <= 2'b01;
		end
		3'b010:
		begin
			op1 <= 2'b00;
			op0 <= 2'b01;
		end
		3'b011:
		begin
			op1 <= 2'b01;
			op0 <= 2'b00;
		end
		3'b100:
		begin
			op1 <= 2'b10;
			op0 <= 2'b00;
		end
		3'b101:
		begin
			op1 <= 2'b00;
			op0 <= 2'b10;
		end
		3'b110:
		begin
			op1 <= 2'b00;
			op0 <= 2'b10;
		end
		3'b111:
		begin
			op1 <= 2'b00;
			op0 <= 2'b00;
		end
	endcase
end

endmodule
