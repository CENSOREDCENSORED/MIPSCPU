
module processor(
input clock,
input reset,

//these ports are used for serial IO and 
//must be wired up to the data_memory module
input [7:0] serial_in,
input serial_valid_in,
input serial_ready_in,
output [7:0] serial_out,
output serial_rden_out,
output serial_wren_out,

output [31:0] outputPC,
output [31:0] outputwriteDataOrPC,
output[31:0] counter,
output[31:0] instructioncounter,
output[31:0] outputReg,
output[31:0] instructionROMOutMEMWBOut
);

localparam DELAY_SLOT_ENABLE = 0;

wire stall;
wire EXhazardReg1;
wire EXhazardReg2;
wire[31:0] forwardReg1;
wire[31:0] forwardReg2;
wire[31:0] memForwardReg1;
wire[31:0] memForwardReg2;

wire[31:0] pcIn;
wire[31:0] pcPlus4;
wire[31:0] pcOut;
wire[31:0] instructionROMOut;
wire[4:0] reg1;
wire[4:0] reg2;
wire[4:0] reg3;
wire mux1Select;
wire mux2Select;
wire mux3Select;
wire muxShiftSelect;
wire muxShiftSelectIDEX;
wire[4:0] writeReg;
wire[4:0] writeRegOr31;
wire[31:0] writeData;
wire[31:0] writeDataOrPC;
wire[31:0] o_RT_Data;
wire[31:0] o_RS_Data;
wire[31:0] signextended;
wire[31:0] aluInput2;
wire[31:0] aluInput1;

wire[31:0] readdata_out;

wire[31:0] O_out;
wire[5:0] Func_in;
wire Branch_out;
wire Jump_out;

wire re_in;
wire we_in;
wire[1:0] size_in;
wire[1:0] size_inIDEX;
wire[1:0] size_inEXMEM;
wire i_Write_Enable;

wire[31:0] branchAddress;
wire[31:0] mux5in;

wire linkReg;
wire jumpReg;

wire[31:0] mux8out;

assign outputPC = pcIn;
assign outputwriteDataOrPC = writeDataOrPC;

wire lhunsigned_out;
wire lhsigned_out;
wire lbunsigned_out;
wire lbsigned_out;


wire[31:0] pcPlus4IFID;
wire[31:0] instructionROMOutIFID;

wire[31:0] pcPlus4IDEX;
wire[5:0] Func_inIDEX;
wire mux1SelectIDEX;
wire mux2SelectIDEX;
wire mux3SelectIDEX;
wire re_inIDEX;
wire we_inIDEX;
wire i_Write_EnableIDEX;
wire linkRegIDEX;
wire jumpRegIDEX;
wire[31:0] o_RS_DataIDEX;
wire[31:0] o_RT_DataIDEX;
wire[4:0] reg1IDEX;
wire[4:0] reg2IDEX;
wire[4:0] reg3IDEX;
wire[31:0] signextendedIDEX;
wire[31:0] jumpAddressIDEX;
wire[31:0] branchAddressIDEX;
wire[31:0] instructionROMOutIDEX;
wire lhunsigned_outIDEX;
wire lhsigned_outIDEX;
wire lbunsigned_outIDEX;
wire lbsigned_outIDEX;

wire[31:0] O_outEXMEM;
wire[31:0] o_RT_DataEXMEM;
wire re_inEXMEM;
wire we_inEXMEM;
wire[4:0] reg2EXMEM;
wire[4:0] reg3EXMEM;
wire mux1SelectEXMEM;
wire mux3SelectEXMEM;
wire linkRegEXMEM;
wire[31:0] pcPlus4EXMEM;
wire[31:0] instructionROMOutEXMEM;
wire i_Write_EnableEXMEM;
wire lhunsigned_outEXMEM;
wire lhsigned_outEXMEM;
wire lbunsigned_outEXMEM;
wire lbsigned_outEXMEM;

