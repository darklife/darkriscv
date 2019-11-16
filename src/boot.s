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
	sw	s1,4(sp)
	addi	a3,a5,1
	lui	s1,%hi(io)
	sw	a3,%lo(threads)(a4)
	sw	s0,8(sp)
	sw	ra,12(sp)
	andi	a5,a5,1
	addi	a4,s1,%lo(io)
	li	a3,-128
	sw	a5,0(sp)
	sb	a3,3(a4)
	lui	s0,%hi(utimers)
	bnez	a5,.L2
	li	a0,48
	call	putchar
	lui	s1,%hi(boot)
.L3:
	call	banner
	lui	a0,%hi(.LC0)
	addi	a3,sp,16
	addi	a2,s0,%lo(utimers)
	addi	a1,s1,%lo(boot)
	addi	a0,a0,%lo(.LC0)
	call	printf
	call	main
	j	.L3
.L2:
	li	a0,49
	call	putchar
	addi	s1,s1,%lo(io)
	li	a4,-128
.L4:
	lw	a5,%lo(utimers)(s0)
	addi	a3,a5,1
	srli	a5,a5,20
	xori	a5,a5,1
	sw	a3,%lo(utimers)(s0)
	andi	a5,a5,1
	sh	a5,8(s1)
	sb	a4,3(s1)
	j	.L4
	.size	boot, .-boot
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"boot0: text@%d data@%d stack@%d\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
