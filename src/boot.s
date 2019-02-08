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
	addi	a5,a5,%lo(io)
	li	a4,578
	sh	a4,6(a5)
	call	hello
.L2:
	call	main
	j	.L2
	.size	_start, .-_start
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
