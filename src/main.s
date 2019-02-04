	.file	"main.c"
	.option nopic
	.text
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-112
	lui	a0,%hi(.LC0)
	sw	s1,100(sp)
	addi	a0,a0,%lo(.LC0)
	lui	s1,%hi(io)
	sw	s3,92(sp)
	sw	s4,88(sp)
	sw	s5,84(sp)
	sw	s6,80(sp)
	sw	s7,76(sp)
	sw	s8,72(sp)
	sw	ra,108(sp)
	sw	s0,104(sp)
	sw	s2,96(sp)
	sw	s9,68(sp)
	sw	s10,64(sp)
	sw	s11,60(sp)
	lui	s3,%hi(.LC1)
	call	puts
	lui	s4,%hi(.LC2)
	lui	s5,%hi(.LC4)
	lui	s6,%hi(.LC6)
	lui	s7,%hi(.LC8)
	lui	s8,%hi(.LC10)
	addi	s1,s1,%lo(io)
.L2:
	addi	a0,s3,%lo(.LC1)
	call	printf
	li	a1,32
	addi	a0,sp,16
	call	gets
	addi	a1,s4,%lo(.LC2)
	addi	a0,sp,16
	call	strcmp
	bnez	a0,.L3
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	printf
	j	.L2
.L3:
	addi	a1,s5,%lo(.LC4)
	addi	a0,sp,16
	call	strcmp
	bnez	a0,.L5
	lw	a1,8(s1)
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	addi	a1,a1,1
	sw	a1,8(s1)
.L30:
	call	printf
	j	.L2
.L5:
	addi	a1,s6,%lo(.LC6)
	addi	a0,sp,16
	call	strcmp
	bnez	a0,.L6
	lui	a0,%hi(.LC7)
	lw	a1,12(s1)
	addi	a0,a0,%lo(.LC7)
	j	.L30
.L6:
	addi	a1,s7,%lo(.LC8)
	addi	a0,sp,16
	call	strcmp
	bnez	a0,.L27
	li	s0,4096
	lui	s9,%hi(.LC9)
	li	s2,32
	li	s10,94
	addi	s11,s0,512
	j	.L7
.L9:
	add	a4,s0,a5
	lbu	a1,0(a4)
	addi	a0,s9,%lo(.LC9)
	sw	a5,12(sp)
	call	printf
	lw	a5,12(sp)
	addi	a5,a5,1
	bne	a5,s2,.L9
	li	a5,0
.L11:
	add	a4,s0,a5
	lbu	a0,0(a4)
	addi	a4,a0,-32
	andi	a4,a4,0xff
	bleu	a4,s10,.L10
	li	a0,46
.L10:
	sw	a5,12(sp)
	call	putchar
	lw	a5,12(sp)
	addi	a5,a5,1
	bne	a5,s2,.L11
	li	a0,10
	addi	s0,s0,32
	call	putchar
	beq	s0,s11,.L2
.L7:
	li	a5,0
	j	.L9
.L27:
	addi	a1,s8,%lo(.LC10)
	addi	a0,sp,16
	call	strcmp
	bnez	a0,.L28
	li	s0,8192
	addi	s0,s0,-512
	lui	s9,%hi(.LC9)
	li	s2,32
	li	s10,94
	li	s11,8192
	j	.L13
.L15:
	add	a4,s0,a5
	lbu	a1,0(a4)
	addi	a0,s9,%lo(.LC9)
	sw	a5,12(sp)
	call	printf
	lw	a5,12(sp)
	addi	a5,a5,1
	bne	a5,s2,.L15
	li	a5,0
.L17:
	add	a4,s0,a5
	lbu	a0,0(a4)
	addi	a4,a0,-32
	andi	a4,a4,0xff
	bleu	a4,s10,.L16
	li	a0,46
.L16:
	sw	a5,12(sp)
	call	putchar
	lw	a5,12(sp)
	addi	a5,a5,1
	bne	a5,s2,.L17
	li	a0,10
	addi	s0,s0,32
	call	putchar
	beq	s0,s11,.L2
.L13:
	li	a5,0
	j	.L15
.L28:
	lbu	a5,16(sp)
	beqz	a5,.L2
	lui	a0,%hi(.LC11)
	addi	a1,sp,16
	addi	a0,a0,%lo(.LC11)
	j	.L30
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
	.string	"led = %x\n"
	.zero	2
.LC6:
	.string	"bug"
.LC7:
	.string	"bug = %x\n"
	.zero	2
.LC8:
	.string	"heap"
	.zero	3
.LC9:
	.string	"%x "
.LC10:
	.string	"stack"
	.zero	2
.LC11:
	.string	"command: [%s] not found.\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
