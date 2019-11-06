	.file	"stdio.c"
	.option nopic
	.text
	.align	2
	.globl	getchar
	.type	getchar, @function
getchar:
.L2:
	.LA0: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA0)
	lbu	a5,4(a5)
	andi	a5,a5,2
	beqz	a5,.L2
	.LA1: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA1)
	lbu	a0,5(a5)
	ret
	.size	getchar, .-getchar
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	li	a5,10
	bne	a0,a5,.L8
.L7:
	.LA2: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA2)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L7
	.LA3: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA3)
	li	a4,13
	sb	a4,5(a5)
.L8:
	.LA4: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA4)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L8
	.LA5: auipc	a5,%pcrel_hi(io)
	andi	a4,a0,0xff
	addi	a5,a5,%pcrel_lo(.LA5)
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
.L25:
	.LA6: auipc	a5,%pcrel_hi(.LC2)
	addi	a5,a5,%pcrel_lo(.LA6)
	bnez	s0,.L24
	mv	s0,a5
	j	.L25
.L26:
	addi	s0,s0,1
	call	putchar
.L24:
	lbu	a0,0(s0)
	bnez	a0,.L26
	lw	ra,8(sp)
	lw	s0,4(sp)
	addi	sp,sp,12
	jr	ra
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
	addi	sp,sp,-88
	sw	s1,76(sp)
	.LA7: auipc	s1,%pcrel_hi(.LANCHOR0)
	addi	s1,s1,%pcrel_lo(.LA7)
	sw	s0,80(sp)
	sw	a1,0(sp)
	li	a2,44
	mv	a1,s1
	mv	s0,a0
	addi	a0,sp,32
	sw	ra,84(sp)
	call	memcpy
	li	a2,20
	addi	a1,s1,44
	addi	a0,sp,12
	call	memcpy
	lw	a4,0(sp)
	addi	a5,sp,12
	beqz	a4,.L32
	addi	a5,sp,32
.L32:
	li	s1,24
.L33:
	lw	a1,0(a5)
	bnez	a1,.L37
	lw	ra,84(sp)
	lw	s0,80(sp)
	lw	s1,76(sp)
	addi	sp,sp,88
	jr	ra
.L37:
	li	a4,1
	beq	a1,a4,.L34
	bgtu	a1,s0,.L35
.L34:
	lw	a3,0(sp)
	.LA12: auipc	a4,%pcrel_hi(.LC3)
	addi	a4,a4,%pcrel_lo(.LA12)
	beqz	a3,.L36
	mv	a0,s0
	sw	a5,4(sp)
	sw	a4,8(sp)
	call	__udivsi3
	li	a1,10
	call	__umodsi3
	lw	a4,8(sp)
	add	a0,a0,a4
	lbu	a0,0(a0)
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
	add	a3,a3,a4
	lbu	a0,0(a3)
	sw	a5,8(sp)
	sw	a4,4(sp)
	call	putchar
	lw	a4,4(sp)
	srl	a0,s0,s1
	andi	a0,a0,15
	add	a4,a0,a4
	lbu	a0,0(a4)
	call	putchar
	lw	a5,8(sp)
	j	.L35
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
.L44:
	lbu	a0,0(s0)
	bnez	a0,.L50
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,36
	jr	ra
.L50:
	li	a5,37
	addi	s1,s0,1
	bne	a0,a5,.L45
	lbu	a0,1(s0)
	li	a5,115
	bne	a0,a5,.L46
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putstr
.L47:
	addi	s0,s1,1
	j	.L44
.L46:
	li	a5,120
	bne	a0,a5,.L48
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putx
	j	.L47
.L48:
	li	a5,100
	bne	a0,a5,.L49
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a4,a5,4
	sw	a4,0(sp)
	call	putd
	j	.L47
.L49:
	call	putchar
	j	.L47
.L45:
	call	putchar
	mv	s1,s0
	j	.L47
	.size	printf, .-printf
	.align	2
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	addi	a2,a2,-1
	li	a5,0
.L54:
	add	a4,a0,a5
	lbu	a3,0(a4)
	add	a4,a1,a5
	lbu	a4,0(a4)
	beq	a5,a2,.L53
	beqz	a3,.L53
	beqz	a4,.L53
	addi	a5,a5,1
	beq	a3,a4,.L54
.L53:
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
.L64:
	add	a4,a0,a5
	lbu	a4,0(a4)
	beqz	a4,.L63
	addi	a5,a5,1
	add	a4,a0,a5
	bnez	a4,.L64
.L63:
	mv	a0,a5
	ret
	.size	strlen, .-strlen
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	li	a5,0
.L71:
	bne	a5,a2,.L72
	ret
.L72:
	add	a4,a1,a5
	lbu	a3,0(a4)
	add	a4,a0,a5
	addi	a5,a5,1
	sb	a3,0(a4)
	j	.L71
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	add	a2,a0,a2
	mv	a5,a0
