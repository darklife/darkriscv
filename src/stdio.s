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
	addi	sp,sp,-24
	sw	s0,16(sp)
	sw	s1,12(sp)
	sw	ra,20(sp)
	mv	s1,a0
	mv	s0,a0
.L12:
	addi	a4,a1,-1
	beqz	a4,.L16
	sw	a1,4(sp)
	sw	a4,0(sp)
	call	getchar
	li	a3,10
	lw	a4,0(sp)
	lw	a1,4(sp)
	bne	a0,a3,.L13
.L16:
	li	a0,10
	call	putchar
	sb	zero,0(s0)
	bne	s0,s1,.L14
	li	s1,0
.L14:
	lw	ra,20(sp)
	lw	s0,16(sp)
	mv	a0,s1
	lw	s1,12(sp)
	addi	sp,sp,24
	jr	ra
.L13:
	sw	a1,8(sp)
	sw	a4,4(sp)
	li	a3,13
	sw	a0,0(sp)
	beq	a0,a3,.L16
	call	putchar
	lw	a5,0(sp)
	li	a3,8
	lw	a4,4(sp)
	lw	a1,8(sp)
	bne	a5,a3,.L17
	beq	s0,s1,.L18
	sb	zero,-1(s0)
	mv	a4,a1
	addi	s0,s0,-1
.L18:
	mv	a1,a4
	j	.L12
.L17:
	sb	a5,0(s0)
	addi	s0,s0,1
	j	.L18
	.size	gets, .-gets
	.align	2
	.globl	putstr
	.type	putstr, @function
putstr:
	addi	sp,sp,-12
	sw	s0,4(sp)
	sw	ra,8(sp)
	mv	s0,a0
	bnez	a0,.L24
	lui	s0,%hi(.LC2)
	addi	s0,s0,%lo(.LC2)
.L24:
	lbu	a0,0(s0)
	bnez	a0,.L26
	lw	ra,8(sp)
	lw	s0,4(sp)
	addi	sp,sp,12
	jr	ra
.L26:
	addi	s0,s0,1
	call	putchar
	j	.L24
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
	.globl	__udivsi3
	.globl	__umodsi3
	.align	2
	.globl	putdx
	.type	putdx, @function
putdx:
	addi	sp,sp,-84
	sw	a1,0(sp)
	lui	a1,%hi(.LANCHOR0)
	sw	s0,76(sp)
	sw	s1,72(sp)
	li	a2,44
	addi	s1,a1,%lo(.LANCHOR0)
	mv	s0,a0
	addi	a1,a1,%lo(.LANCHOR0)
	addi	a0,sp,28
	sw	ra,80(sp)
	call	memcpy
	li	a2,20
	addi	a1,s1,44
	addi	a0,sp,8
	call	memcpy
	lw	a4,0(sp)
	addi	a5,sp,8
	beqz	a4,.L32
	addi	a5,sp,28
.L32:
	li	s1,24
.L33:
	lw	a1,0(a5)
	bnez	a1,.L37
	lw	ra,80(sp)
	lw	s0,76(sp)
	lw	s1,72(sp)
	addi	sp,sp,84
	jr	ra
.L37:
	li	a4,1
	beq	a1,a4,.L34
	bgtu	a1,s0,.L35
.L34:
	lw	a3,0(sp)
	lui	a4,%hi(.LC3)
	sw	a5,4(sp)
	addi	a4,a4,%lo(.LC3)
	beqz	a3,.L36
	mv	a0,s0
	call	__udivsi3
	li	a1,10
	call	__umodsi3
	lui	a5,%hi(.LC3)
	addi	a4,a5,%lo(.LC3)
	add	a0,a4,a0
	lbu	a0,0(a0)
.L41:
	call	putchar
	lw	a5,4(sp)
.L35:
	addi	s1,s1,-8
	addi	a5,a5,4
	j	.L33
