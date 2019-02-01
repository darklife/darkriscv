	.file	"hello.c"
	.option nopic
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	sw	s1,52(sp)
	sw	s2,48(sp)
	sw	s3,44(sp)
	sw	s4,40(sp)
	sw	s5,36(sp)
	sw	s6,32(sp)
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	puts
	lui	s2,%hi(.LC1)
	lui	s1,%hi(.LC2)
	lui	s6,%hi(.LC3)
	lui	s0,%hi(.LC4)
	lui	s5,%hi(.LC6)
	lui	s4,%hi(.LC5)
	lui	s3,%hi(io)
	j	.L2
.L7:
	addi	a0,s6,%lo(.LC3)
	call	printf
	j	.L3
.L4:
	addi	a0,s5,%lo(.LC6)
	call	puts
.L2:
	addi	a0,s2,%lo(.LC1)
	call	printf
	li	a1,32
	mv	a0,sp
	call	gets
	addi	a1,s1,%lo(.LC2)
	mv	a0,sp
	call	strcmp
	beqz	a0,.L7
.L3:
	addi	a1,s0,%lo(.LC4)
	mv	a0,sp
	call	strcmp
	bnez	a0,.L4
	addi	a0,s4,%lo(.LC5)
	call	puts
	lw	a5,%lo(io)(s3)
	lw	a4,8(a5)
	addi	a3,a4,1
	sw	a3,8(a5)
	sw	a4,8(a5)
	j	.L2
	.size	main, .-main
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Welcome to DarkRISCV!"
	.zero	2
.LC1:
	.string	"> "
	.zero	1
.LC2:
	.string	"clear"
	.zero	2
.LC3:
	.string	"\033[H\033[2J"
.LC4:
	.string	"led"
.LC5:
	.string	"led."
	.zero	3
.LC6:
	.string	"command: not found."
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
