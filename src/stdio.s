	.file	"stdio.c"
	.option nopic
	.text
	.align	2
	.type	__udiv_umod_si3.part.0, @function
__udiv_umod_si3.part.0:
	mv	a4,a0
	li	a5,1
	bleu	a0,a1,.L3
.L2:
	bltz	a1,.L3
	slli	a1,a1,1
	slli	a5,a5,1
	bltu	a1,a4,.L2
.L3:
	li	a0,0
	beqz	a4,.L19
.L5:
	beqz	a5,.L6
	bgtu	a1,a4,.L7
	sub	a4,a4,a1
	add	a0,a0,a5
	srli	a1,a1,1
	srli	a5,a5,1
	bnez	a4,.L5
.L6:
	bnez	a2,.L1
	mv	a0,a4
	ret
.L7:
	srli	a5,a5,1
	srli	a1,a1,1
	j	.L5
.L1:
	ret
.L19:
	mv	a0,a4
	j	.L6
	.size	__udiv_umod_si3.part.0, .-__udiv_umod_si3.part.0
	.align	2
	.type	__div_mod_si3.part.1, @function
__div_mod_si3.part.1:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	ra,12(sp)
	mv	s1,a2
	li	s0,0
	bgez	a0,.L21
	sub	a0,zero,a0
	li	s0,1
.L21:
	sw	zero,0(sp)
	bgez	a1,.L22
	li	a5,1
	sub	a1,zero,a1
	sw	a5,0(sp)
.L22:
	mv	a2,s1
	call	__udiv_umod_si3.part.0
	beqz	s1,.L23
	lw	a5,0(sp)
	beq	s0,a5,.L20
.L32:
	sub	a0,zero,a0
.L20:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L23:
	bnez	s0,.L32
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	__div_mod_si3.part.1, .-__div_mod_si3.part.1
	.align	2
	.globl	getchar
	.type	getchar, @function
getchar:
.L35:
	.LA0: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA0)
	lbu	a5,4(a5)
	andi	a5,a5,2
	beqz	a5,.L35
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
	beq	a0,a5,.L40
.L41:
	.LA4: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA4)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L41
	.LA5: auipc	a5,%pcrel_hi(io)
	andi	a4,a0,0xff
	addi	a5,a5,%pcrel_lo(.LA5)
	sb	a4,5(a5)
	mv	a0,a4
	ret
.L40:
	.LA2: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA2)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L40
	.LA3: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA3)
	li	a4,13
	sb	a4,5(a5)
	j	.L41
	.size	putchar, .-putchar
	.align	2
	.globl	gets
	.type	gets, @function
gets:
	addi	a1,a1,-1
	mv	a4,a0
	beqz	a1,.L51
	li	a3,10
	li	a2,13
	li	t1,8
.L46:
	.LA6: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA6)
	lbu	a5,4(a5)
	andi	a5,a5,2
	beqz	a5,.L46
	.LA7: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA7)
	lbu	a5,5(a5)
	andi	t0,a5,0xff
	beq	a3,a5,.L51
	beq	t0,a2,.L51
.L47:
	.LA8: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA8)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L47
	.LA9: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA9)
	sb	t0,5(a5)
	beq	t0,t1,.L62
	sb	t0,0(a4)
	addi	a1,a1,-1
	addi	a4,a4,1
	bnez	a1,.L46
.L51:
	.LA10: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA10)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L51
	.LA11: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA11)
	li	a3,13
	sb	a3,5(a5)
.L52:
	.LA12: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA12)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L52
	sub	a5,a0,a4
	.LA13: auipc	a3,%pcrel_hi(io)
	addi	a3,a3,%pcrel_lo(.LA13)
	li	a2,10
	snez	a5,a5
	sb	a2,5(a3)
	sub	a5,zero,a5
	sb	zero,0(a4)
	and	a0,a0,a5
	ret
.L62:
	beq	a0,a4,.L55
	sb	zero,-1(a4)
	addi	a4,a4,-1
	bnez	a1,.L46
	j	.L51
.L55:
	addi	a1,a1,-1
	bnez	a1,.L46
	j	.L51
	.size	gets, .-gets
	.align	2
	.globl	putstr
	.type	putstr, @function
putstr:
	.LA19: auipc	a5,%pcrel_hi(.LC2)
	addi	a5,a5,%pcrel_lo(.LA19)
	bnez	a0,.L77
	mv	a0,a5
.L77:
	lbu	a4,0(a0)
	beqz	a4,.L63
	li	a3,10
	li	a2,13
.L69:
	addi	a0,a0,1
	beq	a4,a3,.L67
