	.file	"hello.c"
	.option nopic
	.text
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	addi	sp,sp,-48
	sw	s0,44(sp)
	addi	s0,sp,48
	mv	a5,a0
	sb	a5,-33(s0)
	li	a5,-2147483648
	sw	a5,-20(s0)
	nop
.L2:
	lw	a5,-20(s0)
	lw	a5,0(a5)
	bnez	a5,.L2
	lbu	a4,-33(s0)
	lw	a5,-20(s0)
	sw	a4,0(a5)
	nop
	lw	s0,44(sp)
	addi	sp,sp,48
	jr	ra
	.size	putchar, .-putchar
	.align	2
	.globl	puts
	.type	puts, @function
puts:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	addi	s0,sp,32
	sw	a0,-20(s0)
	j	.L4
.L5:
	lw	a5,-20(s0)
	addi	a4,a5,1
	sw	a4,-20(s0)
	lbu	a5,0(a5)
	mv	a0,a5
	call	putchar
.L4:
	lw	a5,-20(s0)
	lbu	a5,0(a5)
	bnez	a5,.L5
	li	a0,10
	call	putchar
	li	a0,13
	call	putchar
	nop
	lw	ra,28(sp)
	lw	s0,24(sp)
	addi	sp,sp,32
	jr	ra
	.size	puts, .-puts
	.section	.rodata
	.align	2
.LC0:
	.string	"hello world!"
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	lui	a5,%hi(.LC0)
	addi	a0,a5,%lo(.LC0)
	call	puts
	nop
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	main, .-main
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
