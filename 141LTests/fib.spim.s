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

.text


	#here we define the entry point for the application.  To keep things simple in the
	#processor, this needs to be the first function defined in the .text segment.
	#that means this file (boot.o) needs to be listed first when linking your app

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
	
	.text
	.align	2
nonRestoringDivision:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	sw	$5,20($fp)
	sw	$6,24($fp)
	sw	$0,4($fp)
	lw	$2,24($fp)
	nop
	sw	$0,0($2)
	li	$2,31			# 0x1f
	sw	$2,0($fp)
	j	$L2lib141
	nop

$L7lib141:
	lw	$2,4($fp)
	nop
	sll	$3,$2,1
	lw	$4,16($fp)
	lw	$2,0($fp)
	nop
	sra	$2,$4,$2
	andi	$2,$2,0x1
	or	$2,$3,$2
	sw	$2,4($fp)
	lw	$2,4($fp)
	nop
	bgez	$2,$L3lib141
	nop

	lw	$3,4($fp)
	lw	$2,20($fp)
	nop
	addu	$2,$3,$2
	j	$L4lib141
	nop

$L3lib141:
	lw	$3,4($fp)
	lw	$2,20($fp)
	nop
	subu	$2,$3,$2
$L4lib141:
	sw	$2,4($fp)
	lw	$2,4($fp)
	nop
	bltz	$2,$L5lib141
	nop

	lw	$2,24($fp)
	nop
	lw	$2,0($2)
	nop
	sll	$2,$2,1
	ori	$2,$2,0x1
	j	$L6lib141
	nop

$L5lib141:
	lw	$2,24($fp)
	nop
	lw	$2,0($2)
	nop
	sll	$2,$2,1
$L6lib141:
	lw	$3,24($fp)
	nop
	sw	$2,0($3)
	lw	$2,0($fp)
	nop
	addiu	$2,$2,-1
	sw	$2,0($fp)
$L2lib141:
	lw	$2,0($fp)
	nop
	bgez	$2,$L7lib141
	nop

	lw	$2,4($fp)
	nop
	bgez	$2,$L8lib141
	nop

	lw	$3,4($fp)
	lw	$2,20($fp)
	nop
	addu	$2,$3,$2
	j	$L9lib141
	nop

$L8lib141:
	lw	$2,4($fp)
	nop
$L9lib141:
	sw	$2,4($fp)
	lw	$2,4($fp)
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	j	$31
	nop

	.end	nonRestoringDivision
	.align	2
modifiedBoothsMultiplication:
	.frame	$fp,96,$31		# vars= 88, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-96
	sw	$fp,92($sp)
	move	$fp,$sp
	sw	$4,96($fp)
	sw	$5,100($fp)
	sw	$6,104($fp)
	li	$2,1			# 0x1
	sw	$2,20($fp)
	sw	$0,24($fp)
	sw	$0,28($fp)
	li	$2,1			# 0x1
	sw	$2,32($fp)
	li	$2,1			# 0x1
	sw	$2,36($fp)
	li	$2,-1			# 0xffffffffffffffff
	sw	$2,40($fp)
	li	$2,-1			# 0xffffffffffffffff
	sw	$2,44($fp)
	li	$2,1			# 0x1
	sw	$2,48($fp)
	sw	$0,52($fp)
	sw	$0,56($fp)
	sw	$0,60($fp)
	li	$2,1			# 0x1
	sw	$2,64($fp)
	sw	$0,68($fp)
	li	$2,1			# 0x1
	sw	$2,72($fp)
	li	$2,1			# 0x1
	sw	$2,76($fp)
	li	$2,1			# 0x1
	sw	$2,80($fp)
	lw	$2,104($fp)
	nop
	sw	$0,0($2)
	sw	$0,12($fp)
	sw	$0,16($fp)
	j	$L12lib141
	nop

