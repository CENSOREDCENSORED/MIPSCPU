module controlunit(
	input[31:0] instruction,
	
	output reg[5:0] Func_in,
	output reg mux1Select,
	output reg mux2Select,
	output reg mux3Select,
	output reg muxShiftSelect,
	output reg re_in,
	output reg we_in,
	output reg i_Write_Enable,
	output reg linkReg,
	output reg jumpReg,
	output reg upper,
	output reg lhunsigned_out,
	output reg lhsigned_out,
	output reg lbunsigned_out,
	output reg lbsigned_out,
	output reg signExtendEnable,
	output reg [1:0] size_in
);

wire [5:0] Opcode = instruction[31:26];
wire [5:0] Func = instruction[5:0];

always @ (*)
begin
	jumpReg <= 0;
	re_in <= 0;
	we_in <= 0;
	i_Write_Enable <= 1;
	linkReg <= 0;
	mux1Select <= 0;
	mux2Select <= 0;
	mux3Select <= 0;
	Func_in <= 6'b000000;
	muxShiftSelect <= 0;
	upper <= 0;
	lhunsigned_out <= 0;
	lhsigned_out <= 0;
	lbunsigned_out <= 0;
	lbsigned_out <= 0;
	signExtendEnable <= 1;
	size_in <= 3;
	case(Opcode)
		6'h0:  //r-type
		begin
		case (Func)
				6'h20: // add
				begin
					Func_in <= 6'b100000;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h21: // addu
				begin
					Func_in <= 6'b100000;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h22: // sub
				begin
					Func_in <= 6'b100010;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h23: // subu
				begin
					Func_in <= 6'b100010;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;				
				end
				
				6'h24: // and
				begin
					Func_in <= 6'b100100;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h25: // or
				begin
					Func_in <= 6'b100101;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h26: // xor
				begin
					Func_in <= 6'b100110;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h27: // nor
				begin
					Func_in <= 6'b100111;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h00: // sll
				begin
					if (instruction != 0)
					begin
						Func_in <= 6'b110000;
						mux1Select <= 1;
						mux2Select <= 0;
						mux3Select <= 0;
						muxShiftSelect <= 1;
					end
				end
				
				
				
				6'h02: // srl
				begin
					Func_in <= 6'b110001;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
					muxShiftSelect <= 1;
				end
				
				
				6'h03: // sra
				begin
					Func_in <= 6'b110011;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
					muxShiftSelect <= 1;
				end
				
				
				6'h04: // sllv
				begin
					Func_in <= 6'b110000;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;				
				end
				
				6'h06: // srlv
				begin
					Func_in <= 6'b110001;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;					
				end
				
				6'h07: // srav
				begin
					Func_in <= 6'b110011;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;						
				end
				
				6'h2a: // slt
				begin
					Func_in <= 6'b101000;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h2b: // sltu
				begin
					Func_in <= 6'b101001;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
				end
				
				6'h08: 	// JR
				begin
					jumpReg <= 1;
					Func_in <= 6'b111010;
					i_Write_Enable <= 0;
				end
				
				6'h09: 
				begin  //jalr
					jumpReg <= 1;
					Func_in <= 6'b111010;
					linkReg <= 1;
				end
					
				6'h18:  // mul
				begin
						$display("Multiply is unsupported");
					//o_Uses_ALU <= TRUE;
					//o_Writes_Back <= TRUE;				
					//o_ALUCTL <= ALUCTL_NOP;	
				end
				
				6'h19:  //mulu
				begin
					/*
					Func_in <= 6'b011000;
					mux1Select <= 1;
					mux2Select <= 0;
					mux3Select <= 0;
					*/
					$display("Multiply Unsigned is unsupported");
					//o_Uses_ALU <= TRUE;
					//o_Writes_Back <= TRUE;				
					//o_ALUCTL <= ALUCTL_NOP;
				end
				
				6'h1a:  //div
				begin
						$display("Divide is unsupported");
					//o_Uses_ALU <= TRUE;
					//o_Writes_Back <= TRUE;				
					//o_ALUCTL <= ALUCTL_NOP;
				end
				
				6'h1b:  //divu
				begin
						$display("Divide Unsigned is unsupported");
					//o_Uses_ALU <= TRUE;
					//o_Writes_Back <= TRUE;				
					//o_ALUCTL <= ALUCTL_NOP;
				end
				
				default:
				begin
					i_Write_Enable <= 0;
				end
			endcase
		end
		6'h08:  		//addi
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
		end
		
		6'h09:  //addiu
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
		end	
		
		6'h0c:  //andi
		begin
			Func_in <= 6'b100100;
			signExtendEnable <= 0;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
		end							
	
		6'h0d:  //ori
		begin
			Func_in <= 6'b100101;
			signExtendEnable <= 0;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
		end			
		
		6'h0e:  //xori
		begin
			Func_in <= 6'b100110;
			signExtendEnable <= 0;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
		end			

		6'h0a:  //slti
		begin
			Func_in <= 6'b101000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
		end			

		6'h0b:  //sltiu
		begin
			Func_in <= 6'b101000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
		end	

		6'h0f:  //lui
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
			upper <= 1;
		end			
		
		6'h04:  //beq
		begin
			Func_in <= 6'b111100;
			mux1Select <= 0;
			mux2Select <= 0;
			mux3Select <= 0;
			i_Write_Enable <= 0;
		end

		6'h05:  //bne
		begin
			Func_in <= 6'b111101;
			mux1Select <= 0;
			mux2Select <= 0;
			mux3Select <= 0;
			i_Write_Enable <= 0;
		end

		6'h06:  //blez
		begin
			Func_in <= 6'b111110;
			mux1Select <= 0;
			mux2Select <= 0;
			mux3Select <= 0;
			i_Write_Enable <= 0;
		end

		6'h01:  //bgez or bltz
		begin	
			mux1Select <= 0;
			mux2Select <= 0;
			mux3Select <= 0;
			i_Write_Enable <= 0;
			if (instruction[19:16] == 1) begin
				Func_in <= 6'b111001;
			end
			else begin
				Func_in <= 6'b111000;
			end
		end
		
		6'h07:  //bgtz
		begin
			Func_in <= 6'b111111;
			mux1Select <= 0;
			mux2Select <= 0;
			mux3Select <= 0;
			i_Write_Enable <= 0;
		end				

		6'h02:  // j
		begin
			Func_in <= 6'b111010;
			i_Write_Enable <= 0;
		end

		6'h03:  // jal
		begin
			Func_in <= 6'b111010;
			linkReg <= 1;
		end
		
		6'h20: //lb
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 1;
			re_in <= 1;
			we_in <= 0;
			lbsigned_out <= 1;
		end
		
		6'h24: //lbu
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 1;
			re_in <= 1;
			we_in <= 0;
			lbunsigned_out <= 1;
		end

		6'h21: //lh
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 1;
			re_in <= 1;
			we_in <= 0;
			lhsigned_out <= 1;
		end

		6'h25: //lhu
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 1;
			re_in <= 1;
			we_in <= 0;
			lhunsigned_out <= 1;
		end
	
		6'h23: //lw
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 1;
			re_in <= 1;
			we_in <= 0;
		end

		6'h28:  //sb
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
			re_in <= 0;
			we_in <= 1;
			i_Write_Enable <= 0;
			size_in <= 0;
		end

		6'h29:  //sh
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
			re_in <= 0;
			we_in <= 1;
			i_Write_Enable <= 0;
			size_in <= 1;
		end

		6'h2b:  //sw
		begin
			Func_in <= 6'b100000;
			mux1Select <= 0;
			mux2Select <= 1;
			mux3Select <= 0;
			re_in <= 0;
			we_in <= 1;
			i_Write_Enable <= 0;
		end

		/*6'h10:  //mtc0
		begin
			
			o_Uses_ALU <= TRUE;
			o_Uses_RT <= TRUE;
			o_RT_Addr <= i_Instruction[20:16];
			casex(i_Instruction[15:11])
				5'h17:	
				begin
					o_ALUCTL <= ALUCTL_MTCO_PASS;
					if( !i_Stall && DEBUG )
						$display("%x: %x (MTC0 Pass)",i_PC,i_Instruction);
				end
				
				5'h18:	
				begin
					o_ALUCTL <= ALUCTL_MTCO_FAIL;
					if( !i_Stall && DEBUG )
						$display("%x: %x (MTC0 Fail)",i_PC,i_Instruction);
				end
				
				5'h19:	
				begin
					o_ALUCTL <= ALUCTL_MTCO_DONE;
					if( !i_Stall && DEBUG )
						$display("%x: %x (MTC0 Done)",i_PC,i_Instruction);
				end
			endcase
		end*/
	endcase
end

endmodule
