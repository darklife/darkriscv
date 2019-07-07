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
	lui	s0,%hi(.LC2)
	addi	s0,s0,%lo(.LC2)
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
	addi	sp,sp,-36
	lui	a1,%hi(.LANCHOR0)
	sw	s0,28(sp)
	li	a2,20
	mv	s0,a0
	addi	a1,a1,%lo(.LANCHOR0)
	addi	a0,sp,4
	sw	s1,24(sp)
	sw	ra,32(sp)
	call	memcpy
	addi	s1,sp,4
	li	a4,24
	lui	a3,%hi(.LC3)
.L29:
	lw	a5,0(s1)
	bnez	a5,.L32
	lw	ra,32(sp)
	lw	s0,28(sp)
	lw	s1,24(sp)
	addi	sp,sp,36
	jr	ra
.L32:
	li	a2,1
	beq	a5,a2,.L30
	bgtu	a5,s0,.L31
.L30:
	addi	a5,a4,4
	srl	a5,s0,a5
	addi	a2,a3,%lo(.LC3)
	andi	a5,a5,15
	add	a5,a5,a2
	lbu	a0,0(a5)
	sw	a4,0(sp)
	call	putchar
	lw	a4,0(sp)
	srl	a5,s0,a4
	lui	a4,%hi(.LC3)
	addi	a2,a4,%lo(.LC3)
	andi	a5,a5,15
	add	a5,a5,a2
	lbu	a0,0(a5)
	call	putchar
	lw	a4,0(sp)
	lui	a3,%hi(.LC3)
.L31:
	addi	a4,a4,-8
	addi	s1,s1,4
	j	.L29
	.size	putx, .-putx
	.globl	__divsi3
	.globl	__modsi3
	.align	2
	.globl	putd
	.type	putd, @function
putd:
	addi	sp,sp,-56
	lui	a1,%hi(.LANCHOR0+20)
	sw	s1,44(sp)
	li	a2,44
	mv	s1,a0
	addi	a1,a1,%lo(.LANCHOR0+20)
	mv	a0,sp
	sw	ra,52(sp)
	sw	s0,48(sp)
	call	memcpy
	bgez	s1,.L35
	li	a0,45
	call	putchar
	li	s1,-1
.L35:
	mv	s0,sp
.L36:
	lw	a1,0(s0)
	bnez	a1,.L39
	lw	ra,52(sp)
	lw	s0,48(sp)
	lw	s1,44(sp)
	addi	sp,sp,56
	jr	ra
.L39:
	li	a4,1
	beq	a1,a4,.L37
	blt	s1,a1,.L38
.L37:
	mv	a0,s1
	call	__divsi3
	li	a1,10
	call	__modsi3
	lui	a5,%hi(.LC4)
	addi	a4,a5,%lo(.LC4)
	add	a0,a4,a0
	lbu	a0,0(a0)
	call	putchar
.L38:
	addi	s0,s0,4
	j	.L36
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
.L42:
	lbu	a0,0(s0)
	bnez	a0,.L48
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,36
	jr	ra
.L48:
	li	a5,37
	addi	s1,s0,1
	bne	a0,a5,.L43
	lbu	a0,1(s0)
	li	a5,115
	bne	a0,a5,.L44
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putstr
.L45:
	addi	s0,s1,1
	j	.L42
.L44:
	li	a5,120
	bne	a0,a5,.L46
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putx
	j	.L45
.L46:
	li	a5,100
	bne	a0,a5,.L47
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putd
	j	.L45
.L47:
	call	putchar
	j	.L45
.L43:
	call	putchar
	mv	s1,s0
	j	.L45
	.size	printf, .-printf
	.align	2
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	addi	a2,a2,-1
	li	a5,0
.L52:
	add	a4,a0,a5
	lbu	a3,0(a4)
	add	a4,a1,a5
	lbu	a4,0(a4)
	beq	a5,a2,.L51
	beqz	a3,.L51
	beqz	a4,.L51
	addi	a5,a5,1
	beq	a3,a4,.L52
