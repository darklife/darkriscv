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
	addi	sp,sp,-16
	addi	a1,a1,-1
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	ra,12(sp)
	mv	s0,a0
	add	s1,a0,a1
.L12:
	beq	s0,s1,.L14
	call	getchar
	li	a5,10
	bne	a0,a5,.L13
.L14:
	li	a0,10
	call	putchar
	lw	ra,12(sp)
	sb	zero,0(s0)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L13:
	li	a5,13
	beq	a0,a5,.L14
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
	sw	s0,72(sp)
	li	a2,40
	mv	s0,a0
	addi	a1,a1,%lo(.LANCHOR0)
	addi	a0,sp,24
	sw	ra,76(sp)
	sw	s1,68(sp)
	call	memcpy
	bgez	s0,.L30
	li	a0,45
	call	putchar
	sub	s0,zero,s0
.L30:
	li	a1,0
	li	s1,0
.L36:
	slli	a5,s1,2
	addi	a4,sp,24
	add	a5,a4,a5
	lw	a3,0(a5)
	li	a0,1
	sub	a2,s0,a3
	mv	a5,a3
.L32:
	bgt	a3,a2,.L31
	addi	a0,a0,1
	li	a4,10
	add	a5,a5,a3
	sub	a2,a2,a3
	bne	a0,a4,.L32
.L31:
	sub	a5,s0,a5
	sw	a5,12(sp)
	bltz	a5,.L33
	addi	a0,a0,48
	call	putchar
	lw	a5,12(sp)
	li	a1,1
	mv	s0,a5
.L34:
	addi	s1,s1,1
	li	a5,10
	bne	s1,a5,.L36
	lw	ra,76(sp)
	lw	s0,72(sp)
	lw	s1,68(sp)
	addi	sp,sp,80
	jr	ra
.L33:
	bnez	a1,.L35
	li	a5,9
	bne	s1,a5,.L34
.L35:
	li	a0,48
	sw	a1,12(sp)
	call	putchar
	lw	a1,12(sp)
	j	.L34
	.size	putd, .-putd
	.align	2
	.globl	printf
	.type	printf, @function
printf:
	addi	sp,sp,-64
	sw	a5,52(sp)
	addi	a5,sp,36
	sw	s0,24(sp)
	sw	ra,28(sp)
	sw	s1,20(sp)
	mv	s0,a0
	sw	a1,36(sp)
	sw	a2,40(sp)
	sw	a3,44(sp)
	sw	a4,48(sp)
	sw	a6,56(sp)
	sw	a7,60(sp)
	sw	a5,12(sp)
.L41:
	lbu	a0,0(s0)
	bnez	a0,.L47
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	addi	sp,sp,64
	jr	ra