.L36:
	addi	a3,s1,4
	srl	a3,s0,a3
	andi	a3,a3,15
	add	a3,a4,a3
	lbu	a0,0(a3)
	call	putchar
	srl	a0,s0,s1
	lui	a5,%hi(.LC3)
	andi	a0,a0,15
	addi	a4,a5,%lo(.LC3)
	add	a4,a4,a0
	lbu	a0,0(a4)
	j	.L41
	.size	putdx, .-putdx
	.align	2
	.globl	putx
	.type	putx, @function
putx:
	li	a1,0
	tail	putdx
	.size	putx, .-putx
	.align	2
	.globl	putd
	.type	putd, @function
putd:
	li	a1,1
	tail	putdx
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
.L45:
	lbu	a0,0(s0)
	bnez	a0,.L51
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,36
	jr	ra
.L51:
	li	a5,37
	addi	s1,s0,1
	bne	a0,a5,.L46
	lbu	a0,1(s0)
	li	a5,115
	bne	a0,a5,.L47
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putstr
.L48:
	addi	s0,s1,1
	j	.L45
.L47:
	li	a5,120
	bne	a0,a5,.L49
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putx
	j	.L48
.L49:
	li	a5,100
	bne	a0,a5,.L50
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putd
	j	.L48
.L50:
	call	putchar
	j	.L48
.L46:
	call	putchar
	mv	s1,s0
	j	.L48
	.size	printf, .-printf
	.align	2
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	addi	a2,a2,-1
	li	a5,0
.L55:
	add	a4,a0,a5
	lbu	a3,0(a4)
	add	a4,a1,a5
	lbu	a4,0(a4)
	beq	a5,a2,.L54
	beqz	a3,.L54
	beqz	a4,.L54
	addi	a5,a5,1
	beq	a3,a4,.L55
.L54:
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
.L65:
	add	a4,a0,a5
	lbu	a4,0(a4)
	beqz	a4,.L64
	addi	a5,a5,1
	add	a4,a0,a5
	bnez	a4,.L65
.L64:
	mv	a0,a5
	ret
	.size	strlen, .-strlen
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	li	a5,0
.L72:
	bne	a5,a2,.L73
	ret
.L73:
	add	a4,a1,a5
	lbu	a3,0(a4)
	add	a4,a0,a5
	addi	a5,a5,1
	sb	a3,0(a4)
	j	.L72
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	add	a2,a0,a2
	mv	a5,a0
.L75:
	bne	a5,a2,.L76
	ret
.L76:
	addi	a5,a5,1
	sb	a1,-1(a5)
	j	.L75
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
	bnez	s0,.L78
	lui	a5,%hi(nxt.1628)
	lw	s0,%lo(nxt.1628)(a5)
	beqz	s0,.L79
.L78:
	mv	a5,s0
.L80:
	lbu	a4,0(a5)
	bnez	a4,.L81
	lui	a5,%hi(nxt.1628)
	sw	zero,%lo(nxt.1628)(a5)
	j	.L79
.L81:
	mv	a2,a3
	mv	a0,a5
	mv	a1,s1
	sw	a3,4(sp)
	sw	a5,0(sp)
	call	strncmp
	lw	a5,0(sp)
	lw	a3,4(sp)
	addi	a4,a5,1
	bnez	a0,.L82
	sb	zero,0(a5)
	lui	a5,%hi(nxt.1628)
	sw	a4,%lo(nxt.1628)(a5)
.L79:
	mv	a0,s0
	lw	ra,16(sp)
	lw	s0,12(sp)
	lw	s1,8(sp)
	addi	sp,sp,20
	jr	ra
.L82:
	mv	a5,a4
	j	.L80
	.size	strtok, .-strtok
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	li	a3,0
	li	a5,0
	li	a2,45
.L88:
	bnez	a0,.L90
.L94:
	bnez	a3,.L91
.L87:
	mv	a0,a5
	ret
.L95:
	li	a3,1
	j	.L89
.L90:
	lbu	a4,0(a0)
	beqz	a4,.L94
	beq	a4,a2,.L95
	slli	a1,a5,3
	addi	a4,a4,-48
	add	a4,a4,a1
	slli	a5,a5,1
	add	a5,a4,a5