.L51:
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
.L62:
	add	a4,a0,a5
	lbu	a4,0(a4)
	beqz	a4,.L61
	addi	a5,a5,1
	add	a4,a0,a5
	bnez	a4,.L62
.L61:
	mv	a0,a5
	ret
	.size	strlen, .-strlen
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	li	a5,0
.L69:
	bne	a5,a2,.L70
	ret
.L70:
	add	a4,a1,a5
	lbu	a3,0(a4)
	add	a4,a0,a5
	addi	a5,a5,1
	sb	a3,0(a4)
	j	.L69
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	add	a2,a0,a2
	mv	a5,a0
.L72:
	bne	a5,a2,.L73
	ret
.L73:
	addi	a5,a5,1
	sb	a1,-1(a5)
	j	.L72
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
	bnez	s0,.L75
	lui	a5,%hi(nxt.1626)
	lw	s0,%lo(nxt.1626)(a5)
	beqz	s0,.L76
.L75:
	mv	a5,s0
.L77:
	lbu	a4,0(a5)
	bnez	a4,.L78
	lui	a5,%hi(nxt.1626)
	sw	zero,%lo(nxt.1626)(a5)
	j	.L76
.L78:
	mv	a2,a3
	mv	a0,a5
	mv	a1,s1
	sw	a3,4(sp)
	sw	a5,0(sp)
	call	strncmp
	lw	a5,0(sp)
	lw	a3,4(sp)
	addi	a4,a5,1
	bnez	a0,.L79
	sb	zero,0(a5)
	lui	a5,%hi(nxt.1626)
	sw	a4,%lo(nxt.1626)(a5)
.L76:
	mv	a0,s0
	lw	ra,16(sp)
	lw	s0,12(sp)
	lw	s1,8(sp)
	addi	sp,sp,20
	jr	ra
.L79:
	mv	a5,a4
	j	.L77
	.size	strtok, .-strtok
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	li	a3,0
	li	a5,0
	li	a2,45
.L85:
	bnez	a0,.L87
.L91:
	bnez	a3,.L88
.L84:
	mv	a0,a5
	ret
.L92:
	li	a3,1
	j	.L86
.L87:
	lbu	a4,0(a0)
	beqz	a4,.L91
	beq	a4,a2,.L92
	slli	a1,a5,3
	addi	a4,a4,-48
	add	a4,a4,a1
	slli	a5,a5,1
	add	a5,a4,a5
.L86:
	addi	a0,a0,1
	j	.L85
.L88:
	sub	a5,zero,a5
	j	.L84
	.size	atoi, .-atoi
	.align	2
	.globl	xtoi
	.type	xtoi, @function
xtoi:
	mv	a3,a0
	li	a2,57
	li	a0,0
.L94:
	beqz	a3,.L93
	lbu	a5,0(a3)
	bnez	a5,.L98
.L93:
	ret
.L98:
	slli	a4,a0,4
	bgtu	a5,a2,.L95
	addi	a5,a5,-48
.L102:
	add	a0,a5,a4
	addi	a3,a3,1
	j	.L94
.L95:
	andi	a5,a5,95
	addi	a5,a5,-55
	j	.L102
	.size	xtoi, .-xtoi
	.align	2
	.globl	mac
	.type	mac, @function
mac:
 #APP
# 296 "stdio.c" 1
	.word 0x00c5857F
# 0 "" 2
 #NO_APP
	ret
	.size	mac, .-mac
	.align	2
	.globl	__umulsi3
	.type	__umulsi3, @function
__umulsi3:
	mv	a5,a0
	li	a0,0
	bltu	a5,a1,.L105
.L106:
	bnez	a1,.L111
	ret
.L108:
	andi	a4,a5,1
	beqz	a4,.L107
	add	a0,a0,a1
.L107:
	srli	a5,a5,1
	slli	a1,a1,1
.L105:
	bnez	a5,.L108
	ret
.L111:
	andi	a4,a1,1
	beqz	a4,.L110
	add	a0,a0,a5