.L68:
	.LA17: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA17)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L68
	.LA18: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA18)
	sb	a4,5(a5)
	lbu	a4,0(a0)
	bnez	a4,.L69
.L63:
	ret
.L67:
	.LA15: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA15)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L67
	.LA16: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA16)
	sb	a2,5(a5)
	j	.L68
	.size	putstr, .-putstr
	.align	2
	.globl	puts
	.type	puts, @function
puts:
	addi	sp,sp,-12
	sw	ra,8(sp)
	call	putstr
.L79:
	.LA20: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA20)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L79
	.LA21: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA21)
	li	a4,13
	sb	a4,5(a5)
.L80:
	.LA22: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA22)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L80
	.LA23: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA23)
	li	a4,10
	sb	a4,5(a5)
	lw	ra,8(sp)
	li	a0,10
	addi	sp,sp,12
	jr	ra
	.size	puts, .-puts
	.globl	__udivsi3
	.globl	__umodsi3
	.align	2
	.globl	putdx
	.type	putdx, @function
putdx:
	.LA24: auipc	a5,%pcrel_hi(.LANCHOR0)
	addi	a5,a5,%pcrel_lo(.LA24)
	lw	a2,32(a5)
	addi	sp,sp,-88
	lw	a4,0(a5)
	sw	a2,64(sp)
	lw	a2,36(a5)
	sw	a4,32(sp)
	lw	a4,4(a5)
	sw	a2,68(sp)
	lw	a2,40(a5)
	lw	t2,8(a5)
	lw	t0,12(a5)
	sw	a2,72(sp)
	lw	a2,44(a5)
	lw	t1,16(a5)
	sw	s0,80(sp)
	sw	a2,12(sp)
	lw	a2,48(a5)
	lw	s0,20(a5)
	sw	a4,36(sp)
	sw	a2,16(sp)
	lw	a2,52(a5)
	lw	a4,28(a5)
	lw	a3,24(a5)
	sw	a2,20(sp)
	lw	a2,56(a5)
	lw	a5,60(a5)
	sw	s1,76(sp)
	sw	a2,24(sp)
	sw	ra,84(sp)
	sw	t2,40(sp)
	sw	t0,44(sp)
	sw	t1,48(sp)
	sw	s0,52(sp)
	sw	a3,56(sp)
	sw	a4,60(sp)
	sw	a5,28(sp)
	mv	a2,a1
	addi	s1,sp,12
	beqz	a1,.L85
	addi	s1,sp,32
.L85:
	lw	a1,0(s1)
	beqz	a1,.L84
	mv	a3,a0
	addi	s1,s1,4
	li	a4,24
	li	t0,1
	li	s0,10
.L99:
	beq	a1,t0,.L87
	bgtu	a1,a3,.L88
.L87:
	beqz	a2,.L89
	mv	a0,a3
	sw	a2,8(sp)
	sw	a4,4(sp)
	sw	a3,0(sp)
	call	__udivsi3
	li	a1,10
	call	__umodsi3
	.LA26: auipc	a5,%pcrel_hi(.LC3)
	addi	a5,a5,%pcrel_lo(.LA26)
	add	a0,a0,a5
	lbu	a1,0(a0)
	lw	a3,0(sp)
	li	t0,1
	lw	a4,4(sp)
	lw	a2,8(sp)
	beq	a1,s0,.L91
.L92:
	.LA29: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA29)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L92
	.LA30: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA30)
	sb	a1,5(a5)
.L88:
	addi	s1,s1,4
	lw	a1,-4(s1)
	addi	a4,a4,-8
	bnez	a1,.L99
.L84:
	lw	ra,84(sp)
	lw	s0,80(sp)
	lw	s1,76(sp)
	addi	sp,sp,88
	jr	ra
.L91:
	.LA27: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA27)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L91
	.LA28: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA28)
	li	a0,13
	sb	a0,5(a5)
	j	.L92
.L89:
	addi	a5,a4,4
	srl	a5,a3,a5
	.LA31: auipc	a1,%pcrel_hi(.LC3)
	andi	a5,a5,15
	addi	a1,a1,%pcrel_lo(.LA31)
	add	a5,a5,a1
	lbu	a0,0(a5)
	beq	a0,s0,.L94
.L95:
	.LA34: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA34)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L95
	srl	a5,a3,a4
	andi	a5,a5,15
	add	a1,a5,a1
	lbu	a1,0(a1)
	.LA35: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA35)
	sb	a0,5(a5)
	beq	a1,s0,.L97
.L98:
	.LA39: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA39)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L98
	.LA40: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA40)
	sb	a1,5(a5)
	addi	s1,s1,4
	lw	a1,-4(s1)
	addi	a4,a4,-8
	bnez	a1,.L99
	j	.L84