wire[31:0] O_outMEMWB;
wire[31:0] o_RT_DataMEMWB;
wire[4:0] reg2MEMWB;
wire[4:0] reg3MEMWB;
wire mux1SelectMEMWB;
wire mux3SelectMEMWB;
wire linkRegMEMWB;
wire[31:0] pcPlus4MEMWB;
wire[31:0] instructionROMOutMEMWB;
wire i_Write_EnableMEMWB;
wire[31:0] readdata_outMEMWB;

assign instructionROMOutMEMWBOut = instructionROMOutMEMWB;

wire MEMHazardReg1;
wire MEMHazardReg2;
wire WBHazardReg1;
wire WBHazardReg2;
wire[31:0] forwardFromMemReg1;
wire[31:0] forwardFromMemReg2;
wire[31:0] forwardFromWBReg1;
wire[31:0] forwardFromWBReg2;
wire upper;
wire upperIDEX;

assign reg1 = instructionROMOutIFID[25:21];
assign reg2 = instructionROMOutIFID[20:16];
assign reg3 = instructionROMOutIFID[15:11];
//assign mux1Select = 0;
//assign mux2Select = 0;
//assign mux3Select = 0;
//assign Func_in = 6'b100000;
//assign stall = 0;
//assign size_in = 2'b11;

//-------------------------------------------------
//Fetch
programcounter pc(
.clock(clock),
.reset(reset),
.stall(stall),
.input1(pcIn),
.output1(pcOut)
);

adder adder(
.input1(pcOut),
.input2(4),
.output1(pcPlus4)
);

inst_rom #(
	//.INIT_PROGRAM("C:/Users/Raymond/Documents/GitHub/MIPSCPU/program.txt"),
	//.INIT_PROGRAM("C:/Users/Raymond/Documents/GitHub/MIPSCPU/test.hex"),
	//.INIT_PROGRAM("C:/Users/Raymond/Documents/GitHub/MIPSCPU/helloworldnb.hex")
	//.INIT_PROGRAM("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/fib.inst_rom.memh"),
	//.INIT_PROGRAM("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/lab3-test.inst_rom.memh"),
	//.INIT_PROGRAM("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/hello_world.inst_rom.memh"),
	.INIT_PROGRAM("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test.inst_rom.memh"),
	//.INIT_PROGRAM("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/gcd.inst_rom.memh"),
	.ADDR_WIDTH(10)
) myInstructionROM(
	.clock(clock),
	.reset(reset),
	.stall(stall),
	.addr_in(pcIn),
	.data_out(instructionROMOut)
);

wire prediction;
wire predictionIFID;
wire predictionIDEX;
wire branchoutcome;
wire signExtendEnable;

//NOTE: Branch predictor isn't actually hooked up
branchPredictor branchPredictor(
	.clock(clock),
	.reset(reset),
	
	.addressToWrite(branchAddressIDEX),
	.branchoutcome(branchoutcome),
	
	.addressToPredict(pcIn),
	.prediction(prediction)
	
);

//Branch MUX
MUX mux4(
	.input1(pcPlus4),
	.input2(branchAddressIDEX),
	.select(Branch_out),
	.output1(mux5in)
);


//Jump register MUX
MUX mux8(
	.input1(jumpAddressIDEX),
	.input2(o_RS_DataIDEX),
	.select(jumpRegIDEX),
	.output1(mux8out)
);

//Jump MUX
MUX mux5(
	.input1(mux5in),
	.input2(mux8out),
	.select(Jump_out),
	.output1(pcIn)
);


IFIDPipe IFIDPipe(
	.clock(clock),
	.reset(reset),
	.stall(stall),
	.instructionROMOut(instructionROMOut),
	.pcPlus4(pcPlus4),
	.Jump_out(Jump_out),
	.Branch_out(Branch_out),
	.prediction(prediction),
	
	.instructionROMOutIFID(instructionROMOutIFID),
	.pcPlus4IFID(pcPlus4IFID),
	.predictionIFID(predictionIFID)
);

