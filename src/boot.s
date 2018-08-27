	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	_start
	.type	_start, @function
_start:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	addi	s0,sp,16
	call	main
.L2:
	j	.L2
	.size	_start, .-_start
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
