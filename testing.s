addi $v0, $zero, 100
addi $a0, $zero, 0x18
addu $a0, $v0, $zero
sll	$v1,$v0,0x18
sra	$v1,$v1,0x18
sllv $v1, $v1, $a0
srlv $v1, $v1, $a0

addu $sp, $fp, $zero