.L110:
	slli	a5,a5,1
	srli	a1,a1,1
	j	.L106
	.size	__umulsi3, .-__umulsi3
	.align	2
	.globl	__mulsi3
	.type	__mulsi3, @function
__mulsi3:
	addi	sp,sp,-12
	sw	s1,0(sp)
	sw	ra,8(sp)
	sw	s0,4(sp)
	li	s1,0
	bgez	a0,.L120
	sub	a0,zero,a0
	li	s1,1
.L120:
	li	s0,0
	bgez	a1,.L121
	sub	a1,zero,a1
	li	s0,1
.L121:
	call	__umulsi3
	mv	a5,a0
	beq	s1,s0,.L119
	sub	a5,zero,a0
.L119:
	lw	ra,8(sp)
	lw	s0,4(sp)
	lw	s1,0(sp)
	mv	a0,a5
	addi	sp,sp,12
	jr	ra
	.size	__mulsi3, .-__mulsi3
	.align	2
	.globl	__udiv_umod_si3
	.type	__udiv_umod_si3, @function
__udiv_umod_si3:
	li	a5,1
	bnez	a1,.L130
.L129:
	mv	a0,a1
	ret
.L131:
	slli	a5,a5,1
	slli	a1,a1,1
.L130:
	bgtu	a0,a1,.L131
	mv	a4,a1
	li	a1,0
.L132:
	beqz	a0,.L134
	bnez	a5,.L135
.L134:
	bnez	a2,.L129
	mv	a1,a0
	j	.L129
.L135:
	bltu	a0,a4,.L133
	sub	a0,a0,a4
	add	a1,a1,a5
.L133:
	srli	a5,a5,1
	srli	a4,a4,1
	j	.L132
	.size	__udiv_umod_si3, .-__udiv_umod_si3
	.align	2
	.globl	__udivsi3
	.type	__udivsi3, @function
__udivsi3:
	li	a2,1
	tail	__udiv_umod_si3
	.size	__udivsi3, .-__udivsi3
	.align	2
	.globl	__umodsi3
	.type	__umodsi3, @function
__umodsi3:
	li	a2,0
	tail	__udiv_umod_si3
	.size	__umodsi3, .-__umodsi3
	.align	2
	.globl	__div_mod_si3
	.type	__div_mod_si3, @function
__div_mod_si3:
	beqz	a1,.L158
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	sw	s1,4(sp)
	mv	a5,a2
	li	s0,0
	bgez	a0,.L146
	sub	a0,zero,a0
	li	s0,1
.L146:
	li	s1,0
	bgez	a1,.L147
	sub	a1,zero,a1
	li	s1,1
.L147:
	mv	a2,a5
	sw	a5,0(sp)
	call	__udiv_umod_si3
	lw	a5,0(sp)
	mv	a1,a0
	beqz	a5,.L148
	beq	s0,s1,.L145
	sub	a1,zero,a0
.L145:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	mv	a0,a1
	addi	sp,sp,16
	jr	ra
.L148:
	beqz	s0,.L145
	sub	a1,zero,a0
	j	.L145
.L158:
	mv	a0,a1
	ret
	.size	__div_mod_si3, .-__div_mod_si3
	.align	2
	.globl	__divsi3
	.type	__divsi3, @function
__divsi3:
	li	a2,1
	tail	__div_mod_si3
	.size	__divsi3, .-__divsi3
	.align	2
	.globl	__modsi3
	.type	__modsi3, @function
__modsi3:
	li	a2,0
	tail	__div_mod_si3
	.size	__modsi3, .-__modsi3
	.section	.rodata
	.align	2
	.set	.LANCHOR0,. + 0
.LC0:
	.word	16777216
	.word	65536
	.word	256
	.word	1
	.word	0
.LC1:
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
	.word	0
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC2:
	.string	"(NULL)"
	.zero	1
.LC3:
	.string	"0123456789abcdef"
	.zero	3
.LC4:
	.string	"0123456789"
	.section	.sbss,"aw",@nobits
	.align	2
	.type	nxt.1626, @object
	.size	nxt.1626, 4
nxt.1626:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
