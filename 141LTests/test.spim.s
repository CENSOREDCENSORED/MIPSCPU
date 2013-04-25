	.text
	.align	2
	.ent	func
func:
	.frame	$fp,8,$31		# vars= 0, regs= 1/0, args= 0, gp= 0
	.mask	0x40000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-8
	sw	$fp,4($sp)
	move	$fp,$sp
	sw	$4,8($fp)
	sw	$5,12($fp)
	lw	$3,8($fp)
	lw	$2,12($fp)
	nop
	addu	$2,$3,$2
	move	$sp,$fp
	lw	$fp,4($sp)
	addiu	$sp,$sp,8
	j	$31
	nop

	.end	func
	.align	2
	.ent	main
main:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, gp= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	
	addiu	$sp,$sp,-32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	li	$2,100			# 0x64
	sw	$2,20($fp)
	li	$2,16			# 0x10
	sw	$2,16($fp)
	lw	$4,20($fp)
	lw	$5,16($fp)
	jal	func
	nop

	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addiu	$sp,$sp,32
	j	$31
	nop

	.end	main