$L14lib141:
	lw	$2,100($fp)
	nop
	andi	$2,$2,0x3
	sll	$3,$2,1
	lw	$2,12($fp)
	nop
	or	$2,$3,$2
	sw	$2,8($fp)
	lw	$2,8($fp)
	nop
	sll	$2,$2,2
	addu	$2,$fp,$2
	lw	$2,20($2)
	nop
	sw	$2,4($fp)
	lw	$3,4($fp)
	li	$2,1			# 0x1
	beq	$3,$2,$L13lib141
	nop

	lw	$3,4($fp)
	lw	$2,96($fp)
	nop
	xor	$3,$3,$2
	lw	$2,4($fp)
	nop
	subu	$2,$3,$2
	sw	$2,0($fp)
	lw	$2,104($fp)
	nop
	lw	$3,0($2)
	lw	$4,0($fp)
	lw	$2,16($fp)
	nop
	sll	$2,$4,$2
	addu	$3,$3,$2
	lw	$2,104($fp)
	nop
	sw	$3,0($2)
$L13lib141:
	lw	$2,8($fp)
	nop
	sll	$2,$2,2
	addu	$2,$fp,$2
	lw	$2,52($2)
	nop
	sw	$2,12($fp)
	lw	$2,100($fp)
	nop
	sra	$2,$2,1
	sw	$2,100($fp)
	lw	$2,16($fp)
	nop
	addiu	$2,$2,1
	sw	$2,16($fp)
$L12lib141:
	lw	$2,16($fp)
	nop
	slt	$2,$2,31
	bne	$2,$0,$L14lib141
	nop

	lw	$2,104($fp)
	nop
	lw	$2,0($2)
	move	$sp,$fp
	lw	$fp,92($sp)
	addiu	$sp,$sp,96
	j	$31
	nop

	.end	modifiedBoothsMultiplication
	.align	2
division:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	sw	$6,16($fp)
	lw	$2,16($fp)
	nop
	sw	$0,0($2)
	j	$L17lib141
	nop

$L18lib141:
	lw	$2,16($fp)
	nop
	lw	$2,0($2)
	nop
	addiu	$3,$2,1
	lw	$2,16($fp)
	nop
	sw	$3,0($2)
	lw	$3,8($fp)
	lw	$2,12($fp)
	nop
	subu	$2,$3,$2
	sw	$2,8($fp)
$L17lib141:
	lw	$3,8($fp)
	lw	$2,12($fp)
	nop
	slt	$2,$3,$2
	beq	$2,$0,$L18lib141
	nop

	lw	$2,8($fp)
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.end	division
	.align	2
multiplication:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	sw	$6,16($fp)
	lw	$2,16($fp)
	nop
	sw	$0,0($2)
	j	$L21lib141
	nop

$L22lib141:
	lw	$2,16($fp)
	nop
	lw	$3,0($2)
	lw	$2,12($fp)
	nop
	addu	$3,$3,$2
	lw	$2,16($fp)
	nop
	sw	$3,0($2)
	lw	$2,8($fp)
	nop
	addiu	$2,$2,-1
	sw	$2,8($fp)
$L21lib141:
	lw	$2,8($fp)
	nop
	bne	$2,$0,$L22lib141
	nop

	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.end	multiplication
	.align	2
strlen:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	lw	$2,16($fp)
	nop
	sw	$2,0($fp)
	j	$L25lib141
	nop

$L26lib141:
	lw	$2,0($fp)
	nop
	addiu	$2,$2,1
	sw	$2,0($fp)
$L25lib141:
	lw	$2,0($fp)
	nop
	lb	$2,0($2)
	nop
	bne	$2,$0,$L26lib141
	nop

	lw	$3,0($fp)
	lw	$2,16($fp)
	nop
	subu	$2,$3,$2
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	j	$31
	nop

	.end	strlen
	.align	2
strrev:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	sw	$4,32($fp)
	lw	$2,32($fp)
	nop
	sw	$2,20($fp)
	lw	$4,32($fp)
	jal	strlen
	nop

	addiu	$2,$2,-1
	lw	$3,32($fp)
	nop
	addu	$2,$3,$2
	sw	$2,16($fp)
	j	$L29lib141
	nop

