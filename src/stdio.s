	.file	"stdio.c"
	.option nopic
	.text
	.align	2
	.globl	getchar
	.type	getchar, @function
getchar:
	lui	a4,%hi(io)
.L2:
	lw	a5,%lo(io)(a4)
	andi	a5,a5,2
	beqz	a5,.L2
	lui	a5,%hi(io)
	addi	a5,a5,%lo(io)
	lw	a0,4(a5)
	ret
	.size	getchar, .-getchar
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	li	a5,10
	beq	a0,a5,.L10
.L5:
	lui	a4,%hi(io)
.L7:
	lw	a5,%lo(io)(a4)
	andi	a5,a5,1
	bnez	a5,.L7
	lui	a5,%hi(io)
	addi	a5,a5,%lo(io)
	sw	a0,4(a5)
	ret
.L10:
	lui	a4,%hi(io)
.L6:
	lw	a5,%lo(io)(a4)
	andi	a5,a5,1
	bnez	a5,.L6
	lui	a5,%hi(io)
	addi	a5,a5,%lo(io)
	li	a4,13
	sw	a4,4(a5)
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
	addi	sp,sp,-48
	sw	ra,12(sp)
	sw	a1,20(sp)
	sw	a2,24(sp)
	sw	a3,28(sp)
	sw	a4,32(sp)
	sw	a5,36(sp)
	sw	a6,40(sp)
	sw	a7,44(sp)
	call	putstr
	li	a0,0
	lw	ra,12(sp)
	addi	sp,sp,48
	jr	ra
	.size	printf, .-printf
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
	lbu	a5,0(a0)
	beqz	a5,.L42
.L41:
	lbu	a4,0(a1)
	beqz	a4,.L42
	bne	a4,a5,.L42
	addi	a0,a0,1
	addi	a1,a1,1
	lbu	a5,0(a0)
	bnez	a5,.L41
.L42:
	lbu	a0,0(a1)
	sub	a0,a5,a0
	ret
	.size	strcmp, .-strcmp
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"0123456789abcdef"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