.L94:
	.LA32: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA32)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L94
	.LA33: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA33)
	li	t1,13
	sb	t1,5(a5)
	j	.L95
.L97:
	.LA37: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA37)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L97
	.LA38: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA38)
	li	a0,13
	sb	a0,5(a5)
	j	.L98
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
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	a1,16(sp)
	sw	a2,20(sp)
	sw	a3,24(sp)
	sw	a4,28(sp)
	lbu	a3,0(a0)
	addi	a5,sp,16
	sw	a5,0(sp)
	beqz	a3,.L135
	mv	s0,a0
	li	a4,37
.L116:
	addi	s1,s0,1
	bne	a3,a4,.L117
	lbu	a3,1(s0)
	li	a5,115
	addi	s0,s0,2
	beq	a3,a5,.L138
	li	a5,120
	beq	a3,a5,.L139
	li	a5,100
	beq	a3,a5,.L140
	li	a5,10
	beq	a3,a5,.L123
.L124:
	.LA43: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA43)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L124
	.LA44: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA44)
	sb	a3,5(a5)
.L119:
	lbu	a3,1(s1)
	bnez	a3,.L116
.L135:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	li	a0,0
	addi	sp,sp,36
	jr	ra
.L123:
	.LA41: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA41)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L123
	.LA42: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA42)
	li	a2,13
	sb	a2,5(a5)
	j	.L124
.L117:
	li	a5,10
	beq	a3,a5,.L126
.L127:
	.LA47: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA47)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L127
	.LA48: auipc	a5,%pcrel_hi(io)
	mv	a2,s1
	addi	a5,a5,%pcrel_lo(.LA48)
	mv	s1,s0
	sb	a3,5(a5)
	mv	s0,a2
	j	.L119
.L126:
	.LA45: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA45)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L126
	.LA46: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA46)
	li	a2,13
	sb	a2,5(a5)
	j	.L127
.L140:
	lw	a5,0(sp)
	li	a1,1
.L137:
	lw	a0,0(a5)
	addi	a5,a5,4
	sw	a5,0(sp)
	call	putdx
	li	a4,37
	j	.L119
.L138:
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a5,a5,4
	sw	a5,0(sp)
	call	putstr
	li	a4,37
	j	.L119
.L139:
	lw	a5,0(sp)
	li	a1,0
	j	.L137
	.size	printf, .-printf
	.align	2
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	li	a5,1
	lbu	a3,0(a0)
	lbu	t1,0(a1)
	mv	a4,a0
	bne	a2,a5,.L142
	j	.L143
.L156:
	beqz	t1,.L143
	bne	a3,t1,.L143
	lbu	a3,0(a4)
	lbu	t1,0(a1)
	beqz	a5,.L143
.L142:
	addi	a4,a4,1
	not	a5,a4
	add	a5,a5,a2
	addi	a1,a1,1
	add	a5,a0,a5
	bnez	a3,.L156
.L143:
	sub	a0,a3,t1
	ret
	.size	strncmp, .-strncmp
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
	lbu	a5,0(a0)
	lbu	a4,0(a1)
	bnez	a5,.L158
	j	.L159
.L164:
	bne	a5,a4,.L159
	lbu	a5,0(a0)
	lbu	a4,0(a1)
	beqz	a5,.L162
.L158:
	addi	a0,a0,1
	addi	a1,a1,1
	bnez	a4,.L164
.L159:
	sub	a0,a5,a4
	ret
.L162:
	li	a5,0
	sub	a0,a5,a4
	ret
	.size	strcmp, .-strcmp
	.align	2
	.globl	strlen
	.type	strlen, @function
strlen:
	mv	a5,a0
	li	a0,0
	bnez	a5,.L166
	j	.L171
.L168:
	addi	a0,a0,1
.L166:
	addi	a5,a5,1
	lbu	a4,-1(a5)
	bnez	a4,.L168
	ret
.L171:
	ret
	.size	strlen, .-strlen
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	beqz	a2,.L173
	add	a2,a0,a2
	mv	a5,a0
.L174:
	addi	a1,a1,1
	lbu	a4,-1(a1)
	addi	a5,a5,1
	sb	a4,-1(a5)
	bne	a2,a5,.L174
.L173:
	ret
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	andi	a1,a1,0xff
	add	a4,a0,a2
	mv	a5,a0
	beqz	a2,.L185
.L181:
	addi	a5,a5,1
	sb	a1,-1(a5)
	bne	a4,a5,.L181