$L30lib141:
	lw	$2,20($fp)
	nop
	lb	$3,0($2)
	lw	$2,16($fp)
	nop
	lb	$2,0($2)
	nop
	xor	$2,$3,$2
	sll	$3,$2,24
	sra	$3,$3,24
	lw	$2,20($fp)
	nop
	sb	$3,0($2)
	lw	$2,16($fp)
	nop
	lb	$3,0($2)
	lw	$2,20($fp)
	nop
	lb	$2,0($2)
	nop
	xor	$2,$3,$2
	sll	$3,$2,24
	sra	$3,$3,24
	lw	$2,16($fp)
	nop
	sb	$3,0($2)
	lw	$2,20($fp)
	nop
	lb	$3,0($2)
	lw	$2,16($fp)
	nop
	lb	$2,0($2)
	nop
	xor	$2,$3,$2
	sll	$3,$2,24
	sra	$3,$3,24
	lw	$2,20($fp)
	nop
	sb	$3,0($2)
	lw	$2,20($fp)
	nop
	addiu	$2,$2,1
	sw	$2,20($fp)
	lw	$2,16($fp)
	nop
	addiu	$2,$2,-1
	sw	$2,16($fp)
$L29lib141:
	lw	$3,16($fp)
	lw	$2,20($fp)
	nop
	sltu	$2,$2,$3
	bne	$2,$0,$L30lib141
	nop

	lw	$2,32($fp)
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	j	$31
	nop

	.end	strrev
	.align	2
int_to_string:
	.frame	$fp,48,$31		# vars= 24, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-48
	sw	$31,44($sp)
	sw	$fp,40($sp)
	move	$fp,$sp
	sw	$4,48($fp)
	sw	$5,52($fp)
	sw	$6,56($fp)
	li	$2,48			# 0x30
	sb	$2,24($fp)
	li	$2,49			# 0x31
	sb	$2,25($fp)
	li	$2,50			# 0x32
	sb	$2,26($fp)
	li	$2,51			# 0x33
	sb	$2,27($fp)
	li	$2,52			# 0x34
	sb	$2,28($fp)
	li	$2,53			# 0x35
	sb	$2,29($fp)
	li	$2,54			# 0x36
	sb	$2,30($fp)
	li	$2,55			# 0x37
	sb	$2,31($fp)
	li	$2,56			# 0x38
	sb	$2,32($fp)
	li	$2,57			# 0x39
	sb	$2,33($fp)
	sw	$0,20($fp)
	lw	$2,20($fp)
	lw	$3,52($fp)
	nop
	addu	$2,$3,$2
	li	$3,10			# 0xa
	sb	$3,0($2)
	lw	$2,20($fp)
	nop
	addiu	$2,$2,1
	sw	$2,20($fp)
$L33lib141:
	addiu	$2,$fp,36
	lw	$4,48($fp)
	lw	$5,56($fp)
	move	$6,$2
	jal	nonRestoringDivision
	nop

	sw	$2,16($fp)
	lw	$2,20($fp)
	lw	$3,52($fp)
	nop
	addu	$2,$3,$2
	lw	$3,16($fp)
	addiu	$4,$fp,16
	addu	$3,$4,$3
	lb	$3,8($3)
	nop
	sb	$3,0($2)
	lw	$2,20($fp)
	nop
	addiu	$2,$2,1
	sw	$2,20($fp)
	lw	$2,36($fp)
	nop
	sw	$2,48($fp)
	lw	$2,48($fp)
	nop
	bgtz	$2,$L33lib141
	nop

	lw	$2,20($fp)
	lw	$3,52($fp)
	nop
	addu	$2,$3,$2
	sb	$0,0($2)
	lw	$4,52($fp)
	jal	strrev
	nop

	move	$sp,$fp
	lw	$31,44($sp)
	lw	$fp,40($sp)
	addiu	$sp,$sp,48
	j	$31
	nop

	.end	int_to_string
	.align	2
runme:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	jal	main
	nop

	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.end	runme
	.align	2
