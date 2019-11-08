	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	boot
	.type	boot, @function
boot:
	addi	sp,sp,-16
	sw	s0,8(sp)
	lui	s0,%hi(threads)
	lw	a0,%lo(threads)(s0)
	sw	ra,12(sp)
	sw	s1,4(sp)
	addi	a5,a0,1
	andi	a0,a0,1
	sw	a0,0(sp)
	addi	a0,a0,48
	sw	a5,%lo(threads)(s0)
	call	putchar
	lw	a5,0(sp)
	beqz	a5,.L5
	lui	a5,%hi(io)
	addi	a5,a5,%lo(io)
.L2:
	lhu	a4,8(a5)
	xori	a4,a4,1
	sh	a4,8(a5)
	lhu	a4,10(a5)
	xori	a4,a4,1
	sh	a4,10(a5)
	sb	zero,3(a5)
	j	.L2
.L5:
	lui	s1,%hi(boot)
.L3:
	call	banner
	lui	a0,%hi(.LC0)
	mv	a3,sp
	addi	a2,s0,%lo(threads)
	addi	a1,s1,%lo(boot)
	addi	a0,a0,%lo(.LC0)
	call	printf
	call	main
	j	.L3
	.size	boot, .-boot
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"boot0: text@%d data@%d stack@%d\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
