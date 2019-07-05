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
	addi	a1,a1,-1
	addi	sp,sp,-20
	add	a5,a0,a1
	sw	s0,12(sp)
	sw	s1,8(sp)
	sw	ra,16(sp)
	mv	s1,a0
	sw	a5,0(sp)
	mv	s0,a0
.L12:
	lw	a5,0(sp)
	beq	s0,a5,.L16
	call	getchar
	li	a3,10
	bne	a0,a3,.L13
.L16:
	li	a0,10
	call	putchar
	sb	zero,0(s0)
	bne	s0,s1,.L14
	li	s1,0
.L14:
	lw	ra,16(sp)
	lw	s0,12(sp)
	mv	a0,s1
	lw	s1,8(sp)
	addi	sp,sp,20
	jr	ra
.L13:
	li	a3,13
	sw	a0,4(sp)
	beq	a0,a3,.L16
	call	putchar
	lw	a4,4(sp)
	addi	s0,s0,1
	sb	a4,-1(s0)
	j	.L12
	.size	gets, .-gets
	.align	2
	.globl	putstr
	.type	putstr, @function
putstr:
	addi	sp,sp,-12
	sw	s0,4(sp)
	sw	ra,8(sp)
	mv	s0,a0
	bnez	a0,.L21
	lui	s0,%hi(.LC1)
	addi	s0,s0,%lo(.LC1)
.L21:
	lbu	a0,0(s0)
	bnez	a0,.L23
	lw	ra,8(sp)
	lw	s0,4(sp)
	addi	sp,sp,12
	jr	ra
.L23:
	addi	s0,s0,1
	call	putchar
	j	.L21
	.size	putstr, .-putstr
	.align	2
	.globl	puts
	.type	puts, @function
puts:
	addi	sp,sp,-12
	sw	ra,8(sp)
	call	putstr
	lw	ra,8(sp)
	li	a0,10
	addi	sp,sp,12
	tail	putchar
	.size	puts, .-puts
	.align	2
	.globl	putx
	.type	putx, @function
putx:
	addi	sp,sp,-12
	sw	s0,4(sp)
	sw	s1,0(sp)
	sw	ra,8(sp)
	lui	s1,%hi(.LC2)
	li	a5,16777216
	mv	s0,a0
	addi	s1,s1,%lo(.LC2)
	bltu	a0,a5,.L29
	srli	a5,a0,28
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
	srli	a5,s0,24
	andi	a5,a5,15
	add	a5,s1,a5
	lbu	a0,0(a5)
	call	putchar
.L30:
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
.L32:
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
	j	.L33
.L29:
	li	a5,65536
	bgeu	a0,a5,.L30
	li	a5,255
	bgtu	a0,a5,.L32
.L33:
	srli	a5,s0,4
	andi	a5,a5,15
	add	a5,s1,a5
	lbu	a0,0(a5)
	andi	s0,s0,15
	add	s0,s1,s0
	call	putchar
	lbu	a0,0(s0)
	lw	s0,4(sp)
	lw	ra,8(sp)
	lw	s1,0(sp)
	addi	sp,sp,12
	tail	putchar
	.size	putx, .-putx
	.align	2
	.globl	putd
	.type	putd, @function
putd:
	addi	sp,sp,-56
	lui	a1,%hi(.LANCHOR0)
	sw	s0,48(sp)
	li	a2,40
	mv	s0,a0
	addi	a1,a1,%lo(.LANCHOR0)
	addi	a0,sp,4
	sw	ra,52(sp)
	sw	s1,44(sp)
	call	memcpy
	bgez	s0,.L36
	li	a0,45
	call	putchar
	sub	s0,zero,s0
.L36:
	li	a1,0
	li	s1,0
.L42:
	slli	a5,s1,2
	addi	a4,sp,4
	add	a5,a4,a5
	lw	a3,0(a5)
	li	a0,1
	sub	a2,s0,a3
	mv	a5,a3
.L38:
	bgt	a3,a2,.L37
	addi	a0,a0,1
	li	a4,10
	add	a5,a5,a3
	sub	a2,a2,a3
	bne	a0,a4,.L38
.L37:
	sub	a5,s0,a5
	sw	a5,0(sp)
	bltz	a5,.L39
	addi	a0,a0,48
	call	putchar
	lw	a5,0(sp)
	li	a1,1
	mv	s0,a5
