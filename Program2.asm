main:
addi $a0, $zero, 10
jal func
j end


func:
beqz $a0, zero
sw $ra, -4($sp)
sw $a0, -8($sp)
addi $a0, $a0, -1
addi $sp, $sp, -12
sw $sp, ($sp)
jal func
lw $sp, ($sp)
addi $sp, $sp, 12
lw $ra, -4($sp)
lw $a0, -8($sp)
zero:
add $v0, $a0, $v0
jr $ra

end:
