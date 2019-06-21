	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	_start
	.type	_start, @function
_start:
	addi	sp,sp,-32
	sw	s0,24(sp)
	lui	s0,%hi(io)
	sw	s1,20(sp)
	sw	ra,28(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	s4,8(sp)
	sw	s5,4(sp)
	addi	a5,s0,%lo(io)
	addi	s1,s0,%lo(io)
.L2:
	lbu	a4,3(a5)
	andi	a4,a4,0xff
	bnez	a4,.L3
	lui	s2,%hi(board_name)
	addi	s2,s2,%lo(board_name)
	lui	s5,%hi(.LC0)
	lui	s4,%hi(.LC1)
	lui	s3,%hi(.LC2)
.L4:
	lbu	a5,%lo(io)(s0)
	lbu	a2,%lo(io)(s0)
	addi	a0,s5,%lo(.LC0)
	slli	a5,a5,2
	add	a5,a5,s2
	lw	a1,0(a5)
	call	printf
	lbu	a1,1(s1)
	lbu	a2,2(s1)
	addi	a0,s4,%lo(.LC1)
	call	printf
	lhu	a1,6(s1)
	addi	a0,s3,%lo(.LC2)
	call	printf
	call	hello
	call	main
	j	.L4
.L3:
	lw	a4,8(a5)
	addi	a4,a4,1
	sw	a4,8(a5)
	sb	zero,3(a5)
	j	.L2
	.size	_start, .-_start
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"board: %s (id=%d)\n"
	.zero	1
.LC1:
	.string	"core0: darkriscv at %d.%dMHz\n"
	.zero	2
.LC2:
	.string	"uart0: baudrate counter=%d\n\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