.L185:
	ret
	.size	memset, .-memset
	.align	2
	.globl	strtok
	.type	strtok, @function
strtok:
	addi	sp,sp,-12
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	a0,0(sp)
	mv	t2,a1
	beqz	a1,.L188
	mv	a5,a1
	li	t2,0
	j	.L187
.L189:
	addi	t2,t2,1
.L187:
	addi	a5,a5,1
	lbu	a4,-1(a5)
	bnez	a4,.L189
.L188:
	lw	a5,0(sp)
	beqz	a5,.L225
.L190:
	lw	t0,0(sp)
	lbu	a3,0(t0)
	beqz	a3,.L192
	lbu	s0,0(a1)
	add	t1,t0,t2
	li	s1,1
.L193:
	mv	a0,a1
	mv	a5,t0
	mv	a2,s0
	beq	t2,s1,.L194
.L197:
	addi	a5,a5,1
	not	a4,a5
	addi	a0,a0,1
	add	a4,a4,t1
	beqz	a2,.L195
	bne	a2,a3,.L195
	lbu	a3,0(a5)
	lbu	a2,0(a0)
	beqz	a4,.L194
	bnez	a3,.L197
.L194:
	beq	a3,a2,.L226
.L195:
	addi	t0,t0,1
	lbu	a3,0(t0)
	addi	t1,t1,1
	bnez	a3,.L193
.L192:
	lw	a0,0(sp)
	.LA51: auipc	a5,%pcrel_hi(nxt.1117)
	sw	zero,%pcrel_lo(.LA51)(a5)
.L186:
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,12
	jr	ra
.L226:
	sb	zero,0(t0)
	lw	s0,8(sp)
	addi	a4,t0,1
	.LA50: auipc	a5,%pcrel_hi(nxt.1117)
	sw	a4,%pcrel_lo(.LA50)(a5)
	lw	a0,0(sp)
	lw	s1,4(sp)
	addi	sp,sp,12
	jr	ra
.L225:
	.LA49: auipc	a5,%pcrel_hi(nxt.1117)
	lw	a5,%pcrel_lo(.LA49)(a5)
	sw	a5,0(sp)
	bnez	a5,.L190
	li	a0,0
	j	.L186
	.size	strtok, .-strtok
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	mv	a5,a0
	li	t0,0
	li	a0,0
	li	t1,45
	bnez	a5,.L228
	j	.L242
.L243:
	addi	a5,a5,1
	add	a0,a4,a1
	beqz	a5,.L231
.L228:
	lbu	a3,0(a5)
	slli	a4,a0,3
	slli	a1,a0,1
	addi	a2,a3,-48
	add	a4,a2,a4
	beqz	a3,.L231
	bne	a3,t1,.L243
	addi	a5,a5,1
	li	t0,1
	bnez	a5,.L228
.L231:
	beqz	t0,.L227
	sub	a0,zero,a0
.L227:
	ret
.L242:
	ret
	.size	atoi, .-atoi
	.align	2
	.globl	xtoi
	.type	xtoi, @function
xtoi:
	mv	a4,a0
	li	t1,57
	li	a0,0
	bnez	a4,.L245
	j	.L255
.L249:
	add	a0,a1,a2
	bleu	a5,t1,.L248
	add	a0,a3,a2
.L248:
	addi	a4,a4,1
	beqz	a4,.L244
.L245:
	lbu	a5,0(a4)
	slli	a2,a0,4
	andi	a3,a5,95
	addi	a1,a5,-48
	addi	a3,a3,-55
	bnez	a5,.L249
.L244:
	ret
.L255:
	ret
	.size	xtoi, .-xtoi
	.align	2
	.globl	mac
	.type	mac, @function
mac:
 #APP
# 270 "stdio.c" 1
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
	bgeu	a0,a1,.L258
	mv	a5,a1
	mv	a1,a0
.L258:
	li	a0,0
	beqz	a1,.L262
.L261:
	andi	a4,a1,1
	srli	a1,a1,1
	beqz	a4,.L260
	add	a0,a0,a5
.L260:
	slli	a5,a5,1
	bnez	a1,.L261
	ret
.L262:
	ret
	.size	__umulsi3, .-__umulsi3
	.align	2
	.globl	__mulsi3
	.type	__mulsi3, @function
__mulsi3:
	li	a2,0
	bgez	a0,.L268
	sub	a0,zero,a0
	li	a2,1
.L268:
	mv	a5,a0
	bltz	a1,.L285
	mv	a4,a1
	li	t1,0
	bgtu	a1,a0,.L270
	mv	a4,a0
	li	t1,0
	mv	a5,a1
.L270:
	beqz	a5,.L280
.L271:
	li	a0,0