.L47:
	li	a5,37
	addi	s1,s0,1
	bne	a0,a5,.L42
	lbu	a0,1(s0)
	li	a5,115
	bne	a0,a5,.L43
	lw	a5,12(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,12(sp)
	call	printf
.L44:
	addi	s0,s1,1
	j	.L41
.L43:
	li	a5,120
	bne	a0,a5,.L45
	lw	a5,12(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,12(sp)
	call	putx
	j	.L44
.L45:
	li	a5,100
	bne	a0,a5,.L46
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
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	li	a3,1
.L50:
	lbu	a4,0(a0)
	lbu	a5,0(a1)
	beq	a2,a3,.L51
	beqz	a4,.L51
	beqz	a5,.L51
	beq	a4,a5,.L52
.L51:
	sub	a0,a4,a5
	ret
.L52:
	addi	a0,a0,1
	addi	a1,a1,1
	addi	a2,a2,-2
	j	.L50
	.size	strncmp, .-strncmp
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
	li	a2,-1
	tail	strncmp
	.size	strcmp, .-strcmp
	.align	2
	.globl	strlen
	.type	strlen, @function
strlen:
	li	a5,0
.L61:
	add	a4,a0,a5
	lbu	a4,0(a4)
	bnez	a4,.L62
	mv	a0,a5
	ret
.L62:
	addi	a5,a5,1
	j	.L61
	.size	strlen, .-strlen
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	li	a5,0
.L64:
	bne	a5,a2,.L65
	ret
.L65:
	add	a4,a1,a5
	lbu	a3,0(a4)
	add	a4,a0,a5
	addi	a5,a5,1
	sb	a3,0(a4)
	j	.L64
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	add	a2,a0,a2
	mv	a5,a0
.L67:
	bne	a5,a2,.L68
	ret
.L68:
	addi	a5,a5,1
	sb	a1,-1(a5)
	j	.L67
	.size	memset, .-memset
	.align	2
	.globl	strtok
	.type	strtok, @function
strtok:
	addi	sp,sp,-32
	sw	s0,24(sp)
	mv	s0,a0
	mv	a0,a1
	sw	s1,20(sp)
	sw	ra,28(sp)
	mv	s1,a1
	call	strlen
	mv	a3,a0
	bnez	s0,.L70
	lui	a5,%hi(nxt.1616)
	lw	s0,%lo(nxt.1616)(a5)
	beqz	s0,.L71
.L70:
	mv	a5,s0
.L72:
	lbu	a4,0(a5)
	beqz	a4,.L71
	mv	a2,a3
	mv	a0,a5
	mv	a1,s1
	sw	a3,12(sp)
	sw	a5,8(sp)
	call	strncmp
	lw	a5,8(sp)
	lw	a3,12(sp)
	addi	a4,a5,1
	bnez	a0,.L74
	sb	zero,0(a5)
	lui	a5,%hi(nxt.1616)
	sw	a4,%lo(nxt.1616)(a5)
.L71:
	mv	a0,s0
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	addi	sp,sp,32
	jr	ra
.L74:
	mv	a5,a4
	j	.L72
	.size	strtok, .-strtok
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	li	a3,0
	li	a5,0
	li	a2,45
.L80:
	lbu	a4,0(a0)
	bnez	a4,.L82
	beqz	a3,.L79
	sub	a5,zero,a5
.L79:
	mv	a0,a5
	ret
.L82:
	beq	a4,a2,.L84
	slli	a1,a5,3
	addi	a4,a4,-48
	add	a4,a4,a1
	slli	a5,a5,1
	add	a5,a4,a5
.L81:
	addi	a0,a0,1
	j	.L80
.L84:
	li	a3,1
	j	.L81
	.size	atoi, .-atoi
	.align	2
	.globl	mac
	.type	mac, @function
mac:
 #APP
# 255 "stdio.c" 1
	.word 0x00c5857F
# 0 "" 2
 #NO_APP
	ret
	.size	mac, .-mac
	.align	2
	.globl	__mului3
	.type	__mului3, @function
__mului3:
	mv	a5,a0
	li	a0,0
	bltu	a5,a1,.L90
.L91:
	bnez	a1,.L96
	ret
.L93:
	andi	a4,a5,1
	beqz	a4,.L92
	add	a0,a0,a1
.L92:
	srli	a5,a5,1
	slli	a1,a1,1
.L90:
	bnez	a5,.L93
	ret
.L96:
	andi	a4,a1,1
	beqz	a4,.L95
	add	a0,a0,a5
.L95:
	slli	a5,a5,1
	srli	a1,a1,1
	j	.L91
	.size	__mului3, .-__mului3
	.align	2
	.globl	__mulsi3
	.type	__mulsi3, @function
__mulsi3:
	addi	sp,sp,-16
	sw	s1,4(sp)
	sw	ra,12(sp)
	sw	s0,8(sp)
	li	s1,0
	bgez	a0,.L105
	sub	a0,zero,a0
	li	s1,1
.L105:
	li	s0,0
	bgez	a1,.L106
	sub	a1,zero,a1
	li	s0,1
.L106:
	call	__mului3
	mv	a5,a0
	beq	s1,s0,.L104
	sub	a5,zero,a0
.L104:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	mv	a0,a5
	addi	sp,sp,16
	jr	ra
	.size	__mulsi3, .-__mulsi3
	.align	2
	.globl	__divu_modui3
	.type	__divu_modui3, @function
__divu_modui3:
	li	a5,1
	bnez	a1,.L115
.L114:
	mv	a0,a1
	ret
.L116:
	slli	a5,a5,1
	slli	a1,a1,1
.L115:
	bgtu	a0,a1,.L116
	mv	a4,a1
	li	a1,0
.L117:
	beqz	a0,.L119
	bnez	a5,.L120
.L119:
	bnez	a2,.L114
	mv	a1,a0
	j	.L114
.L120:
	bltu	a0,a4,.L118
	sub	a0,a0,a4
	add	a1,a1,a5
.L118:
	srli	a5,a5,1
	srli	a4,a4,1
	j	.L117
	.size	__divu_modui3, .-__divu_modui3
	.align	2
	.globl	__divui3
	.type	__divui3, @function
__divui3:
	li	a2,1
	tail	__divu_modui3
	.size	__divui3, .-__divui3
	.align	2
	.globl	__modui3
	.type	__modui3, @function
__modui3:
	li	a2,0
	tail	__divu_modui3
	.size	__modui3, .-__modui3
	.align	2
	.globl	__divs_modsi3
	.type	__divs_modsi3, @function
__divs_modsi3:
	beqz	a1,.L143
	addi	sp,sp,-32
	sw	s0,24(sp)
	sw	ra,28(sp)
	sw	s1,20(sp)
	mv	a5,a2
	li	s0,0
	bgez	a0,.L131
	sub	a0,zero,a0
	li	s0,1
.L131:
	li	s1,0
	bgez	a1,.L132
	sub	a1,zero,a1
	li	s1,1
.L132:
	mv	a2,a5
	sw	a5,12(sp)
	call	__divu_modui3
	lw	a5,12(sp)
	mv	a1,a0
	beqz	a5,.L133
	beq	s0,s1,.L130
	sub	a1,zero,a0
.L130:
	lw	ra,28(sp)
	lw	s0,24(sp)
	lw	s1,20(sp)
	mv	a0,a1
	addi	sp,sp,32
	jr	ra
.L133:
	beqz	s0,.L130
	sub	a1,zero,a0
	j	.L130
.L143:
	mv	a0,a1
	ret
	.size	__divs_modsi3, .-__divs_modsi3
	.align	2
	.globl	__divsi3
	.type	__divsi3, @function
__divsi3:
	li	a2,1
	tail	__divs_modsi3
	.size	__divsi3, .-__divsi3
	.align	2
	.globl	__modsi3
	.type	__modsi3, @function
__modsi3:
	li	a2,0
	tail	__divs_modsi3
	.size	__modsi3, .-__modsi3
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
	.section	.sbss,"aw",@nobits
	.align	2
	.type	nxt.1616, @object
	.size	nxt.1616, 4
nxt.1616:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
