	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	boot
	.type	boot, @function
boot:
	.LA0: auipc	a5,%pcrel_hi(threads)
	lw	a0,%pcrel_lo(.LA0)(a5)
	addi	sp,sp,-20
	.LA1: auipc	a5,%pcrel_hi(threads)
	addi	a4,a0,1
	andi	a0,a0,1
	sw	a0,0(sp)
	addi	a0,a0,48
	sw	a4,%pcrel_lo(.LA1)(a5)
	sw	ra,16(sp)
	call	putchar
	lw	a5,0(sp)
	bnez	a5,.L2
	li	a5,49
	sw	a5,4(sp)
	.LA2: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA2)
	li	a4,1
	sw	a4,12(a5)
.L3:
	call	banner
	.LA3: auipc	a2,%pcrel_hi(threads)
	.LA4: auipc	a1,%pcrel_hi(boot)
	.LA5: auipc	a0,%pcrel_hi(.LC0)
	mv	a3,sp
	addi	a2,a2,%pcrel_lo(.LA3)
	addi	a1,a1,%pcrel_lo(.LA4)
	addi	a0,a0,%pcrel_lo(.LA5)
	call	printf
	call	main
	j	.L3
.L2:
	lw	a4,4(sp)
	.LA6: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA6)
	sw	a4,12(a5)
.L4:
	.LA7: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA7)
	lhu	a4,8(a5)
	.LA8: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA8)
	xori	a4,a4,1
	sh	a4,8(a5)
	.LA9: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA9)
	lhu	a4,10(a5)
	.LA10: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA10)
	xori	a4,a4,1
	sh	a4,10(a5)
	.LA11: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA11)
	sb	zero,3(a5)
	j	.L4
	.size	boot, .-boot
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"boot0: text@%d data@%d stack@%d\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
