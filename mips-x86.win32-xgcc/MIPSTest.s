	.file	1 "MIPSTest.c"
	.globl	mallochead
	.data
	.align	2
mallochead:
	.word	0
	.text
	.globl	main
	.ent	main
main:
	.frame	$fp,32,$31		# vars= 8, regs= 2/0, args= 16, extra= 0
	.mask	0xc0000000,-4
	.fmask	0x00000000,0
	subu	$sp,$sp,32
	sw	$31,28($sp)
	sw	$fp,24($sp)
	move	$fp,$sp
	sw	$0,mallochead
	li	$4,16			# 0x10
	jal	myMalloc
	sw	$2,16($fp)
	lw	$2,16($fp)
	addu	$3,$2,4
	li	$2,200			# 0xc8
	sw	$2,0($3)
	lw	$2,16($fp)
	move	$sp,$fp
	lw	$31,28($sp)
	lw	$fp,24($sp)
	addu	$sp,$sp,32
	jr	$31
	.end	main
	.globl	myMalloc
	.ent	myMalloc
myMalloc:
	.frame	$fp,16,$31		# vars= 8, regs= 1/0, args= 0, extra= 0
	.mask	0x40000000,-8
	.fmask	0x00000000,0
	subu	$sp,$sp,16
	sw	$fp,8($sp)
	move	$fp,$sp
	sw	$4,16($fp)
	lw	$2,mallochead
	bne	$2,$0,$L3
	li	$2,268697600			# 0x10040000
	sw	$2,4($fp)
	lw	$2,4($fp)
	sw	$2,mallochead
	lw	$3,mallochead
	li	$2,268697600			# 0x10040000
	ori	$2,$2,0x10
	sw	$2,0($3)
	lw	$4,mallochead
	lw	$2,mallochead
	lw	$3,0($2)
	lw	$2,16($fp)
	addu	$2,$3,$2
	sw	$2,4($4)
	lw	$2,mallochead
	sw	$2,0($fp)
	j	$L4
$L3:
	lw	$2,mallochead
	sw	$2,4($fp)
	lw	$2,mallochead
	sw	$2,0($fp)
$L5:
	lw	$2,0($fp)
	bne	$2,$0,$L7
	lw	$2,0($fp)
	lw	$2,8($2)
	beq	$2,$0,$L6
	lw	$2,0($fp)
	lw	$3,0($fp)
	lw	$4,4($2)
	lw	$2,0($3)
	subu	$3,$4,$2
	lw	$2,16($fp)
	slt	$2,$3,$2
	bne	$2,$0,$L7
	j	$L6
$L7:
	lw	$2,0($fp)
	sw	$2,4($fp)
	lw	$2,0($fp)
	lw	$2,12($2)
	sw	$2,0($fp)
	j	$L5
$L6:
	lw	$2,4($fp)
	lw	$2,4($2)
	addu	$2,$2,4
	sw	$2,0($fp)
	lw	$3,0($fp)
	lw	$2,4($fp)
	lw	$2,4($2)
	addu	$2,$2,16
	sw	$2,0($3)
$L4:
	lw	$2,0($fp)
	lw	$2,0($2)
	move	$sp,$fp
	lw	$fp,8($sp)
	addu	$sp,$sp,16
	jr	$31
	.end	myMalloc