.L74:
	bne	a5,a2,.L75
	ret
.L75:
	addi	a5,a5,1
	sb	a1,-1(a5)
	j	.L74
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
	bnez	s0,.L77
	.LA13: auipc	a5,%pcrel_hi(nxt.1626)
	lw	s0,%pcrel_lo(.LA13)(a5)
	beqz	s0,.L78
.L77:
	mv	a5,s0
.L79:
	lbu	a4,0(a5)
	bnez	a4,.L80
	.LA15: auipc	a5,%pcrel_hi(nxt.1626)
	sw	zero,%pcrel_lo(.LA15)(a5)
	j	.L78
.L80:
	mv	a2,a3
	mv	a0,a5
	mv	a1,s1
	sw	a3,4(sp)
	sw	a5,0(sp)
	call	strncmp
	lw	a5,0(sp)
	lw	a3,4(sp)
	addi	a4,a5,1
	bnez	a0,.L81
	sb	zero,0(a5)
	.LA14: auipc	a5,%pcrel_hi(nxt.1626)
	sw	a4,%pcrel_lo(.LA14)(a5)
.L78:
	mv	a0,s0
	lw	ra,16(sp)
	lw	s0,12(sp)
	lw	s1,8(sp)
	addi	sp,sp,20
	jr	ra
.L81:
	mv	a5,a4
	j	.L79
	.size	strtok, .-strtok
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	li	a3,0
	li	a5,0
	li	a2,45
.L87:
	bnez	a0,.L89
.L93:
	bnez	a3,.L90
.L86:
	mv	a0,a5
	ret
.L94:
	li	a3,1
	j	.L88
.L89:
	lbu	a4,0(a0)
	beqz	a4,.L93
	beq	a4,a2,.L94
	slli	a1,a5,3
	addi	a4,a4,-48
	add	a4,a4,a1
	slli	a5,a5,1
	add	a5,a4,a5
.L88:
	addi	a0,a0,1
	j	.L87
.L90:
	sub	a5,zero,a5
	j	.L86
	.size	atoi, .-atoi
	.align	2
	.globl	xtoi
	.type	xtoi, @function
xtoi:
	mv	a3,a0
	li	a2,57
	li	a0,0
.L96:
	beqz	a3,.L95
	lbu	a5,0(a3)
	bnez	a5,.L100
.L95:
	ret
.L100:
	slli	a4,a0,4
	bgtu	a5,a2,.L97
	addi	a5,a5,-48
.L104:
	add	a0,a5,a4
	addi	a3,a3,1
	j	.L96
.L97:
	andi	a5,a5,95
	addi	a5,a5,-55
	j	.L104
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
	bgeu	a0,a1,.L107
	mv	a5,a1
	mv	a1,a0
.L107:
	li	a0,0
.L108:
	bnez	a1,.L110
	ret
.L110:
	andi	a4,a1,1
	beqz	a4,.L109
	add	a0,a0,a5
.L109:
	slli	a5,a5,1
	srli	a1,a1,1
	j	.L108
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
	bgez	a0,.L115
	sub	a0,zero,a0
	li	s1,1
.L115:
	li	s0,0
	bgez	a1,.L116
	sub	a1,zero,a1
	li	s0,1
.L116:
	call	__umulsi3
	mv	a5,a0
	beq	s1,s0,.L114
	sub	a5,zero,a0
.L114:
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
	bnez	a1,.L125
.L124:
	mv	a0,a1
	ret
.L126:
	slli	a5,a5,1
	slli	a1,a1,1
.L125:
	bgtu	a0,a1,.L126
	mv	a4,a1
	li	a1,0
.L127:
	beqz	a0,.L129
	bnez	a5,.L130
.L129:
	bnez	a2,.L124
	mv	a1,a0
	j	.L124
.L130:
	bltu	a0,a4,.L128
	sub	a0,a0,a4
	add	a1,a1,a5
.L128:
	srli	a5,a5,1
	srli	a4,a4,1
	j	.L127
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
	beqz	a1,.L153
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	sw	s1,4(sp)
	mv	a5,a2
	li	s0,0
	bgez	a0,.L141
	sub	a0,zero,a0
	li	s0,1
.L141:
	li	s1,0
	bgez	a1,.L142
	sub	a1,zero,a1
	li	s1,1
.L142:
	mv	a2,a5
	sw	a5,0(sp)
	call	__udiv_umod_si3
	lw	a5,0(sp)
	mv	a1,a0
	beqz	a5,.L143
	beq	s0,s1,.L140
	sub	a1,zero,a0
.L140:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	mv	a0,a1
	addi	sp,sp,16
	jr	ra
.L143:
	beqz	s0,.L140
	sub	a1,zero,a0
	j	.L140
.L153:
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
	.type	nxt.1626, @object
	.size	nxt.1626, 4
nxt.1626:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
