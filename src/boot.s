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
	sw	a3,%lo(threads)(a4)
	lui	a4,%hi(io)
	sw	ra,12(sp)
	sw	s1,4(sp)
	andi	a5,a5,1
	addi	a3,a4,%lo(io)
	li	a2,-128
	sw	a5,0(sp)
	sb	a2,3(a3)
	lui	s0,%hi(utimers)
	beqz	a5,.L5
	addi	a4,a4,%lo(io)
	li	a3,-128
.L2:
	lw	a5,%lo(utimers)(s0)
	addi	a2,a5,1
	srli	a5,a5,20
	xori	a5,a5,1
	sw	a2,%lo(utimers)(s0)
	andi	a5,a5,1
	sh	a5,8(a4)
	sb	a3,3(a4)
	j	.L2
.L5:
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
	.size	boot, .-boot
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"boot0: text@%d data@%d stack@%d\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
