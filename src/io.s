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
	.LA4: auipc	a5,%pcrel_hi(.LC4)
	li	a4,2
	addi	a5,a5,%pcrel_lo(.LA4)
	beq	a0,a4,.L1
	.LA5: auipc	a5,%pcrel_hi(.LC5)
	li	a4,3
	addi	a5,a5,%pcrel_lo(.LA5)
	beq	a0,a4,.L1
	.LA6: auipc	a5,%pcrel_hi(.LC6)
	li	a4,4
	addi	a5,a5,%pcrel_lo(.LA6)
	beq	a0,a4,.L1
	.LA7: auipc	a5,%pcrel_hi(.LC7)
	li	a4,5
	addi	a5,a5,%pcrel_lo(.LA7)
	beq	a0,a4,.L1
	.LA8: auipc	a5,%pcrel_hi(.LC8)
	li	a4,6
	addi	a5,a5,%pcrel_lo(.LA8)
	beq	a0,a4,.L1
	.LA9: auipc	a5,%pcrel_hi(.LC9)
	li	a4,7
	addi	a5,a5,%pcrel_lo(.LA9)
	beq	a0,a4,.L1
	.LA1: auipc	a5,%pcrel_hi(.LC1)
	li	a4,8
	addi	a5,a5,%pcrel_lo(.LA1)
	beq	a0,a4,.L1
	.LA10: auipc	a5,%pcrel_hi(.LC10)
	li	a4,9
	addi	a5,a5,%pcrel_lo(.LA10)
	beq	a0,a4,.L1
	.LA0: auipc	a5,%pcrel_hi(.LC0)
	li	a4,10
	addi	a5,a5,%pcrel_lo(.LA0)
	beq	a0,a4,.L1
	.LA11: auipc	a5,%pcrel_hi(.LC11)
	addi	a5,a5,%pcrel_lo(.LA11)
.L1:
	mv	a0,a5
	ret
	.size	board_name, .-board_name
	.globl	utimers
	.globl	threads
	.comm	io,16,4
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"aliexpress hpc/40gbe ku040"
	.zero	1
.LC1:
	.string	"aliexpress hpc/40gbe k420"
	.zero	2
.LC2:
	.string	"simulation only"
.LC3:
	.string	"avnet microboard lx9"
	.zero	3
.LC4:
	.string	"xilinx ac701 a200"
	.zero	2
.LC5:
	.string	"qmtech sdram lx16"
	.zero	2
.LC6:
	.string	"qmtech spartan7 s15"
.LC7:
	.string	"lattice brevia2 lxp2"
	.zero	3
.LC8:
	.string	"piswords rs485 lx9"
	.zero	1
.LC9:
	.string	"digilent spartan3 s200"
	.zero	1
.LC10:
	.string	"qmtech artix7 a35"
	.zero	2
.LC11:
	.string	"unknown"
	.section	.sbss,"aw",@nobits
	.align	2
	.type	utimers, @object
	.size	utimers, 4
utimers:
	.zero	4
	.type	threads, @object
	.size	threads, 4
threads:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
