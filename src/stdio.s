	.file	"stdio.c"
	.option nopic
	.text
	.align	2
	.globl	getchar
	.type	getchar, @function
getchar:
	lui	a5,%hi(io)
.L2:
	lw	a4,%lo(io)(a5)
	andi	a4,a4,2
	beqz	a4,.L2
	addi	a5,a5,%lo(io)
	lw	a0,4(a5)
	ret
	.size	getchar, .-getchar
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	li	a4,10
	lui	a5,%hi(io)
	bne	a0,a4,.L8
.L7:
	lw	a4,%lo(io)(a5)
	andi	a4,a4,1
	bnez	a4,.L7
	addi	a4,a5,%lo(io)
	li	a3,13
	sw	a3,4(a4)
.L8:
	lw	a4,%lo(io)(a5)
	andi	a4,a4,1
	bnez	a4,.L8
	addi	a5,a5,%lo(io)
	sw	a0,4(a5)
	ret
	.size	putchar, .-putchar
	.align	2
	.globl	gets
	.type	gets, @function
gets:
	addi	sp,sp,-32
	addi	a1,a1,-1
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	sw	ra,28(sp)
	mv	s0,a0
	add	s1,a0,a1
	li	s2,10
	li	s3,13
.L12:
	beq	s0,s1,.L14
	call	getchar
	bne	a0,s2,.L13
.L14:
	li	a0,10
	call	putchar
	lw	ra,28(sp)
	sb	zero,0(s0)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
.L13:
	beq	a0,s3,.L14
	addi	s0,s0,1
	sb	a0,-1(s0)
	andi	a0,a0,0xff
	call	putchar
	j	.L12
	.size	gets, .-gets
	.align	2
	.globl	puts
	.type	puts, @function
puts:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	mv	s0,a0
.L19:
	lbu	a0,0(s0)
	bnez	a0,.L20
	lw	s0,8(sp)
	lw	ra,12(sp)
	li	a0,10
	addi	sp,sp,16
	tail	putchar
.L20:
	addi	s0,s0,1
	call	putchar
	j	.L19
	.size	puts, .-puts
	.align	2
	.globl	putx
	.type	putx, @function
putx:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	ra,12(sp)
	lui	s1,%hi(.LC0)
	li	a5,16777216
	mv	s0,a0
	addi	s1,s1,%lo(.LC0)
	bleu	a0,a5,.L23
	srli	a5,a0,28
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
	srli	a5,s0,24
	andi	a5,a5,15
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
.L24:
	srli	a5,s0,20
	andi	a5,a5,15
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
	srli	a5,s0,16
	andi	a5,a5,15
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
.L26:
	srli	a5,s0,12
	andi	a5,a5,15
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
	srli	a5,s0,8
	andi	a5,a5,15
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
	j	.L27
.L23:
	li	a5,65536
	bgtu	a0,a5,.L24
	li	a5,256
	bgtu	a0,a5,.L26
.L27:
	srli	a5,s0,4
	andi	a5,a5,15
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
	andi	a5,s0,15
	add	s1,s1,a5
	lbu	a0,0(s1)
	call	putchar
	mv	a0,s0
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	putx, .-putx
	.align	2
	.globl	printf
	.type	printf, @function
printf:
	addi	sp,sp,-80
	sw	a5,68(sp)
	addi	a5,sp,52
	sw	s0,40(sp)
	sw	s2,32(sp)
	sw	s3,28(sp)
	sw	s4,24(sp)
	sw	ra,44(sp)
	sw	s1,36(sp)
	mv	s0,a0
	sw	a1,52(sp)
	sw	a2,56(sp)
	sw	a3,60(sp)
	sw	a4,64(sp)
	sw	a6,72(sp)
	sw	a7,76(sp)
	sw	a5,12(sp)
	li	s2,37
	li	s3,115
	li	s4,120
.L30:
	lbu	a0,0(s0)
	bnez	a0,.L35
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	lw	s4,24(sp)
	addi	sp,sp,80
	jr	ra
.L35:
	addi	s1,s0,1
	bne	a0,s2,.L31
	lbu	a0,1(s0)
	bne	a0,s3,.L32
	lw	a5,12(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,12(sp)
	call	printf
.L33:
	addi	s0,s1,1
	j	.L30
.L32:
	bne	a0,s4,.L34
	lw	a5,12(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,12(sp)
	call	putx
	j	.L33
.L34:
	call	putchar
	j	.L33
.L31:
	call	putchar
	mv	s1,s0
	j	.L33
	.size	printf, .-printf
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
.L38:
	lbu	a4,0(a0)
	lbu	a5,0(a1)
	beqz	a4,.L39
	beqz	a5,.L39
	beq	a4,a5,.L40
.L39:
	sub	a0,a4,a5
	ret
.L40:
	addi	a0,a0,1
	addi	a1,a1,1
	j	.L38
	.size	strcmp, .-strcmp
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	li	a5,0
.L48:
	bne	a5,a2,.L49
	ret
.L49:
	add	a4,a1,a5
	lbu	a3,0(a4)
	add	a4,a0,a5
	addi	a5,a5,1
	sb	a3,0(a4)
	j	.L48
	.size	memcpy, .-memcpy
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"0123456789abcdef"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
