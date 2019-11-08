	.file	"io.c"
	.option nopic
	.text
	.align	2
	.globl	board_name
	.type	board_name, @function
board_name:
	beqz	a0,.L3
	li	a5,1
	beq	a0,a5,.L4
	li	a5,2
	beq	a0,a5,.L5
	li	a5,3
	beq	a0,a5,.L6
	li	a5,4
	beq	a0,a5,.L7
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	ret
.L3:
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	ret
.L4:
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	ret
.L5:
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	ret
.L6:
	lui	a0,%hi(.LC4)
	addi	a0,a0,%lo(.LC4)
	ret
.L7:
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	ret
	.size	board_name, .-board_name
	.globl	threads
	.comm	io,16,4
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"unknown host x86"
	.zero	3
.LC1:
	.string	"xilinx ac701 artix-7 a200"
	.zero	2
.LC2:
	.string	"simulation only"
.LC3:
	.string	"avnet microboard spartan-6 lx9"
	.zero	1
.LC4:
	.string	"qmtech sdram lx16"
	.zero	2
.LC5:
	.string	"unknown"
	.section	.sbss,"aw",@nobits
	.align	2
	.type	threads, @object
	.size	threads, 4
threads:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
