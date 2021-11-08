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
	.LA19: auipc	a5,%pcrel_hi(.LC0)
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
	.globl	__umodsi3
	.globl	__udivsi3
	.align	2
	.globl	putnum
	.type	putnum, @function
putnum:
	.LA24: auipc	a4,%pcrel_hi(.LC1)
	addi	a5,a4,%pcrel_lo(.LA24)
	lw	t1,%pcrel_lo(.LA24)(a4)
	lw	a2,4(a5)
	lw	a4,12(a5)
	lw	a3,8(a5)
	lbu	a5,16(a5)
	addi	sp,sp,-72
	sw	s1,60(sp)
	sw	a4,20(sp)
	sb	a5,24(sp)
	sw	ra,68(sp)
	sw	s0,64(sp)
	sw	t1,8(sp)
	sw	a2,12(sp)
	sw	a3,16(sp)
	li	a4,10
	mv	s1,a1
	mv	a5,a0
	beq	a1,a4,.L100
.L85:
	li	s0,0
.L88:
	mv	a1,s1
	mv	a0,a5
	sw	a5,0(sp)
	call	__umodsi3
	addi	a5,sp,60
	add	a0,a5,a0
	lw	a5,0(sp)
	lbu	a3,-52(a0)
	addi	a4,s0,1
	mv	a0,a5
	addi	a5,sp,60
	add	a5,a5,a4
	sw	a5,4(sp)
	addi	a5,sp,60
	add	a5,a5,s0
	sb	a3,-32(a5)
	mv	a1,s1
	sw	a4,0(sp)
	call	__udivsi3
	li	a3,10
	mv	a5,a0
	mv	a1,s1
	lw	a4,0(sp)
	beq	s1,a3,.L93
	sw	a0,0(sp)
	call	__umodsi3
	lw	a5,0(sp)
	addi	a4,sp,60
	add	a0,a4,a0
	lbu	a4,-52(a0)
	mv	a0,a5
	lw	a5,4(sp)
	mv	a1,s1
	addi	s0,s0,2
	sb	a4,-32(a5)
	call	__udivsi3
	mv	a5,a0
	bnez	a5,.L88
.L101:
	addi	a3,sp,28
	add	s0,a3,s0
	li	a2,10
	li	a1,13
.L92:
	lbu	a4,-1(s0)
	beq	a4,a2,.L90
.L91:
	.LA29: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA29)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L91
	.LA30: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA30)
	sb	a4,5(a5)
	addi	s0,s0,-1
	bne	a3,s0,.L92
	lw	ra,68(sp)
	lw	s0,64(sp)
	lw	s1,60(sp)
	addi	sp,sp,72
	jr	ra
.L90:
	.LA27: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA27)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L90
	.LA28: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA28)
	sb	a1,5(a5)
	j	.L91
.L93:
	mv	s0,a4
	bnez	a5,.L88
	j	.L101
.L100:
	bgez	a0,.L85
.L86:
	.LA25: auipc	a4,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA25)
	lbu	a4,4(a4)
	andi	a4,a4,1
	bnez	a4,.L86
	.LA26: auipc	a4,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA26)
	li	a3,45
	sb	a3,5(a4)
	sub	a5,zero,a5
	j	.L85
	.size	putnum, .-putnum
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
	beqz	a3,.L122
	mv	s0,a0
	li	a4,37
.L103:
	addi	s1,s0,1
	bne	a3,a4,.L104
	lbu	a3,1(s0)
	li	a5,115
	addi	s0,s0,2
	beq	a3,a5,.L125
	li	a5,120
	beq	a3,a5,.L126
	li	a5,100
	beq	a3,a5,.L127
	li	a5,10
	beq	a3,a5,.L110
.L111:
	.LA33: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA33)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L111
	.LA34: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA34)
	sb	a3,5(a5)
.L106:
	lbu	a3,1(s1)
	bnez	a3,.L103
.L122:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	li	a0,0
	addi	sp,sp,36
	jr	ra
.L110:
	.LA31: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA31)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L110
	.LA32: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA32)
	li	a2,13
	sb	a2,5(a5)
	j	.L111
.L104:
	li	a5,10
	beq	a3,a5,.L113
.L114:
	.LA37: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA37)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L114
	.LA38: auipc	a5,%pcrel_hi(io)
	mv	a2,s1
	addi	a5,a5,%pcrel_lo(.LA38)
	mv	s1,s0
	sb	a3,5(a5)
	mv	s0,a2
	j	.L106
.L113:
	.LA35: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA35)
	lbu	a5,4(a5)
	andi	a5,a5,1
	bnez	a5,.L113
	.LA36: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA36)
	li	a2,13
	sb	a2,5(a5)
	j	.L114
.L127:
	lw	a5,0(sp)
	li	a1,10
.L124:
	lw	a0,0(a5)
	addi	a5,a5,4
	sw	a5,0(sp)
	call	putnum
	li	a4,37
	j	.L106
.L125:
	lw	a5,0(sp)
	lw	a0,0(a5)
	addi	a5,a5,4
	sw	a5,0(sp)
	call	putstr
	li	a4,37
	j	.L106
.L126:
	lw	a5,0(sp)
	li	a1,16
	j	.L124
	.size	printf, .-printf
	.align	2
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	li	a5,1
	lbu	a3,0(a0)
	lbu	t1,0(a1)
	mv	a4,a0
	bne	a2,a5,.L129
	j	.L130
.L143:
	beqz	t1,.L130
	bne	a3,t1,.L130
	lbu	a3,0(a4)
	lbu	t1,0(a1)
	beqz	a5,.L130
.L129:
	addi	a4,a4,1
	not	a5,a4
	add	a5,a5,a2
	addi	a1,a1,1
	add	a5,a0,a5
	bnez	a3,.L143
.L130:
	sub	a0,a3,t1
	ret
	.size	strncmp, .-strncmp
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
	lbu	a5,0(a0)
	lbu	a4,0(a1)
	bnez	a5,.L145
	j	.L146
.L151:
	bne	a5,a4,.L146
	lbu	a5,0(a0)
	lbu	a4,0(a1)
	beqz	a5,.L149
.L145:
	addi	a0,a0,1
	addi	a1,a1,1
	bnez	a4,.L151
.L146:
	sub	a0,a5,a4
	ret
.L149:
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
	bnez	a5,.L153
	j	.L158
.L155:
	addi	a0,a0,1
.L153:
	addi	a5,a5,1
	lbu	a4,-1(a5)
	bnez	a4,.L155
	ret
.L158:
	ret
	.size	strlen, .-strlen
	.align	2
	.globl	strtok
	.type	strtok, @function
strtok:
	addi	sp,sp,-12
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	a0,0(sp)
	mv	t2,a1
	beqz	a1,.L161
	mv	a5,a1
	li	t2,0
	j	.L160
.L162:
	addi	t2,t2,1
.L160:
	addi	a5,a5,1
	lbu	a4,-1(a5)
	bnez	a4,.L162
.L161:
	lw	a5,0(sp)
	beqz	a5,.L198
.L163:
	lw	t0,0(sp)
	lbu	a3,0(t0)
	beqz	a3,.L165
	lbu	s0,0(a1)
	add	t1,t0,t2
	li	s1,1
.L166:
	mv	a0,a1
	mv	a5,t0
	mv	a2,s0
	beq	t2,s1,.L167
.L170:
	addi	a5,a5,1
	not	a4,a5
	addi	a0,a0,1
	add	a4,a4,t1
	beqz	a2,.L168
	bne	a2,a3,.L168
	lbu	a3,0(a5)
	lbu	a2,0(a0)
	beqz	a4,.L167
	bnez	a3,.L170
.L167:
	beq	a3,a2,.L199
.L168:
	addi	t0,t0,1
	lbu	a3,0(t0)
	addi	t1,t1,1
	bnez	a3,.L166