.L40:
	addi	s1,s1,1
	li	a5,10
	bne	s1,a5,.L42
	lw	ra,52(sp)
	lw	s0,48(sp)
	lw	s1,44(sp)
	addi	sp,sp,56
	jr	ra
.L39:
	bnez	a1,.L41
	li	a5,9
	bne	s1,a5,.L40
.L41:
	li	a0,48
	sw	a1,0(sp)
	call	putchar
	lw	a1,0(sp)
	j	.L40
	.size	putd, .-putd
	.align	2
	.globl	printf
	.type	printf, @function
printf:
	addi	sp,sp,-36
	sw	a5,32(sp)
	addi	a5,sp,16
	sw	s0,8(sp)
	sw	ra,12(sp)
	sw	s1,4(sp)
	mv	s0,a0
	sw	a1,16(sp)
	sw	a2,20(sp)
	sw	a3,24(sp)
	sw	a4,28(sp)
	sw	a5,0(sp)
.L47:
	lbu	a0,0(s0)
	bnez	a0,.L53
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,36
	jr	ra
.L53:
	li	a5,37
	addi	s1,s0,1
	bne	a0,a5,.L48
	lbu	a0,1(s0)
	li	a5,115
	bne	a0,a5,.L49
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putstr
.L50:
	addi	s0,s1,1
	j	.L47
.L49:
	li	a5,120
	bne	a0,a5,.L51
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putx
	j	.L50
.L51:
	li	a5,100
	bne	a0,a5,.L52
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putd
	j	.L50
.L52:
	call	putchar
	j	.L50
.L48:
	call	putchar
	mv	s1,s0
	j	.L50
	.size	printf, .-printf
	.align	2
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	addi	a2,a2,-1
	li	a5,0
.L57:
	add	a4,a0,a5
	lbu	a3,0(a4)
	add	a4,a1,a5
	lbu	a4,0(a4)
	beq	a5,a2,.L56
	beqz	a3,.L56
	beqz	a4,.L56
	addi	a5,a5,1
	beq	a3,a4,.L57
.L56:
	sub	a0,a3,a4
	ret
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
.L67:
	add	a4,a0,a5
	lbu	a4,0(a4)
	beqz	a4,.L66
	addi	a5,a5,1
	add	a4,a0,a5
	bnez	a4,.L67
.L66:
	mv	a0,a5
	ret
	.size	strlen, .-strlen
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	li	a5,0
.L74:
	bne	a5,a2,.L75
	ret
.L75:
	add	a4,a1,a5
	lbu	a3,0(a4)
	add	a4,a0,a5
	addi	a5,a5,1
	sb	a3,0(a4)
	j	.L74
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	add	a2,a0,a2
	mv	a5,a0
.L77:
	bne	a5,a2,.L78
	ret
.L78:
	addi	a5,a5,1
	sb	a1,-1(a5)
	j	.L77
	.size	memset, .-memset
	.align	2
	.globl	strtok
	.type	strtok, @function
strtok:
	addi	sp,sp,-20
	sw	s0,12(sp)
	mv	s0,a0
	mv	a0,a1
	sw	s1,8(sp)
	sw	ra,16(sp)
	mv	s1,a1
	call	strlen
	mv	a3,a0
	bnez	s0,.L80
	lui	a5,%hi(nxt.1622)
	lw	s0,%lo(nxt.1622)(a5)
	beqz	s0,.L81
.L80:
	mv	a5,s0
.L82:
	lbu	a4,0(a5)
	bnez	a4,.L83
	lui	a5,%hi(nxt.1622)
	sw	zero,%lo(nxt.1622)(a5)
	j	.L81
.L83:
	mv	a2,a3
	mv	a0,a5
	mv	a1,s1
	sw	a3,4(sp)
	sw	a5,0(sp)
	call	strncmp
	lw	a5,0(sp)
	lw	a3,4(sp)
	addi	a4,a5,1
	bnez	a0,.L84
	sb	zero,0(a5)
	lui	a5,%hi(nxt.1622)
	sw	a4,%lo(nxt.1622)(a5)
.L81:
	mv	a0,s0
	lw	ra,16(sp)
	lw	s0,12(sp)
	lw	s1,8(sp)
	addi	sp,sp,20
	jr	ra
.L84:
	mv	a5,a4
	j	.L82
	.size	strtok, .-strtok
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	li	a3,0
	li	a5,0
	li	a2,45
.L90:
	bnez	a0,.L92
.L96:
	bnez	a3,.L93
