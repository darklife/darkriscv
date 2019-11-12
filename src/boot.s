	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	boot
	.type	boot, @function
boot:
	lui	a4,%hi(threads)
	lw	a5,%lo(threads)(a4)
	addi	sp,sp,-16
	sw	s0,8(sp)
	addi	a3,a5,1
	lui	s0,%hi(io)
	sw	a3,%lo(threads)(a4)
	sw	s1,4(sp)
	sw	ra,12(sp)
	andi	a5,a5,1
	addi	a4,s0,%lo(io)
	li	a3,-128
	sw	a5,0(sp)
	sb	a3,3(a4)
	lui	s1,%hi(utimers)
	bnez	a5,.L2
	li	a0,48
	call	putchar
	lui	s0,%hi(boot)
.L3:
	call	banner
	lui	a0,%hi(.LC0)
	mv	a3,sp
	addi	a2,s1,%lo(utimers)
	addi	a1,s0,%lo(boot)
	addi	a0,a0,%lo(.LC0)
	call	printf
	call	main
	j	.L3
.L2:
	li	a0,49
	call	putchar
	addi	s0,s0,%lo(io)
	li	a4,-128
.L4:
	lw	a5,%lo(utimers)(s1)
	addi	a5,a5,1
	sw	a5,%lo(utimers)(s1)
	lhu	a5,10(s0)
	xori	a5,a5,1
	sh	a5,10(s0)
	sb	a4,3(s0)
	j	.L4
	.size	boot, .-boot
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"boot0: text@%d data@%d stack@%d\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