.L165:
	lw	a0,0(sp)
	.LA41: auipc	a5,%pcrel_hi(nxt.1096)
	sw	zero,%pcrel_lo(.LA41)(a5)
.L159:
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,12
	jr	ra
.L199:
	sb	zero,0(t0)
	lw	s0,8(sp)
	addi	a4,t0,1
	.LA40: auipc	a5,%pcrel_hi(nxt.1096)
	sw	a4,%pcrel_lo(.LA40)(a5)
	lw	a0,0(sp)
	lw	s1,4(sp)
	addi	sp,sp,12
	jr	ra
.L198:
	.LA39: auipc	a5,%pcrel_hi(nxt.1096)
	lw	a5,%pcrel_lo(.LA39)(a5)
	sw	a5,0(sp)
	bnez	a5,.L163
	li	a0,0
	j	.L159
	.size	strtok, .-strtok
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	beqz	a2,.L201
	add	a2,a0,a2
	mv	a5,a0
.L202:
	addi	a1,a1,1
	lbu	a4,-1(a1)
	addi	a5,a5,1
	sb	a4,-1(a5)
	bne	a2,a5,.L202
.L201:
	ret
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	andi	a1,a1,0xff
	add	a4,a0,a2
	mv	a5,a0
	beqz	a2,.L213
.L209:
	addi	a5,a5,1
	sb	a1,-1(a5)
	bne	a4,a5,.L209
.L213:
	ret
	.size	memset, .-memset
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	mv	a5,a0
	li	t0,0
	li	a0,0
	li	t1,45
	bnez	a5,.L215
	j	.L229
.L230:
	addi	a5,a5,1
	add	a0,a4,a1
	beqz	a5,.L218
.L215:
	lbu	a3,0(a5)
	slli	a4,a0,3
	slli	a1,a0,1
	addi	a2,a3,-48
	add	a4,a2,a4
	beqz	a3,.L218
	bne	a3,t1,.L230
	addi	a5,a5,1
	li	t0,1
	bnez	a5,.L215
.L218:
	beqz	t0,.L214
	sub	a0,zero,a0
.L214:
	ret
.L229:
	ret
	.size	atoi, .-atoi
	.align	2
	.globl	xtoi
	.type	xtoi, @function
xtoi:
	mv	a4,a0
	li	t1,57
	li	a0,0
	bnez	a4,.L232
	j	.L242
.L236:
	add	a0,a1,a2
	bleu	a5,t1,.L235
	add	a0,a3,a2
.L235:
	addi	a4,a4,1
	beqz	a4,.L231
.L232:
	lbu	a5,0(a4)
	slli	a2,a0,4
	andi	a3,a5,95
	addi	a1,a5,-48
	addi	a3,a3,-55
	bnez	a5,.L236
.L231:
	ret
.L242:
	ret
	.size	xtoi, .-xtoi
	.align	2
	.globl	mac
	.type	mac, @function
mac:
 #APP
# 267 "stdio.c" 1
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
	bgeu	a0,a1,.L245
	mv	a5,a1
	mv	a1,a0
.L245:
	li	a0,0
	beqz	a1,.L249
.L248:
	andi	a4,a1,1
	srli	a1,a1,1
	beqz	a4,.L247
	add	a0,a0,a5
.L247:
	slli	a5,a5,1
	bnez	a1,.L248
	ret
.L249:
	ret
	.size	__umulsi3, .-__umulsi3
	.align	2
	.globl	__mulsi3
	.type	__mulsi3, @function
__mulsi3:
	li	a2,0
	bgez	a0,.L255
	sub	a0,zero,a0
	li	a2,1
.L255:
	mv	a5,a0
	bltz	a1,.L272
	mv	a4,a1
	li	t1,0
	bgtu	a1,a0,.L257
	mv	a4,a0
	li	t1,0
	mv	a5,a1
.L257:
	beqz	a5,.L267
.L258:
	li	a0,0
