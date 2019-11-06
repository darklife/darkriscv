	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	boot
	.type	boot, @function
boot:
	addi	sp,sp,-16
	.LA0: auipc	a5,%pcrel_hi(threads)
	sw	s0,8(sp)
	lw	s0,%pcrel_lo(.LA0)(a5)
	.LA1: auipc	a5,%pcrel_hi(threads)
	sw	ra,12(sp)
	addi	a4,s0,1
	andi	s0,s0,1
	addi	a0,s0,48
	sw	a4,%pcrel_lo(.LA1)(a5)
	call	putchar
	bnez	s0,.L2
	li	a5,49
	sw	a5,0(sp)
	.LA2: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA2)
	li	a4,1
	sw	a4,12(a5)
.L3:
	call	main
	j	.L3
.L2:
	lw	a4,0(sp)
	.LA3: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA3)
	sw	a4,12(a5)
.L4:
	.LA4: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA4)
	lhu	a4,8(a5)
	.LA5: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA5)
	xori	a4,a4,1
	sh	a4,8(a5)
	.LA6: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA6)
	lhu	a4,10(a5)
	.LA7: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA7)
	xori	a4,a4,1
	sh	a4,10(a5)
	.LA8: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA8)
	sb	zero,3(a5)
	j	.L4
	.size	boot, .-boot
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
