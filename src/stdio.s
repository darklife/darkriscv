	.file	"stdio.c"
	.option nopic
	.text
	.align	2
	.globl	getchar
	.type	getchar, @function
getchar:
	lui	a5,%hi(io)
	addi	a5,a5,%lo(io)
.L2:
	lbu	a4,4(a5)
	andi	a4,a4,2
	beqz	a4,.L2
	lbu	a0,5(a5)
	ret
	.size	getchar, .-getchar
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	lui	a5,%hi(io)
	li	a4,10
	addi	a5,a5,%lo(io)
	bne	a0,a4,.L8
.L7:
	lbu	a4,4(a5)
	andi	a4,a4,1
	bnez	a4,.L7
	li	a4,13
	sb	a4,5(a5)
.L8:
	lbu	a4,4(a5)
	andi	a4,a4,1
	bnez	a4,.L8
	andi	a4,a0,0xff
	sb	a4,5(a5)
	mv	a0,a4
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
	lui	s1,%hi(.LC1)
	li	a5,16777216
	mv	s0,a0
	addi	s1,s1,%lo(.LC1)
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
	andi	s0,s0,15
	add	s0,s1,s0
	call	putchar
	lbu	a0,0(s0)
	lw	s0,8(sp)
	lw	ra,12(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	tail	putchar
	.size	putx, .-putx
	.align	2
	.globl	putd
	.type	putd, @function
putd:
	addi	sp,sp,-80
	lui	a1,%hi(.LANCHOR0)
	sw	s1,68(sp)
	li	a2,40
	mv	s1,a0
	addi	a1,a1,%lo(.LANCHOR0)
	addi	a0,sp,8
	sw	ra,76(sp)
	sw	s0,72(sp)
	sw	s2,64(sp)
	sw	s3,60(sp)
	sw	s4,56(sp)
	sw	s5,52(sp)
	sw	s6,48(sp)
	call	memcpy
	bgez	s1,.L30
	li	a0,45
	call	putchar
	sub	s1,zero,s1
.L30:
	addi	s0,sp,8
	li	s5,0
	li	s3,0
	li	s4,10
	li	s6,9
.L36:
	lw	a4,0(s0)
	li	a0,1
	sub	a3,s1,a4
	mv	a5,a4
.L32:
	bgt	a4,a3,.L31
	addi	a0,a0,1
	add	a5,a5,a4
	sub	a3,a3,a4
	bne	a0,s4,.L32
.L31:
	sub	s2,s1,a5
	bltz	s2,.L33
	addi	a0,a0,48
	call	putchar
	mv	s1,s2
	li	s5,1
.L34:
	addi	s3,s3,1
	addi	s0,s0,4
	bne	s3,s4,.L36
	lw	ra,76(sp)
	lw	s0,72(sp)
	lw	s1,68(sp)
	lw	s2,64(sp)
	lw	s3,60(sp)
	lw	s4,56(sp)
	lw	s5,52(sp)
	lw	s6,48(sp)
	addi	sp,sp,80
	jr	ra
.L33:
	bnez	s5,.L35
	bne	s3,s6,.L34
.L35:
	li	a0,48
	call	putchar
	j	.L34
	.size	putd, .-putd
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
	sw	s5,20(sp)
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
	li	s5,100
.L41:
	lbu	a0,0(s0)
	bnez	a0,.L47
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	lw	s4,24(sp)
	lw	s5,20(sp)
	addi	sp,sp,80
	jr	ra
.L47:
	addi	s1,s0,1
	bne	a0,s2,.L42
	lbu	a0,1(s0)
	bne	a0,s3,.L43
	lw	a5,12(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,12(sp)
	call	printf
.L44:
	addi	s0,s1,1
	j	.L41
.L43:
	bne	a0,s4,.L45
	lw	a5,12(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,12(sp)
	call	putx
	j	.L44
.L45:
	bne	a0,s5,.L46
	lw	a5,12(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,12(sp)
	call	putd
	j	.L44
.L46:
	call	putchar
	j	.L44
.L42:
	call	putchar
	mv	s1,s0
	j	.L44
	.size	printf, .-printf
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
.L50:
	lbu	a4,0(a0)
	lbu	a5,0(a1)
	beqz	a4,.L51
	beqz	a5,.L51
	beq	a4,a5,.L52
.L51:
	sub	a0,a4,a5
	ret
.L52:
	addi	a0,a0,1
	addi	a1,a1,1
	j	.L50
	.size	strcmp, .-strcmp
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	li	a5,0
.L60:
	bne	a5,a2,.L61
	ret
.L61:
	add	a4,a1,a5
	lbu	a3,0(a4)
	add	a4,a0,a5
	addi	a5,a5,1
	sb	a3,0(a4)
	j	.L60
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	add	a2,a0,a2
	mv	a5,a0
.L63:
	bne	a5,a2,.L64
	ret
.L64:
	addi	a5,a5,1
	sb	a1,-1(a5)
	j	.L63
	.size	memset, .-memset
	.section	.rodata
	.align	2
	.set	.LANCHOR0,. + 0
.LC0:
	.word	1000000000
	.word	100000000
	.word	10000000
	.word	1000000
	.word	100000
	.word	10000
	.word	1000
	.word	100
	.word	10
	.word	1
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC1:
	.string	"0123456789abcdef"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