.L261:
	andi	a3,a5,1
	srli	a5,a5,1
	beqz	a3,.L260
	add	a0,a0,a4
.L260:
	slli	a4,a4,1
	bnez	a5,.L261
.L259:
	beq	a2,t1,.L254
	sub	a0,zero,a0
.L254:
	ret
.L272:
	sub	a4,zero,a1
	bgtu	a4,a0,.L265
	mv	a5,a4
	li	t1,1
	mv	a4,a0
	j	.L258
.L265:
	li	t1,1
	bnez	a5,.L258
.L267:
	li	a0,0
	j	.L259
	.size	__mulsi3, .-__mulsi3
	.align	2
	.globl	__udiv_umod_si3
	.type	__udiv_umod_si3, @function
__udiv_umod_si3:
	beqz	a1,.L274
	tail	__udiv_umod_si3.part.0
.L274:
	li	a0,0
	ret
	.size	__udiv_umod_si3, .-__udiv_umod_si3
	.align	2
	.globl	__udivsi3
	.type	__udivsi3, @function
__udivsi3:
	beqz	a1,.L276
	li	a2,1
	tail	__udiv_umod_si3.part.0
.L276:
	li	a0,0
	ret
	.size	__udivsi3, .-__udivsi3
	.align	2
	.globl	__umodsi3
	.type	__umodsi3, @function
__umodsi3:
	beqz	a1,.L278
	li	a2,0
	tail	__udiv_umod_si3.part.0
.L278:
	li	a0,0
	ret
	.size	__umodsi3, .-__umodsi3
	.align	2
	.globl	__div_mod_si3
	.type	__div_mod_si3, @function
__div_mod_si3:
	beqz	a1,.L280
	tail	__div_mod_si3.part.1
.L280:
	li	a0,0
	ret
	.size	__div_mod_si3, .-__div_mod_si3
	.align	2
	.globl	__divsi3
	.type	__divsi3, @function
__divsi3:
	beqz	a1,.L282
	li	a2,1
	tail	__div_mod_si3.part.1
.L282:
	li	a0,0
	ret
	.size	__divsi3, .-__divsi3
	.align	2
	.globl	__modsi3
	.type	__modsi3, @function
__modsi3:
	beqz	a1,.L284
	li	a2,0
	tail	__div_mod_si3.part.1
.L284:
	li	a0,0
	ret
	.size	__modsi3, .-__modsi3
	.align	2
	.globl	usleep
	.type	usleep, @function
usleep:
	addi	sp,sp,-12
	sw	s0,4(sp)
	sw	ra,8(sp)
	mv	s0,a0
	call	get_mtvec
	addi	a3,s0,-1
	bnez	a0,.L286
	li	a2,-128
	li	a4,-1
	beqz	s0,.L285
.L287:
	.LA44: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA44)
	sb	a2,3(a5)
.L291:
	.LA45: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA45)
	lbu	a5,3(a5)
	andi	a5,a5,0xff
	beqz	a5,.L291
	addi	a3,a3,-1
	bne	a3,a4,.L287
.L285:
	lw	ra,8(sp)
	lw	s0,4(sp)
	addi	sp,sp,12
	jr	ra
.L286:
	beqz	s0,.L285
	li	a2,-1
.L290:
	.LA42: auipc	a5,%pcrel_hi(utimers)
	lw	a4,%pcrel_lo(.LA42)(a5)
.L289:
	.LA43: auipc	a5,%pcrel_hi(utimers)
	lw	a5,%pcrel_lo(.LA43)(a5)
	beq	a5,a4,.L289
	addi	a3,a3,-1
	bne	a3,a2,.L290
	lw	ra,8(sp)
	lw	s0,4(sp)
	addi	sp,sp,12
	jr	ra
	.size	usleep, .-usleep
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"(NULL)"
	.zero	1
.LC1:
	.string	"0123456789abcdef"
	.section	.sbss,"aw",@nobits
	.align	2
	.type	nxt.1096, @object
	.size	nxt.1096, 4
nxt.1096:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