//-------------------------------------------------
//Decode
//control unit
controlunit controlunit(
	.instruction(instructionROMOutIFID),
	
	.Func_in(Func_in),
	.mux1Select(mux1Select),
	.mux2Select(mux2Select),
	.mux3Select(mux3Select),
	.muxShiftSelect(muxShiftSelect),
	.re_in(re_in),
	.we_in(we_in),
	.i_Write_Enable(i_Write_Enable),
	.linkReg(linkReg),
	.jumpReg(jumpReg),
	.upper(upper),
	.lhunsigned_out(lhunsigned_out),
	.lhsigned_out(lhsigned_out),
	.lbunsigned_out(lbunsigned_out),
	.lbsigned_out(lbsigned_out),
	.signExtendEnable(signExtendEnable),
	.size_in(size_in)
);

regfile regfile(
	.i_Clk(clock),
	.reset(reset),
	.i_RS_Addr(reg1),
	.i_RT_Addr(reg2),
	.i_Write_Addr(writeRegOr31),
	.i_Write_Data(writeDataOrPC),
	.i_Write_Enable(i_Write_EnableMEMWB),
	.o_RS_Data(o_RS_Data),
	.o_RT_Data(o_RT_Data),
	.outputReg(outputReg)
);

signextender signextender(
	.enable(signExtendEnable),
	.input1(instructionROMOutIFID[15:0]),
	.output1(signextended)
);


