	.file	"stdio.c"
	.option nopic
	.text
	.align	2
	.globl	getchar
	.type	getchar, @function
getchar:
	lui	a5,%hi(io)
	lw	a4,%lo(io)(a5)
.L2:
	lw	a5,0(a4)
	andi	a5,a5,2
	beqz	a5,.L2
	lw	a0,4(a4)
	ret
	.size	getchar, .-getchar
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	li	a5,10
	beq	a0,a5,.L10
.L5:
	lui	a5,%hi(io)
	lw	a4,%lo(io)(a5)
.L7:
	lw	a5,0(a4)
	andi	a5,a5,1
	bnez	a5,.L7
	sw	a0,4(a4)
	ret
.L10:
	lui	a5,%hi(io)
	lw	a4,%lo(io)(a5)
.L6:
	lw	a5,0(a4)
	andi	a5,a5,1
	bnez	a5,.L6
	li	a5,13
	sw	a5,4(a4)
	j	.L5
	.size	putchar, .-putchar
	.align	2
	.globl	gets
	.type	gets, @function
gets:
	addi	sp,sp,-32
	sw	ra,28(sp)
	sw	s0,24(sp)
	sw	s1,20(sp)
	sw	s2,16(sp)
	sw	s3,12(sp)
	li	a5,1
	beq	a1,a5,.L14
	mv	s0,a0
	li	s2,10
	li	s3,13
	addi	a1,a1,-1
	add	s1,a0,a1
.L13:
	call	getchar
	beq	a0,s2,.L12
	beq	a0,s3,.L12
	addi	s0,s0,1
	sb	a0,-1(s0)
	andi	a0,a0,0xff
	call	putchar
	bne	s0,s1,.L13
.L12:
	li	a0,10
	call	putchar
	sb	zero,0(s0)
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	lw	s2,16(sp)
	lw	s3,12(sp)
	addi	sp,sp,32
	jr	ra
.L14:
	mv	s0,a0
	j	.L12
	.size	gets, .-gets
	.align	2
	.globl	putstr
	.type	putstr, @function
putstr:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	lbu	a0,0(a0)
	beqz	a0,.L17
.L19:
	addi	s0,s0,1
	call	putchar
	lbu	a0,0(s0)
	bnez	a0,.L19
.L17:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	putstr, .-putstr
	.align	2
	.globl	puts
	.type	puts, @function
puts:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	mv	s0,a0
	lbu	a0,0(a0)
	beqz	a0,.L23
.L24:
	addi	s0,s0,1
	call	putchar
	lbu	a0,0(s0)
	bnez	a0,.L24
.L23:
	li	a0,10
	call	putchar
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
	.size	puts, .-puts
	.align	2
	.globl	hex
	.type	hex, @function
hex:
	li	a5,9
	ble	a0,a5,.L29
	li	a5,97
.L28:
	add	a0,a5,a0
	ret
.L29:
	li	a5,48
	j	.L28
	.size	hex, .-hex
	.align	2
	.globl	putx
	.type	putx, @function
putx:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	mv	s0,a0
	li	a5,16777216
	bgt	a0,a5,.L37
	li	a5,65536
	bgt	a0,a5,.L32
	li	a5,256
	bgt	a0,a5,.L34
.L35:
	srai	a5,s0,4
	andi	a5,a5,15
	lui	s1,%hi(.LC0)
	addi	s1,s1,%lo(.LC0)
	add	a5,a5,s1
	lbu	a0,0(a5)
	call	putchar
	andi	a5,s0,15
	add	s1,a5,s1
	lbu	a0,0(s1)
	call	putchar
	mv	a0,s0
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L37:
	srli	a5,a0,28
	lui	s1,%hi(.LC0)
	addi	s1,s1,%lo(.LC0)
	add	a5,a5,s1
	lbu	a0,0(a5)
	call	putchar
	srai	a5,s0,24
	andi	a5,a5,15
	add	a5,a5,s1
	lbu	a0,0(a5)
	call	putchar
.L32:
	srai	a5,s0,20
	andi	a5,a5,15
	lui	s1,%hi(.LC0)
	addi	s1,s1,%lo(.LC0)
	add	a5,a5,s1
	lbu	a0,0(a5)
	call	putchar
	srai	a5,s0,16
	andi	a5,a5,15
	add	a5,a5,s1
	lbu	a0,0(a5)
	call	putchar
.L34:
	srai	a5,s0,12
	andi	a5,a5,15
	lui	s1,%hi(.LC0)
	addi	s1,s1,%lo(.LC0)
	add	a5,a5,s1
	lbu	a0,0(a5)
	call	putchar
	srai	a5,s0,8
	andi	a5,a5,15
	add	a5,a5,s1
	lbu	a0,0(a5)
	call	putchar
	j	.L35
	.size	putx, .-putx
	.align	2
	.globl	printf
	.type	printf, @function
printf:
	addi	sp,sp,-80
	sw	ra,44(sp)
	sw	s0,40(sp)
	sw	s1,36(sp)
	sw	s2,32(sp)
	sw	s3,28(sp)
	sw	s4,24(sp)
	sw	a0,12(sp)
	sw	a1,52(sp)
	sw	a2,56(sp)
	sw	a3,60(sp)
	sw	a4,64(sp)
	sw	a5,68(sp)
	sw	a6,72(sp)
	sw	a7,76(sp)
	mv	a4,a0
	lbu	a0,0(a0)
	beqz	a0,.L39
	addi	s1,sp,12
	li	s0,37
	li	s2,115
	li	s3,120
	j	.L44
.L47:
	addi	s4,s1,4
	lw	a0,4(s1)
	call	putstr
	mv	s1,s4
	j	.L42
.L48:
	addi	s4,s1,4
	lw	a0,4(s1)
	call	putx
	mv	s1,s4
	j	.L42
.L40:
	call	putchar
.L42:
	lw	a5,12(sp)
	addi	a4,a5,1
	sw	a4,12(sp)
	lbu	a0,1(a5)
	beqz	a0,.L39
.L44:
	bne	a0,s0,.L40
	lbu	a5,1(a4)
	beq	a5,s2,.L47
	beq	a5,s3,.L48
	mv	a0,s0
	call	putchar
	j	.L42
.L39:
	li	a0,0
	lw	ra,44(sp)
	lw	s0,40(sp)
	lw	s1,36(sp)
	lw	s2,32(sp)
	lw	s3,28(sp)
	lw	s4,24(sp)
	addi	sp,sp,80
	jr	ra
	.size	printf, .-printf
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
	lbu	a5,0(a0)
	beqz	a5,.L51
.L50:
	lbu	a4,0(a1)
	beqz	a4,.L51
	bne	a4,a5,.L51
	addi	a0,a0,1
	addi	a1,a1,1
	lbu	a5,0(a0)
	bnez	a5,.L50
.L51:
	lbu	a0,0(a1)
	sub	a0,a5,a0
	ret
	.size	strcmp, .-strcmp
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"0123456789abcdef"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
