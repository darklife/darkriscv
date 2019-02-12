	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	_start
	.type	_start, @function
_start:
	addi	sp,sp,-16
	li	a0,64
	sw	ra,12(sp)
	sw	s0,8(sp)
	call	putchar
	lui	s0,%hi(io)
	lbu	a5,%lo(io)(s0)
	lui	a4,%hi(board_name)
	addi	a4,a4,%lo(board_name)
	slli	a5,a5,2
	add	a5,a5,a4
	lw	a1,0(a5)
	lbu	a2,%lo(io)(s0)
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	printf
	addi	s0,s0,%lo(io)
	lbu	a1,1(s0)
	lbu	a2,2(s0)
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	printf
	lhu	a1,6(s0)
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	printf
	call	hello
.L2:
	call	main
	j	.L2
	.size	_start, .-_start
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"%s (id=%d)\n"
.LC1:
	.string	"darkriscv@%d.%dMHz\n"
.LC2:
	.string	"darkruart baudrate counter %d\n\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