//PC after branch
adder adder2(
.input1(pcPlus4IFID),
.input2({signextended[29:0], 2'b00}),
.output1(branchAddress)
);


hazardDetectionNoStall hdns(
	.writeReg2(writeRegOr31),
	.writeReg3(writeRegOr31),
	.reg1(reg1),
	.reg2(reg2),
	.opcode(instructionROMOutMEMWB[31:26]),
	.func(instructionROMOutMEMWB[5:0]),
	
	.hazardReg1(EXhazardReg1),
	.hazardReg2(EXhazardReg2)
);

MUX mux9(
	.input1(o_RS_Data),
	.input2(writeDataOrPC),
	.select(EXhazardReg1),
	.output1(forwardReg1)
);
MUX mux10(
	.input1(o_RT_Data),
	.input2(writeDataOrPC),
	.select(EXhazardReg2),
	.output1(forwardReg2)
);

hazardDetectionStall hds(
	.reg2write(reg2IDEX),
	.reg1(reg1),
	.reg2(reg2),
	.opcodeWrite(instructionROMOutIDEX[31:26]),
	.opcodeRead(instructionROMOutIFID[31:26]),
	.funcRead(instructionROMOutIFID[5:0]),
	
	.stall(stall)
);

IDEXPipe#(
	.DELAY_SLOT_ENABLE(DELAY_SLOT_ENABLE)
) IDEXPipe(
	.clock(clock),
	.reset(reset),
	.stall(stall),
	.pcPlus4IFID(pcPlus4IFID),
	.Func_in(Func_in),
	.mux1Select(mux1Select),
	.mux2Select(mux2Select),
	.mux3Select(mux3Select),
	.re_in(re_in),
	.we_in(we_in),
	.i_Write_Enable(i_Write_Enable),
	.linkReg(linkReg),
	.jumpReg(jumpReg),
	.o_RS_Data(forwardReg1),
	.o_RT_Data(forwardReg2),
	.reg1(reg1),
	.reg2(reg2),
	.reg3(reg3),
	.signextended(signextended),
	.jumpAddress({{4{instructionROMOutIFID[25]}}, instructionROMOutIFID[25:0], 2'b00}),
	.branchAddress(branchAddress),
	.instructionROMOutIFID(instructionROMOutIFID),
	.muxShiftSelect(muxShiftSelect),
	.upper(upper),
	.predictionIFID(predictionIFID),
	.lhunsigned_out(lhunsigned_out),
	.lhsigned_out(lhsigned_out),
	.lbunsigned_out(lbunsigned_out),
	.lbsigned_out(lbsigned_out),
	.size_in(size_in),

	.Branch_out(Branch_out),
	.Jump_out(Jump_out),

	.pcPlus4IDEX(pcPlus4IDEX),
	.Func_inIDEX(Func_inIDEX),
	.mux1SelectIDEX(mux1SelectIDEX),
	.mux2SelectIDEX(mux2SelectIDEX),
	.mux3SelectIDEX(mux3SelectIDEX),
	.re_inIDEX(re_inIDEX),
	.we_inIDEX(we_inIDEX),
	.i_Write_EnableIDEX(i_Write_EnableIDEX),
	.linkRegIDEX(linkRegIDEX),
	.jumpRegIDEX(jumpRegIDEX),
	.o_RS_DataIDEX(o_RS_DataIDEX),
	.o_RT_DataIDEX(o_RT_DataIDEX),
	.reg1IDEX(reg1IDEX),
	.reg2IDEX(reg2IDEX),
	.reg3IDEX(reg3IDEX),
	.signextendedIDEX(signextendedIDEX),
	.jumpAddressIDEX(jumpAddressIDEX),
	.branchAddressIDEX(branchAddressIDEX),
	.instructionROMOutIDEX(instructionROMOutIDEX),
	.muxShiftSelectIDEX(muxShiftSelectIDEX),
	.upperIDEX(upperIDEX),
	.predictionIDEX(predictionIDEX),
	.lhunsigned_outIDEX(lhunsigned_outIDEX),
	.lhsigned_outIDEX(lhsigned_outIDEX),
	.lbunsigned_outIDEX(lbunsigned_outIDEX),
	.lbsigned_outIDEX(lbsigned_outIDEX),
	.size_inIDEX(size_inIDEX)
);

//-------------------------------------------------
//Execute

//forwarding from WB stage
hazardDetectionNoStall hdnsWB(
	.writeReg2(writeRegOr31),
	.writeReg3(writeRegOr31),
	.reg1(reg1IDEX),
	.reg2(reg2IDEX),
	.opcode(instructionROMOutMEMWB[31:26]),
	.func(instructionROMOutMEMWB[5:0]),
	
	.hazardReg1(WBHazardReg1),
	.hazardReg2(WBHazardReg2)
);


MUX mux102(
	.input1(o_RS_DataIDEX),
	.input2(writeDataOrPC),
	.select(WBHazardReg1),
	.output1(forwardFromWBReg1)
);

MUX mux103(
	.input1(o_RT_DataIDEX),
	.input2(writeDataOrPC),
	.select(WBHazardReg2),
	.output1(forwardFromWBReg2)
);

//forwarding from MEM stage
hazardDetectionNoStall hdnsMEM(
	.writeReg2(reg2EXMEM),
	.writeReg3(reg3EXMEM),
	.reg1(reg1IDEX),
	.reg2(reg2IDEX),
	.opcode(instructionROMOutEXMEM[31:26]),
	.func(instructionROMOutEXMEM[5:0]),
	
	.hazardReg1(MEMHazardReg1),
	.hazardReg2(MEMHazardReg2)
);

MUX mux100(
	.input1(forwardFromWBReg1),
	.input2(O_outEXMEM),
	.select(MEMHazardReg1),
	.output1(forwardFromMemReg1)
);

MUX mux101(
	.input1(forwardFromWBReg2),
	.input2(O_outEXMEM),
	.select(MEMHazardReg2),
	.output1(forwardFromMemReg2)
);

//Selects the second value into the ALU
MUX mux2(
	.input1(forwardFromMemReg2),
	.input2(signextendedIDEX),
	.select(mux2SelectIDEX),
	.output1(aluInput2)
);

wire [26:0] zero;
assign zero = 0;
MUX muxShift1(
	.input1(forwardFromMemReg1),
	.input2({zero,instructionROMOutIDEX[10:6]}),
	.select(muxShiftSelectIDEX),
	.output1(aluInput1)
);

alu alu(
	.Func_in(Func_inIDEX),
	.A_in(aluInput1),
	.B_in(aluInput2),
	.upper(upperIDEX),
	.O_out(O_out),
	.Branch_out(branchoutcome),
	.Jump_out(Jump_out)
);

assign Branch_out = branchoutcome;//~(branchoutcome ^ predictionIDEX);

EXMEMPipe EXMEMPipe(	
	.clock(clock),
	.reset(reset),
	
	.O_out(O_out),
	.o_RT_DataIDEX(forwardFromMemReg2),
	.re_inIDEX(re_inIDEX),
	.we_inIDEX(we_inIDEX),
	.reg2IDEX(reg2IDEX),
	.reg3IDEX(reg3IDEX),
	.mux1SelectIDEX(mux1SelectIDEX),
	.mux3SelectIDEX(mux3SelectIDEX),
	.linkRegIDEX(linkRegIDEX),
	.pcPlus4IDEX(pcPlus4IDEX),
	.instructionROMOutIDEX(instructionROMOutIDEX),
	.i_Write_EnableIDEX(i_Write_EnableIDEX),
	.lhunsigned_outIDEX(lhunsigned_outIDEX),
	.lhsigned_outIDEX(lhsigned_outIDEX),
	.lbunsigned_outIDEX(lbunsigned_outIDEX),
	.lbsigned_outIDEX(lbsigned_outIDEX),
	.size_inIDEX(size_inIDEX),
	
	.O_outEXMEM(O_outEXMEM),
	.o_RT_DataEXMEM(o_RT_DataEXMEM),
	.re_inEXMEM(re_inEXMEM),
	.we_inEXMEM(we_inEXMEM),
	.reg2EXMEM(reg2EXMEM),
	.reg3EXMEM(reg3EXMEM),
	.mux1SelectEXMEM(mux1SelectEXMEM),
	.mux3SelectEXMEM(mux3SelectEXMEM),
	.linkRegEXMEM(linkRegEXMEM),
	.pcPlus4EXMEM(pcPlus4EXMEM),
	.instructionROMOutEXMEM(instructionROMOutEXMEM),
	.i_Write_EnableEXMEM(i_Write_EnableEXMEM),
	.lhunsigned_outEXMEM(lhunsigned_outEXMEM),
	.lhsigned_outEXMEM(lhsigned_outEXMEM),
	.lbunsigned_outEXMEM(lbunsigned_outEXMEM),
	.lbsigned_outEXMEM(lbsigned_outEXMEM),
	.size_inEXMEM(size_inEXMEM)
	
);

//-------------------------------------------------
//Memory
data_memory #(
	.INIT_PROGRAM0("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test.data_ram0.memh"),
	.INIT_PROGRAM1("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test.data_ram1.memh"),
	.INIT_PROGRAM2("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test.data_ram2.memh"),
	.INIT_PROGRAM3("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/test.data_ram3.memh")
	/*.INIT_PROGRAM0("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/lab3-test.data_ram0.memh"),
	.INIT_PROGRAM1("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/lab3-test.data_ram1.memh"),
	.INIT_PROGRAM2("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/lab3-test.data_ram2.memh"),
	.INIT_PROGRAM3("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/lab3-test.data_ram3.memh")*/
	/*.INIT_PROGRAM0("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/hello_world.data_ram0.memh"),
	.INIT_PROGRAM1("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/hello_world.data_ram1.memh"),
	.INIT_PROGRAM2("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/hello_world.data_ram2.memh"),
	.INIT_PROGRAM3("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/hello_world.data_ram3.memh")*/
	/*.INIT_PROGRAM0("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/fib.data_ram0.memh"),
	.INIT_PROGRAM1("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/fib.data_ram1.memh"),
	.INIT_PROGRAM2("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/fib.data_ram2.memh"),
	.INIT_PROGRAM3("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/fib.data_ram3.memh")*/
	/*.INIT_PROGRAM0("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/gcd.data_ram0.memh"),
	.INIT_PROGRAM1("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/gcd.data_ram1.memh"),
	.INIT_PROGRAM2("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/gcd.data_ram2.memh"),
	.INIT_PROGRAM3("C:/Users/Raymond/Documents/GitHub/MIPSCPU/141LTests/gcd.data_ram3.memh")*/
) dmem
(
	.clock(clock),
	.reset(reset),
	.addr_in(O_outEXMEM),
	.writedata_in(o_RT_DataEXMEM),
	
	.re_in(re_inEXMEM),
	.we_in(we_inEXMEM),
	.size_in(size_inEXMEM),
	.readdata_out(readdata_out),
	.lhunsigned_outEXMEM(lhunsigned_outEXMEM),
	.lhsigned_outEXMEM(lhsigned_outEXMEM),
	.lbunsigned_outEXMEM(lbunsigned_outEXMEM),
	.lbsigned_outEXMEM(lbsigned_outEXMEM),
	
	.serial_in(serial_in),
	.serial_ready_in(serial_ready_in),
	.serial_valid_in(serial_valid_in),
	
	.serial_out(serial_out),
	.serial_rden_out(serial_rden_out),
	.serial_wren_out(serial_wren_out)
);





MEMWBPipe MEMWBPipe(
	.clock(clock),
	.reset(reset),
	
	.O_outEXMEM(O_outEXMEM),
	.o_RT_DataEXMEM(o_RT_DataEXMEM),
	.reg2EXMEM(reg2EXMEM),
	.reg3EXMEM(reg3EXMEM),
	.mux1SelectEXMEM(mux1SelectEXMEM),
	.mux3SelectEXMEM(mux3SelectEXMEM),
	.linkRegEXMEM(linkRegEXMEM),
	.pcPlus4EXMEM(pcPlus4EXMEM),
	.instructionROMOutEXMEM(instructionROMOutEXMEM),
	.i_Write_EnableEXMEM(i_Write_EnableEXMEM),
	.readdata_out(readdata_out),
	
	.O_outMEMWB(O_outMEMWB),
	.o_RT_DataMEMWB(o_RT_DataMEMWB),
	.reg2MEMWB(reg2MEMWB),
	.reg3MEMWB(reg3MEMWB),
	.mux1SelectMEMWB(mux1SelectMEMWB),
	.mux3SelectMEMWB(mux3SelectMEMWB),
	.linkRegMEMWB(linkRegMEMWB),
	.pcPlus4MEMWB(pcPlus4MEMWB),
	.instructionROMOutMEMWB(instructionROMOutMEMWB),
	.i_Write_EnableMEMWB(i_Write_EnableMEMWB),
	.readdata_outMEMWB(readdata_outMEMWB)
);

//-------------------------------------------------
//Writeback
//Selects whether we write to 2nd or 3rd register
MUX mux1(
	.input1(reg2MEMWB),
	.input2(reg3MEMWB),
	.select(mux1SelectMEMWB),
	.output1(writeReg)
);

//Selects what data we write to the register file
MUX mux3(
	.input1(O_outMEMWB),
	.input2(readdata_outMEMWB),
	.select(mux3SelectMEMWB),
	.output1(writeData)
);

//Link MUX
MUX mux6(
	.input1(writeReg),
	.input2(31),
	.select(linkRegMEMWB && (instructionROMOutMEMWB[31:26] != 0)),
	.output1(writeRegOr31)
);

reg [31:0] pcPlus8MEMWB;

always @(*)
begin
	if (DELAY_SLOT_ENABLE)
	begin
		pcPlus8MEMWB = pcPlus4MEMWB + 4;
	end
	else
	begin
		pcPlus8MEMWB = pcPlus4MEMWB;
	end
end

//Link MUX
MUX mux7(
	.input1(writeData),
	.input2(pcPlus8MEMWB),
	.select(linkRegMEMWB),
	.output1(writeDataOrPC)
);

//-------------------------------------------------


counter clockcounter(
	.clock(clock),
	.reset(reset),
	.counter(counter)
);

instructioncounter instructioncounter2(
	.clock(clock),
	.reset(reset),
	.instruction(instructionROMOutMEMWB),
	.instructioncounter(instructioncounter)
);

endmodule
