	.file	"main.c"
	.option nopic
	.text
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-96
	sw	ra,92(sp)
	sw	s0,88(sp)
	sw	s1,84(sp)
	sw	s2,80(sp)
	sw	s3,76(sp)
	sw	s4,72(sp)
	sw	s5,68(sp)
	sw	s6,64(sp)
	sw	s7,60(sp)
	sw	s8,56(sp)
	sw	s9,52(sp)
	sw	s10,48(sp)
	sw	s11,44(sp)
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	puts
	lui	s4,%hi(.LC1)
	lui	s3,%hi(.LC2)
	lui	s5,%hi(.LC4)
	lui	s7,%hi(.LC6)
	lui	s8,%hi(.LC7)
	lui	s6,%hi(io)
	addi	s6,s6,%lo(io)
	j	.L2
.L3:
	addi	a1,s5,%lo(.LC4)
	mv	a0,sp
	call	strcmp
	beqz	a0,.L27
	addi	a1,s7,%lo(.LC6)
	mv	a0,sp
	call	strcmp
	beqz	a0,.L28
	addi	a1,s8,%lo(.LC7)
	mv	a0,sp
	call	strcmp
	beqz	a0,.L29
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	puts
	j	.L2
.L27:
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	call	puts
	lw	a5,8(s6)
	addi	a5,a5,1
	sw	a5,8(s6)
.L2:
	addi	a0,s4,%lo(.LC1)
	call	printf
	li	a1,32
	mv	a0,sp
	call	gets
	addi	a1,s3,%lo(.LC2)
	mv	a0,sp
	call	strcmp
	bnez	a0,.L3
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	printf
	j	.L2
.L9:
	li	a0,46
	call	putchar
.L10:
	addi	s1,s1,1
	beq	s2,s1,.L30
.L11:
	lbu	a0,0(s1)
	addi	a5,a0,-32
	andi	a5,a5,0xff
	bgtu	a5,s9,.L9
	call	putchar
	j	.L10
.L30:
	li	a0,10
	call	putchar
	addi	s10,s10,32
	addi	s2,s2,32
	beq	s10,s11,.L2
.L6:
	mv	s1,s10
	mv	s0,s10
.L8:
	lbu	a0,0(s0)
	call	putx
	li	a0,32
	call	putchar
	addi	s0,s0,1
	bne	s0,s2,.L8
	j	.L11
.L28:
	li	s2,4096
	addi	s2,s2,32
	li	s10,4096
	li	s9,94
	li	s11,4096
	addi	s11,s11,512
	j	.L6
.L15:
	li	a0,46
	call	putchar
.L16:
	addi	s1,s1,1
	beq	s1,s2,.L31
.L17:
	lbu	a0,0(s1)
	addi	a5,a0,-32
	andi	a5,a5,0xff
	bgtu	a5,s9,.L15
	call	putchar
	j	.L16
.L31:
	li	a0,10
	call	putchar
	addi	s10,s10,32
	addi	s2,s2,32
	beq	s10,s11,.L2
.L12:
	mv	s1,s10
	mv	s0,s10
.L14:
	lbu	a0,0(s0)
	call	putx
	li	a0,32
	call	putchar
	addi	s0,s0,1
	bne	s0,s2,.L14
	j	.L17
.L29:
	li	s10,8192
	addi	s2,s10,-480
	addi	s10,s10,-512
	li	s9,94
	li	s11,8192
	j	.L12
	.size	main, .-main
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"Welcome to DarkRISCV!"
	.zero	2
.LC1:
	.string	"> "
	.zero	1
.LC2:
	.string	"clear"
	.zero	2
.LC3:
	.string	"\033[H\033[2J"
.LC4:
	.string	"led"
.LC5:
	.string	"led switch."
.LC6:
	.string	"heap"
	.zero	3
.LC7:
	.string	"stack"
	.zero	2
.LC8:
	.string	"command: not found."
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