.L89:
	mv	a0,a5
	ret
.L97:
	li	a3,1
	j	.L91
.L92:
	lbu	a4,0(a0)
	beqz	a4,.L96
	beq	a4,a2,.L97
	slli	a1,a5,3
	addi	a4,a4,-48
	add	a4,a4,a1
	slli	a5,a5,1
	add	a5,a4,a5
.L91:
	addi	a0,a0,1
	j	.L90
.L93:
	sub	a5,zero,a5
	j	.L89
	.size	atoi, .-atoi
	.align	2
	.globl	xtoi
	.type	xtoi, @function
xtoi:
	mv	a3,a0
	li	a2,57
	li	a0,0
.L99:
	beqz	a3,.L98
	lbu	a5,0(a3)
	bnez	a5,.L103
.L98:
	ret
.L103:
	slli	a4,a0,4
	bgtu	a5,a2,.L100
	addi	a5,a5,-48
.L107:
	add	a0,a5,a4
	addi	a3,a3,1
	j	.L99
.L100:
	andi	a5,a5,95
	addi	a5,a5,-55
	j	.L107
	.size	xtoi, .-xtoi
	.align	2
	.globl	mac
	.type	mac, @function
mac:
 #APP
# 278 "stdio.c" 1
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
	bltu	a5,a1,.L110
.L111:
	bnez	a1,.L116
	ret
.L113:
	andi	a4,a5,1
	beqz	a4,.L112
	add	a0,a0,a1
.L112:
	srli	a5,a5,1
	slli	a1,a1,1
.L110:
	bnez	a5,.L113
	ret
.L116:
	andi	a4,a1,1
	beqz	a4,.L115
	add	a0,a0,a5
.L115:
	slli	a5,a5,1
	srli	a1,a1,1
	j	.L111
	.size	__mului3, .-__mului3
	.align	2
	.globl	__mulsi3
	.type	__mulsi3, @function
__mulsi3:
	addi	sp,sp,-12
	sw	s1,0(sp)
	sw	ra,8(sp)
	sw	s0,4(sp)
	li	s1,0
	bgez	a0,.L125
	sub	a0,zero,a0
	li	s1,1
.L125:
	li	s0,0
	bgez	a1,.L126
	sub	a1,zero,a1
	li	s0,1
.L126:
	call	__mului3
	mv	a5,a0
	beq	s1,s0,.L124
	sub	a5,zero,a0
.L124:
	lw	ra,8(sp)
	lw	s0,4(sp)
	lw	s1,0(sp)
	mv	a0,a5
	addi	sp,sp,12
	jr	ra
	.size	__mulsi3, .-__mulsi3
	.align	2
	.globl	__divu_modui3
	.type	__divu_modui3, @function
__divu_modui3:
	li	a5,1
	bnez	a1,.L135
.L134:
	mv	a0,a1
	ret
.L136:
	slli	a5,a5,1
	slli	a1,a1,1
.L135:
	bgtu	a0,a1,.L136
	mv	a4,a1
	li	a1,0
.L137:
	beqz	a0,.L139
	bnez	a5,.L140
.L139:
	bnez	a2,.L134
	mv	a1,a0
	j	.L134
.L140:
	bltu	a0,a4,.L138
	sub	a0,a0,a4
	add	a1,a1,a5
.L138:
	srli	a5,a5,1
	srli	a4,a4,1
	j	.L137
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
	beqz	a1,.L163
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	sw	s1,4(sp)
	mv	a5,a2
	li	s0,0
	bgez	a0,.L151
	sub	a0,zero,a0
	li	s0,1
.L151:
	li	s1,0
	bgez	a1,.L152
	sub	a1,zero,a1
	li	s1,1
.L152:
	mv	a2,a5
	sw	a5,0(sp)
	call	__divu_modui3
	lw	a5,0(sp)
	mv	a1,a0
	beqz	a5,.L153
	beq	s0,s1,.L150
	sub	a1,zero,a0
.L150:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	mv	a0,a1
	addi	sp,sp,16
	jr	ra
.L153:
	beqz	s0,.L150
	sub	a1,zero,a0
	j	.L150
.L163:
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
	.string	"(NULL)"
	.zero	1
.LC2:
	.string	"0123456789abcdef"
	.section	.sbss,"aw",@nobits
	.align	2
	.type	nxt.1622, @object
	.size	nxt.1622, 4
nxt.1622:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