SendByte:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-16
	sw	$fp,12($sp)
	move	$fp,$sp
	move	$2,$4
	sb	$2,16($fp)
	li	$2,-65536			# 0xffffffffffff0000
	ori	$2,$2,0x8
	sw	$2,4($fp)
	li	$2,-65536			# 0xffffffffffff0000
	ori	$2,$2,0xc
	sw	$2,0($fp)
$L38lib141:
	lw	$2,4($fp)
	nop
	lw	$2,0($2)
	nop
	andi	$2,$2,0x1
	beq	$2,$0,$L38lib141
	nop

	lb	$3,16($fp)
	lw	$2,0($fp)
	nop
	sw	$3,0($2)
	move	$sp,$fp
	lw	$fp,12($sp)
	addiu	$sp,$sp,16
	j	$31
	nop

	.end	SendByte
	.align	2
GetByte:
	.frame	$fp,24,$31		# vars= 16, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-24
	sw	$fp,20($sp)
	move	$fp,$sp
	li	$2,-65536			# 0xffffffffffff0000
	sw	$2,4($fp)
	li	$2,-65536			# 0xffffffffffff0000
	ori	$2,$2,0x4
	sw	$2,0($fp)
$L41lib141:
	lw	$2,4($fp)
	nop
	lw	$2,0($2)
	nop
	andi	$2,$2,0x1
	beq	$2,$0,$L41lib141
	nop

	lw	$2,0($fp)
	nop
	lw	$2,0($2)
	nop
	sb	$2,8($fp)
	lb	$2,8($fp)
	move	$sp,$fp
	lw	$fp,20($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.end	GetByte
	.text
	.align	2
print:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	sw	$4,24($fp)
	j	$L2
	nop

$L3:
	lw	$2,24($fp)
	nop
	lb	$2,0($2)
	nop
	move	$4,$2
	jal	SendByte
	nop

	lw	$2,24($fp)
	nop
	addiu	$2,$2,1
	sw	$2,24($fp)
$L2:
	lw	$2,24($fp)
	nop
	lb	$2,0($2)
	nop
	bne	$2,$0,$L3
	nop

	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.end	print
	.align	2
fib:
	.frame	$fp,80,$31		# vars= 56, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-80
	sw	$31,76($sp)
	sw	$fp,72($sp)
	move	$fp,$sp
	sw	$4,80($fp)
	sw	$0,32($fp)
	li	$2,1			# 0x1
	sw	$2,28($fp)
	lw	$2,80($fp)
	nop
	sw	$2,20($fp)
	j	$L6
	nop

$L7:
	addiu	$2,$fp,36
	lw	$4,32($fp)
	move	$5,$2
	li	$6,10			# 0xa
	jal	int_to_string
	nop

	move	$4,$2
	jal	print
	nop

	lw	$3,32($fp)
	lw	$2,28($fp)
	nop
	addu	$2,$3,$2
	sw	$2,24($fp)
	lw	$2,28($fp)
	nop
	sw	$2,32($fp)
	lw	$2,24($fp)
	nop
	sw	$2,28($fp)
	lw	$2,20($fp)
	nop
	addiu	$2,$2,-1
	sw	$2,20($fp)
$L6:
	lw	$2,20($fp)
	nop
	bgtz	$2,$L7
	nop

	move	$2,$0
	move	$sp,$fp
	lw	$31,76($sp)
	lw	$fp,72($sp)
	addiu	$sp,$sp,80
	j	$31
	nop

	.end	fib
	.rdata
	.align	2
$LC0:
	.ascii	"S\012\000"
	.align	2
$LC1:
	.ascii	"E\012\000"
	.text
	.align	2
main:
	.frame	$fp,24,$31		# vars= 0, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-24
	sw	$31,20($sp)
	sw	$fp,16($sp)
	move	$fp,$sp
	la	$2,$LC0
	jal	print
	nop

	li	$4,10			# 0xa
	jal	fib
	nop

	la	$2,$LC1
	jal	print
	nop

	move	$2,$0
	move	$sp,$fp
	lw	$31,20($sp)
	lw	$fp,16($sp)
	addiu	$sp,$sp,24
	j	$31
	nop

	.end	main
