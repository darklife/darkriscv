	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	_start
	.type	_start, @function
_start:
	addi	sp,sp,-16
	lui	a5,%hi(io)
	sw	ra,12(sp)
	li	a3,0
	addi	a5,a5,%lo(io)
.L2:
	lbu	a4,3(a5)
	andi	a4,a4,0xff
	bnez	a4,.L3
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	puts
	lw	ra,12(sp)
	addi	sp,sp,16
	tail	main
.L3:
	slli	a4,a3,16
	srli	a4,a4,16
	sh	a4,10(a5)
	sb	zero,3(a5)
	addi	a3,a3,1
	j	.L2
	.size	_start, .-_start
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	":)"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
