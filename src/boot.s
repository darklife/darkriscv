	.file	"boot.c"
	.option nopic
	.text
	.globl	__mulsi3
	.align	2
	.globl	boot
	.type	boot, @function
boot:
	addi	sp,sp,-16
	sw	s0,8(sp)
	lui	s0,%hi(io)
	sw	s1,4(sp)
	addi	s1,s0,%lo(io)
	lbu	a0,1(s1)
	lbu	a5,2(s1)
	li	a1,999424
	addi	a1,a1,576
	andi	a4,a5,0xff
	sw	a4,0(sp)
	sw	ra,12(sp)
	call	__mulsi3
	lw	a4,0(sp)
	slli	a5,a4,5
	sub	a5,a5,a4
	slli	a5,a5,2
	add	a5,a5,a4
	slli	a5,a5,3
	add	a0,a0,a5
	srai	a0,a0,1
	sw	a0,12(s1)
	addi	a5,s0,%lo(io)
.L2:
	lbu	a4,3(a5)
	andi	a4,a4,0xff
	bnez	a4,.L3
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	puts
	lw	s0,8(sp)
	lw	ra,12(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	tail	main
.L3:
	lhu	a4,8(a5)
	xori	a4,a4,1
	sh	a4,8(a5)
	sb	zero,3(a5)
	j	.L2
	.size	boot, .-boot
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	":)"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