.L274:
	andi	a3,a5,1
	srli	a5,a5,1
	beqz	a3,.L273
	add	a0,a0,a4
.L273:
	slli	a4,a4,1
	bnez	a5,.L274
.L272:
	beq	a2,t1,.L267
	sub	a0,zero,a0
.L267:
	ret
.L285:
	sub	a4,zero,a1
	bgtu	a4,a0,.L278
	mv	a5,a4
	li	t1,1
	mv	a4,a0
	j	.L271
.L278:
	li	t1,1
	bnez	a5,.L271
.L280:
	li	a0,0
	j	.L272
	.size	__mulsi3, .-__mulsi3
	.align	2
	.globl	__udiv_umod_si3
	.type	__udiv_umod_si3, @function
__udiv_umod_si3:
	beqz	a1,.L287
	tail	__udiv_umod_si3.part.0
.L287:
	li	a0,0
	ret
	.size	__udiv_umod_si3, .-__udiv_umod_si3
	.align	2
	.globl	__udivsi3
	.type	__udivsi3, @function
__udivsi3:
	beqz	a1,.L289
	li	a2,1
	tail	__udiv_umod_si3.part.0
.L289:
	li	a0,0
	ret
	.size	__udivsi3, .-__udivsi3
	.align	2
	.globl	__umodsi3
	.type	__umodsi3, @function
__umodsi3:
	beqz	a1,.L291
	li	a2,0
	tail	__udiv_umod_si3.part.0
.L291:
	li	a0,0
	ret
	.size	__umodsi3, .-__umodsi3
	.align	2
	.globl	__div_mod_si3
	.type	__div_mod_si3, @function
__div_mod_si3:
	beqz	a1,.L293
	tail	__div_mod_si3.part.1
.L293:
	li	a0,0
	ret
	.size	__div_mod_si3, .-__div_mod_si3
	.align	2
	.globl	__divsi3
	.type	__divsi3, @function
__divsi3:
	beqz	a1,.L295
	li	a2,1
	tail	__div_mod_si3.part.1
.L295:
	li	a0,0
	ret
	.size	__divsi3, .-__divsi3
	.align	2
	.globl	__modsi3
	.type	__modsi3, @function
__modsi3:
	beqz	a1,.L297
	li	a2,0
	tail	__div_mod_si3.part.1
.L297:
	li	a0,0
	ret
	.size	__modsi3, .-__modsi3
	.align	2
	.globl	usleep
	.type	usleep, @function
usleep:
	addi	a4,a0,-1
	beqz	a0,.L298
	li	a2,-128
	li	a3,-1
.L301:
	.LA52: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA52)
	sb	a2,3(a5)
.L300:
	.LA53: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA53)
	lbu	a5,3(a5)
	andi	a5,a5,0xff
	beqz	a5,.L300
	addi	a4,a4,-1
	bne	a4,a3,.L301
.L298:
	ret
	.size	usleep, .-usleep
	.align	2
	.globl	set_mtvec
	.type	set_mtvec, @function
set_mtvec:
 #APP
# 362 "stdio.c" 1
	csrw mtvec,a0
# 0 "" 2
 #NO_APP
	ret
	.size	set_mtvec, .-set_mtvec
	.align	2
	.globl	get_mtvec
	.type	get_mtvec, @function
get_mtvec:
 #APP
# 369 "stdio.c" 1
	csrr a0,mtvec
# 0 "" 2
 #NO_APP
	ret
	.size	get_mtvec, .-get_mtvec
	.align	2
	.globl	set_mepc
	.type	set_mepc, @function
set_mepc:
 #APP
# 377 "stdio.c" 1
	csrw mepc,a0
# 0 "" 2
 #NO_APP
	ret
	.size	set_mepc, .-set_mepc
	.align	2
	.globl	get_mepc
	.type	get_mepc, @function
get_mepc:
 #APP
# 384 "stdio.c" 1
	csrr a0,mepc
# 0 "" 2
 #NO_APP
	ret
	.size	get_mepc, .-get_mepc
	.align	2
	.globl	set_mie
	.type	set_mie, @function
set_mie:
 #APP
# 392 "stdio.c" 1
	csrw mie,a0
# 0 "" 2
 #NO_APP
	ret
	.size	set_mie, .-set_mie
	.align	2
	.globl	get_mie
	.type	get_mie, @function
get_mie:
 #APP
# 399 "stdio.c" 1
	csrr a0,mie
# 0 "" 2
 #NO_APP
	ret
	.size	get_mie, .-get_mie
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
	.type	nxt.1117, @object
	.size	nxt.1117, 4
nxt.1117:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
