	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	boot
	.type	boot, @function
boot:
	lui	a5,%hi(threads)
	lw	a4,%lo(threads)(a5)
	addi	sp,sp,-16
	sw	s0,8(sp)
	addi	a3,a4,1
	sw	a3,%lo(threads)(a5)
	lui	a5,%hi(io)
	sw	ra,12(sp)
	sw	s1,4(sp)
	andi	a4,a4,1
	addi	a3,a5,%lo(io)
	li	a2,-128
	sw	a4,0(sp)
	sb	a2,3(a3)
	lui	s0,%hi(utimers)
	beqz	a4,.L6
	li	a3,999424
	addi	a5,a5,%lo(io)
	addi	a3,a3,575
.L2:
	lw	a4,%lo(utimers)(s0)
	addi	a1,a4,-1
	sw	a1,%lo(utimers)(s0)
	bnez	a4,.L4
	lhu	a4,8(a5)
	addi	a4,a4,1
	slli	a4,a4,16
	srli	a4,a4,16
	sh	a4,8(a5)
	sw	a3,%lo(utimers)(s0)
.L4:
	sb	a2,3(a5)
	j	.L2
.L6:
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
