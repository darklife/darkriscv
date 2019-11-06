	.file	"io.c"
	.option nopic
	.text
	.align	2
	.globl	board_name
	.type	board_name, @function
board_name:
	.LA2: auipc	a5,%pcrel_hi(.LC2)
	addi	a5,a5,%pcrel_lo(.LA2)
	beqz	a0,.L1
	.LA3: auipc	a5,%pcrel_hi(.LC3)
	li	a4,1
	addi	a5,a5,%pcrel_lo(.LA3)
	beq	a0,a4,.L1
	.LA1: auipc	a5,%pcrel_hi(.LC1)
	li	a4,2
	addi	a5,a5,%pcrel_lo(.LA1)
	beq	a0,a4,.L1
	.LA4: auipc	a5,%pcrel_hi(.LC4)
	li	a4,3
	addi	a5,a5,%pcrel_lo(.LA4)
	beq	a0,a4,.L1
	.LA0: auipc	a5,%pcrel_hi(.LC0)
	li	a4,4
	addi	a5,a5,%pcrel_lo(.LA0)
	beq	a0,a4,.L1
	.LA5: auipc	a5,%pcrel_hi(.LC5)
	addi	a5,a5,%pcrel_lo(.LA5)
.L1:
	mv	a0,a5
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
