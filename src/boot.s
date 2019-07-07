	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	boot
	.type	boot, @function
boot:
	lui	a5,%hi(threads)
	addi	sp,sp,-16
	sw	s0,8(sp)
	lw	s0,%lo(threads)(a5)
	sw	ra,12(sp)
	addi	a4,s0,1
	andi	s0,s0,1
	addi	a0,s0,48
	sw	a4,%lo(threads)(a5)
	call	putchar
	lui	a5,%hi(io)
	addi	a5,a5,%lo(io)
	bnez	s0,.L2
	li	a4,49
	sw	a4,0(sp)
	li	a4,1
	sw	a4,12(a5)
.L3:
	call	main
	j	.L3
.L2:
	lw	a4,0(sp)
	sw	a4,12(a5)
.L4:
	lhu	a4,8(a5)
	xori	a4,a4,1
	sh	a4,8(a5)
	lhu	a4,10(a5)
	xori	a4,a4,1
	sh	a4,10(a5)
	sb	zero,3(a5)
	j	.L4
	.size	boot, .-boot
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