.L89:
	addi	a0,a0,1
	j	.L88
.L91:
	sub	a5,zero,a5
	j	.L87
	.size	atoi, .-atoi
	.align	2
	.globl	xtoi
	.type	xtoi, @function
xtoi:
	mv	a3,a0
	li	a2,57
	li	a0,0
.L97:
	beqz	a3,.L96
	lbu	a5,0(a3)
	bnez	a5,.L101
.L96:
	ret
.L101:
	slli	a4,a0,4
	bgtu	a5,a2,.L98
	addi	a5,a5,-48
.L105:
	add	a0,a5,a4
	addi	a3,a3,1
	j	.L97
.L98:
	andi	a5,a5,95
	addi	a5,a5,-55
	j	.L105
	.size	xtoi, .-xtoi
	.align	2
	.globl	mac
	.type	mac, @function
mac:
 #APP
# 271 "stdio.c" 1
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
	bgeu	a0,a1,.L108
	mv	a5,a1
	mv	a1,a0
.L108:
	li	a0,0
.L109:
	bnez	a1,.L111
	ret
.L111:
	andi	a4,a1,1
	beqz	a4,.L110
	add	a0,a0,a5
.L110:
	slli	a5,a5,1
	srli	a1,a1,1
	j	.L109
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
	bgez	a0,.L116
	sub	a0,zero,a0
	li	s1,1
.L116:
	li	s0,0
	bgez	a1,.L117
	sub	a1,zero,a1
	li	s0,1
.L117:
	call	__umulsi3
	mv	a5,a0
	beq	s1,s0,.L115
	sub	a5,zero,a0
.L115:
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
	bnez	a1,.L126
.L125:
	mv	a0,a1
	ret
.L127:
	slli	a5,a5,1
	slli	a1,a1,1
.L126:
	bgtu	a0,a1,.L127
	mv	a4,a1
	li	a1,0
.L128:
	beqz	a0,.L130
	bnez	a5,.L131
.L130:
	bnez	a2,.L125
	mv	a1,a0
	j	.L125
.L131:
	bltu	a0,a4,.L129
	sub	a0,a0,a4
	add	a1,a1,a5
.L129:
	srli	a5,a5,1
	srli	a4,a4,1
	j	.L128
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
	beqz	a1,.L154
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	sw	s1,4(sp)
	mv	a5,a2
	li	s0,0
	bgez	a0,.L142
	sub	a0,zero,a0
	li	s0,1
.L142:
	li	s1,0
	bgez	a1,.L143
	sub	a1,zero,a1
	li	s1,1
.L143:
	mv	a2,a5
	sw	a5,0(sp)
	call	__udiv_umod_si3
	lw	a5,0(sp)
	mv	a1,a0
	beqz	a5,.L144
	beq	s0,s1,.L141
	sub	a1,zero,a0
.L141:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	mv	a0,a1
	addi	sp,sp,16
	jr	ra
.L144:
	beqz	s0,.L141
	sub	a1,zero,a0
	j	.L141
.L154:
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
	.align	2
	.globl	usleep
	.type	usleep, @function
usleep:
	lui	a5,%hi(io)
	li	a3,-1
	addi	a5,a5,%lo(io)
	li	a2,-128
.L160:
	addi	a0,a0,-1
	bne	a0,a3,.L162
	ret
.L162:
	sb	a2,3(a5)
.L161:
	lbu	a4,3(a5)
	andi	a4,a4,0xff
	beqz	a4,.L161
	j	.L160
	.size	usleep, .-usleep
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
	.word	0
.LC1:
	.word	16777216
	.word	65536
	.word	256
	.word	1
	.word	0
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC2:
	.string	"(NULL)"
	.zero	1
.LC3:
	.string	"0123456789abcdef"
	.section	.sbss,"aw",@nobits
	.align	2
	.type	nxt.1628, @object
	.size	nxt.1628, 4
nxt.1628:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
