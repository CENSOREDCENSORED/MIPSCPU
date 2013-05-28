`timescale 1ns/1ps

module testbench();

reg clock;
reg reset;

wire [7:0] serial_out;
wire serial_wren;
wire[31:0] outputPC;
wire[31:0] outputwriteDataOrPC;
wire[31:0] counter;
wire[31:0] instructioncounter;
wire[31:0] outputReg;
wire[31:0] instructionROMOutMEMWBOut;

//Generate clock at 100 MHz
initial begin
	clock <= 1'b0;
	reset <= 1'b1;
	forever #9 clock <= ~clock;
end

//Drop reset after 200 ns
always begin
	#200 reset <= 1'b0;
end
	
	
//instantiate the processor  "DUT"
processor dut(
	.clock(clock),
	.reset(reset),
	
	.serial_in(8'd0),
	.serial_valid_in(1'b1), //active-high - we never have anything to read from the serial port
	.serial_ready_in(1'b1), //active-high - we are always ready to print serial data
	.serial_rden_out(), //active-high
	.serial_out(serial_out),
	.serial_wren_out(serial_wren), //active-high
	.outputPC(outputPC),
	.outputwriteDataOrPC(outputwriteDataOrPC),
	.counter(counter),
	.instructioncounter(instructioncounter),
	.outputReg(outputReg),
	.instructionROMOutMEMWBOut(instructionROMOutMEMWBOut)
);


//This will print out a message whenever the serial port is written to
always @(posedge clock) begin
	if (reset) begin
	end else begin
		if (serial_wren) begin
				$display("[%0d] Serial: %c",$time,serial_out);
		end
	end
end


endmodule