#
#  CSE 141L Boot Code
#
#
#  This code is the start of execution for 141L processors, it should be at address 0x00400000
#  The __start functions jumps to runme (part of lib141, which calls a main() function that the
#  user should write.
#
#  When runme ends, the processor is put into a loop until it is rebooted
#
#
#  Change Log:
# 	1/18/2012 - Adrian Caulfield - Initial Implementation
#
#

.data
.extern _gp

.text

.globl	__start
.extern	runme
.type __start,@function

	#here we define the entry point for the application.  To keep things simple in the
	#processor, this needs to be the first function defined in the .text segment.
	#that means this file (boot.o) needs to be listed first when linking your app

	.set	noreorder
	__start:
	la	$gp, _gp
	lui	$sp, 0x7fff
	ori	$sp, $sp, 0xfffc
	add	$26, $0, $0		# set kernel reg to 0 for ugly bltz hack
	add	$3,$0,$0		# this is not really required.  its so this works on semi-working processors
	jal	runme
	nop
	
	__start_loop:
	nop
	nop
	jal	__start_loop
	nop
	
