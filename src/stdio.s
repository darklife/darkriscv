	.file	"stdio.c"
	.option nopic
	.text
	.align	2
	.type	_idle.part.0, @function
_idle.part.0:
	.LA0: auipc	a5,%pcrel_hi(utimers)
	lw	a5,%pcrel_lo(.LA0)(a5)
	.LA1: auipc	a4,%pcrel_hi(utimers)
	addi	a3,a5,-1
	sw	a3,%pcrel_lo(.LA1)(a4)
	bnez	a5,.L2
	.LA2: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA2)
	lhu	a5,8(a5)
	.LA3: auipc	a4,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA3)
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,8(a4)
	li	a4,999424
	.LA4: auipc	a5,%pcrel_hi(utimers)
	addi	a4,a4,575
	sw	a4,%pcrel_lo(.LA4)(a5)
.L2:
	.LA5: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA5)
	li	a4,-128
	sb	a4,3(a5)
	ret
	.size	_idle.part.0, .-_idle.part.0
	.align	2
	.type	__udiv_umod_si3.part.1, @function
__udiv_umod_si3.part.1:
	mv	a4,a0
	li	a5,1
	bleu	a0,a1,.L6
.L5:
	bltz	a1,.L6
	slli	a1,a1,1
	slli	a5,a5,1
	bltu	a1,a4,.L5
.L6:
	li	a0,0
	beqz	a4,.L21
.L8:
	beqz	a5,.L9
	bgtu	a1,a4,.L10
	sub	a4,a4,a1
	add	a0,a0,a5
	srli	a1,a1,1
	srli	a5,a5,1
	bnez	a4,.L8
.L9:
	bnez	a2,.L4
	mv	a0,a4
	ret
.L10:
	srli	a5,a5,1
	srli	a1,a1,1
	j	.L8
.L4:
	ret
.L21:
	mv	a0,a4
	j	.L9
	.size	__udiv_umod_si3.part.1, .-__udiv_umod_si3.part.1
	.align	2
	.type	__div_mod_si3.part.2, @function
__div_mod_si3.part.2:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	s1,4(sp)
	sw	ra,12(sp)
	mv	s1,a2
	li	s0,0
	bgez	a0,.L23
	sub	a0,zero,a0
	li	s0,1
.L23:
	sw	zero,0(sp)
	bgez	a1,.L24
	li	a5,1
	sub	a1,zero,a1
	sw	a5,0(sp)
.L24:
	mv	a2,s1
	call	__udiv_umod_si3.part.1
	beqz	s1,.L25
	lw	a5,0(sp)
	beq	s0,a5,.L22
.L34:
	sub	a0,zero,a0
.L22:
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
.L25:
	bnez	s0,.L34
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,16
	jr	ra
	.size	__div_mod_si3.part.2, .-__div_mod_si3.part.2
	.align	2
	.globl	_idle
	.type	_idle, @function
_idle:
	.LA6: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA6)
	lbu	a5,3(a5)
	slli	a5,a5,24
	srai	a5,a5,24
	bltz	a5,.L38
	ret
.L38:
	tail	_idle.part.0
	.size	_idle, .-_idle
	.align	2
	.globl	getchar
	.type	getchar, @function
getchar:
	addi	sp,sp,-12
	sw	ra,8(sp)
.L41:
	.LA8: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA8)
	lbu	a5,4(a5)
	.LA7: auipc	a4,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA7)
	andi	a5,a5,2
	bnez	a5,.L45
	lbu	a5,3(a4)
	slli	a5,a5,24
	srai	a5,a5,24
	bgez	a5,.L41
	call	_idle.part.0
	j	.L41
.L45:
	lw	ra,8(sp)
	.LA9: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA9)
	lbu	a0,5(a5)
	addi	sp,sp,12
	jr	ra
	.size	getchar, .-getchar
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	addi	sp,sp,-12
	sw	s0,4(sp)
	sw	ra,8(sp)
	li	a5,10
	mv	s0,a0
	beq	a0,a5,.L49
.L52:
	.LA14: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA14)
	lbu	a5,4(a5)
	.LA13: auipc	a4,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA13)
	andi	a5,a5,1
	beqz	a5,.L58
	lbu	a5,3(a4)
	slli	a5,a5,24
	srai	a5,a5,24
	bgez	a5,.L52
	call	_idle.part.0
	j	.L52
.L60:
	call	_idle.part.0
.L49:
	.LA11: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA11)
	lbu	a5,4(a5)
	.LA10: auipc	a4,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA10)
	andi	a5,a5,1
	beqz	a5,.L59
	lbu	a5,3(a4)
	slli	a5,a5,24
	srai	a5,a5,24
	bgez	a5,.L49
	j	.L60
.L58:
	.LA15: auipc	a5,%pcrel_hi(io)
	andi	a4,s0,0xff
	addi	a5,a5,%pcrel_lo(.LA15)
	sb	a4,5(a5)
	lw	ra,8(sp)
	lw	s0,4(sp)
	mv	a0,a4
	addi	sp,sp,12
	jr	ra
.L59:
	.LA12: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA12)
	li	a4,13
	sb	a4,5(a5)
	j	.L52
	.size	putchar, .-putchar
	.align	2
	.globl	gets
	.type	gets, @function
gets:
	addi	sp,sp,-24
	sw	s0,16(sp)
	sw	s1,12(sp)
	sw	ra,20(sp)
	sw	a1,4(sp)
	sw	a0,8(sp)
	addi	s1,a1,-1
	mv	s0,a0
	beqz	s1,.L81
.L64:
	.LA17: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA17)
	lbu	a5,4(a5)
	andi	a5,a5,2
	bnez	a5,.L82
	.LA16: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA16)
	lbu	a5,3(a5)
	slli	a5,a5,24
	srai	a5,a5,24
	bgez	a5,.L64
	call	_idle.part.0
	j	.L64
.L82:
	.LA18: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA18)
	lbu	a4,5(a5)
	li	a3,10
	andi	a5,a4,0xff
	beq	a3,a4,.L66
	li	a4,13
	beq	a5,a4,.L66
	mv	a0,a5
	sw	a5,0(sp)
	call	putchar
	lw	a5,0(sp)
	li	a4,8
	beq	a5,a4,.L83
	sb	a5,0(s0)
	sw	s1,4(sp)
	addi	s0,s0,1
.L68:
	lw	a5,4(sp)
	addi	s1,a5,-1
	bnez	s1,.L64
.L66:
	li	a0,10
	call	putchar
	lw	a4,8(sp)
	sb	zero,0(s0)
	sub	a5,a4,s0
	snez	a5,a5
	sub	a5,zero,a5
	and	a5,a4,a5
	sw	a5,8(sp)
.L74:
	lw	ra,20(sp)
	lw	s0,16(sp)
	lw	a0,8(sp)
	lw	s1,12(sp)
	addi	sp,sp,24
	jr	ra
.L83:
	lw	a5,8(sp)
	beq	a5,s0,.L72
	sb	zero,-1(s0)
	addi	s0,s0,-1
	j	.L68
.L72:
	sw	s1,4(sp)
	j	.L68
.L81:
	li	a0,10
	call	putchar
	lw	a5,8(sp)
	sw	zero,8(sp)
	sb	zero,0(a5)
	j	.L74
	.size	gets, .-gets
	.align	2
	.globl	putstr
	.type	putstr, @function
putstr:
	addi	sp,sp,-12
	sw	ra,8(sp)
	sw	s0,4(sp)
	bnez	a0,.L94
	.LA20: auipc	a5,%pcrel_hi(.LC2)
	addi	a5,a5,%pcrel_lo(.LA20)
	mv	s0,a5
	j	.L96
.L87:
	addi	s0,s0,1
	call	putchar
.L96:
	lbu	a0,0(s0)
	bnez	a0,.L87
	lw	ra,8(sp)
	lw	s0,4(sp)
	addi	sp,sp,12
	jr	ra
.L94:
	mv	s0,a0
	j	.L96
	.size	putstr, .-putstr
	.align	2
	.globl	puts
	.type	puts, @function
puts:
	addi	sp,sp,-12
	sw	ra,8(sp)
	sw	s0,4(sp)
	bnez	a0,.L107
	.LA22: auipc	a5,%pcrel_hi(.LC2)
	addi	a5,a5,%pcrel_lo(.LA22)
	mv	s0,a5
	j	.L109
.L100:
	addi	s0,s0,1
	call	putchar
.L109:
	lbu	a0,0(s0)
	bnez	a0,.L100
	lw	s0,4(sp)
	lw	ra,8(sp)
	li	a0,10
	addi	sp,sp,12
	tail	putchar
.L107:
	mv	s0,a0
	j	.L109
	.size	puts, .-puts
	.globl	__udivsi3
	.globl	__umodsi3
	.align	2
	.globl	putdx
	.type	putdx, @function
putdx:
	.LA23: auipc	a5,%pcrel_hi(.LANCHOR0)
	addi	sp,sp,-88
	addi	a5,a5,%pcrel_lo(.LA23)
	sw	s0,80(sp)
	lw	s0,32(a5)
	lw	a4,0(a5)
	lw	t2,8(a5)
	sw	s0,64(sp)
	lw	s0,36(a5)
	sw	a4,32(sp)
	lw	a4,4(a5)
	sw	s0,68(sp)
	lw	s0,40(a5)
	lw	t0,12(a5)
	lw	t1,16(a5)
	sw	s0,72(sp)
	lw	s0,44(a5)
	lw	a2,20(a5)
	sw	a4,36(sp)
	sw	s0,12(sp)
	lw	s0,48(a5)
	lw	a4,28(a5)
	lw	a3,24(a5)
	sw	s0,16(sp)
	lw	s0,52(a5)
	sw	ra,84(sp)
	sw	s1,76(sp)
	sw	s0,20(sp)
	lw	s0,56(a5)
	lw	a5,60(a5)
	sw	t2,40(sp)
	sw	s0,24(sp)
	sw	t0,44(sp)
	sw	t1,48(sp)
	sw	a2,52(sp)
	sw	a3,56(sp)
	sw	a4,60(sp)
	sw	a5,28(sp)
	mv	s0,a1
	addi	a4,sp,12
	beqz	a1,.L111
	addi	a4,sp,32
.L111:
	lw	a1,0(a4)
	beqz	a1,.L110
	addi	s1,a4,4
	mv	a5,s1
	sw	s0,0(sp)
	li	s0,24
	mv	s1,s0
	mv	a3,a0
	mv	s0,a5
	j	.L116
.L124:
	call	__udivsi3
	li	a1,10
	call	__umodsi3
	.LA25: auipc	a5,%pcrel_hi(.LC3)
	addi	a5,a5,%pcrel_lo(.LA25)
	add	a0,a0,a5
	lbu	a0,0(a0)
	call	putchar
	lw	a3,4(sp)
.L114:
	addi	s0,s0,4
	lw	a1,-4(s0)
	addi	s1,s1,-8
	beqz	a1,.L110
.L116:
	li	a5,1
	beq	a1,a5,.L113
	bgtu	a1,a3,.L114
.L113:
	addi	a5,s1,4
	lw	a4,0(sp)
	srl	a5,a3,a5
	.LA26: auipc	a2,%pcrel_hi(.LC3)
	andi	a5,a5,15
	addi	a2,a2,%pcrel_lo(.LA26)
	sw	a3,4(sp)
	add	a5,a5,a2
	mv	a0,a3
	bnez	a4,.L124
	lbu	a0,0(a5)
	sw	a2,8(sp)
	addi	s0,s0,4
	call	putchar
	lw	a3,4(sp)
	lw	a2,8(sp)
	srl	a5,a3,s1
	andi	a5,a5,15
	add	a2,a5,a2
	lbu	a0,0(a2)
	addi	s1,s1,-8
	call	putchar
	lw	a1,-4(s0)
	lw	a3,4(sp)
	bnez	a1,.L116
.L110:
	lw	ra,84(sp)
	lw	s0,80(sp)
	lw	s1,76(sp)
	addi	sp,sp,88
	jr	ra
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
	addi	sp,sp,-44
	sw	s1,12(sp)
	sw	a5,40(sp)
	sw	ra,20(sp)
	sw	s0,16(sp)
	sw	a1,24(sp)
	sw	a2,28(sp)
	sw	a3,32(sp)
	sw	a4,36(sp)
	mv	s1,a0
	lbu	a0,0(a0)
	addi	a5,sp,24
	sw	a5,8(sp)
	bnez	a0,.L128
	j	.L144
.L150:
	lbu	a0,1(s1)
	li	a5,115
	addi	s1,s1,2
	beq	a0,a5,.L147
	li	a5,120
	beq	a0,a5,.L148
	li	a5,100
	beq	a0,a5,.L149
	call	putchar
.L132:
	lbu	a0,1(s0)
	beqz	a0,.L144
.L128:
	li	a5,37
	addi	s0,s1,1
	beq	a0,a5,.L150
	call	putchar
	mv	a5,s0
	mv	s0,s1
	lbu	a0,1(s0)
	mv	s1,a5
	bnez	a0,.L128
.L144:
	lw	ra,20(sp)
	lw	s0,16(sp)
	lw	s1,12(sp)
	li	a0,0
	addi	sp,sp,44
	jr	ra
.L149:
	lw	a5,8(sp)
	li	a1,1
	lw	a0,0(a5)
	addi	a5,a5,4
	sw	a5,8(sp)
	call	putdx
	j	.L132
.L148:
	lw	a5,8(sp)
	li	a1,0
	lw	a0,0(a5)
	addi	a5,a5,4
	sw	a5,8(sp)
	call	putdx
	j	.L132
.L147:
	lw	a3,8(sp)
	.LA29: auipc	a4,%pcrel_hi(.LC2)
	addi	a4,a4,%pcrel_lo(.LA29)
	lw	a5,0(a3)
	addi	a3,a3,4
	sw	a3,8(sp)
	bnez	a5,.L145
	mv	a5,a4
.L145:
	lbu	a0,0(a5)
	beqz	a0,.L132
.L133:
	addi	a5,a5,1
	sw	a5,0(sp)
	sw	a5,4(sp)
	call	putchar
	lw	a5,0(sp)
	lbu	a0,0(a5)
	bnez	a0,.L133
	j	.L132
	.size	printf, .-printf
	.align	2
	.globl	strncmp
	.type	strncmp, @function
strncmp:
	li	a5,1
	lbu	a3,0(a0)
	lbu	t1,0(a1)
	mv	a4,a0
	bne	a2,a5,.L152
	j	.L153
.L166:
	beqz	t1,.L153
	bne	a3,t1,.L153
	lbu	a3,0(a4)
	lbu	t1,0(a1)
	beqz	a5,.L153
.L152:
	addi	a4,a4,1
	not	a5,a4
	add	a5,a5,a2
	addi	a1,a1,1
	add	a5,a0,a5
	bnez	a3,.L166
.L153:
	sub	a0,a3,t1
	ret
	.size	strncmp, .-strncmp
	.align	2
	.globl	strcmp
	.type	strcmp, @function
strcmp:
	lbu	a5,0(a0)
	lbu	a4,0(a1)
	bnez	a5,.L168
	j	.L169
.L174:
	bne	a5,a4,.L169
	lbu	a5,0(a0)
	lbu	a4,0(a1)
	beqz	a5,.L172
.L168:
	addi	a0,a0,1
	addi	a1,a1,1
	bnez	a4,.L174
.L169:
	sub	a0,a5,a4
	ret
.L172:
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
	bnez	a5,.L176
	j	.L181
.L178:
	addi	a0,a0,1
.L176:
	addi	a5,a5,1
	lbu	a4,-1(a5)
	bnez	a4,.L178
	ret
.L181:
	ret
	.size	strlen, .-strlen
	.align	2
	.globl	memcpy
	.type	memcpy, @function
memcpy:
	beqz	a2,.L183
	add	a2,a0,a2
	mv	a5,a0
.L184:
	addi	a1,a1,1
	lbu	a4,-1(a1)
	addi	a5,a5,1
	sb	a4,-1(a5)
	bne	a2,a5,.L184
.L183:
	ret
	.size	memcpy, .-memcpy
	.align	2
	.globl	memset
	.type	memset, @function
memset:
	andi	a1,a1,0xff
	add	a4,a0,a2
	mv	a5,a0
	beqz	a2,.L195
.L191:
	addi	a5,a5,1
	sb	a1,-1(a5)
	bne	a4,a5,.L191
.L195:
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
	beqz	a1,.L198
	mv	a5,a1
	li	t2,0
	j	.L197
.L199:
	addi	t2,t2,1
.L197:
	addi	a5,a5,1
	lbu	a4,-1(a5)
	bnez	a4,.L199
.L198:
	lw	a5,0(sp)
	beqz	a5,.L235
.L200:
	lw	t0,0(sp)
	lbu	a3,0(t0)
	beqz	a3,.L202
	lbu	s0,0(a1)
	add	t1,t0,t2
	li	s1,1
.L203:
	mv	a0,a1
	mv	a5,t0
	mv	a2,s0
	beq	t2,s1,.L204
.L207:
	addi	a5,a5,1
	not	a4,a5
	addi	a0,a0,1
	add	a4,a4,t1
	beqz	a2,.L205
	bne	a2,a3,.L205
	lbu	a3,0(a5)
	lbu	a2,0(a0)
	beqz	a4,.L204
	bnez	a3,.L207
.L204:
	beq	a3,a2,.L236
.L205:
	addi	t0,t0,1
	lbu	a3,0(t0)
	addi	t1,t1,1
	bnez	a3,.L203
.L202:
	lw	a0,0(sp)
	.LA32: auipc	a5,%pcrel_hi(nxt.1110)
	sw	zero,%pcrel_lo(.LA32)(a5)
.L196:
	lw	s0,8(sp)
	lw	s1,4(sp)
	addi	sp,sp,12
	jr	ra
.L236:
	sb	zero,0(t0)
	lw	s0,8(sp)
	addi	a4,t0,1
	.LA31: auipc	a5,%pcrel_hi(nxt.1110)
	sw	a4,%pcrel_lo(.LA31)(a5)
	lw	a0,0(sp)
	lw	s1,4(sp)
	addi	sp,sp,12
	jr	ra
.L235:
	.LA30: auipc	a5,%pcrel_hi(nxt.1110)
	lw	a5,%pcrel_lo(.LA30)(a5)
	sw	a5,0(sp)
	bnez	a5,.L200
	li	a0,0
	j	.L196
	.size	strtok, .-strtok
	.align	2
	.globl	atoi
	.type	atoi, @function
atoi:
	mv	a5,a0
	li	t0,0
	li	a0,0
	li	t1,45
	bnez	a5,.L238
	j	.L252
.L253:
	addi	a5,a5,1
	add	a0,a4,a1
	beqz	a5,.L241
.L238:
	lbu	a3,0(a5)
	slli	a4,a0,3
	slli	a1,a0,1
	addi	a2,a3,-48
	add	a4,a2,a4
	beqz	a3,.L241
	bne	a3,t1,.L253
	addi	a5,a5,1
	li	t0,1
	bnez	a5,.L238
.L241:
	beqz	t0,.L237
	sub	a0,zero,a0
.L237:
	ret
.L252:
	ret
	.size	atoi, .-atoi
	.align	2
	.globl	xtoi
	.type	xtoi, @function
xtoi:
	mv	a4,a0
	li	t1,57
	li	a0,0
	bnez	a4,.L255
	j	.L265
.L259:
	add	a0,a1,a2
	bleu	a5,t1,.L258
	add	a0,a3,a2
.L258:
	addi	a4,a4,1
	beqz	a4,.L254
.L255:
	lbu	a5,0(a4)
	slli	a2,a0,4
	andi	a3,a5,95
	addi	a1,a5,-48
	addi	a3,a3,-55
	bnez	a5,.L259
.L254:
	ret
.L265:
	ret
	.size	xtoi, .-xtoi
	.align	2
	.globl	mac
	.type	mac, @function
mac:
 #APP
# 285 "stdio.c" 1
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
	bgeu	a0,a1,.L268
	mv	a5,a1
	mv	a1,a0
.L268:
	li	a0,0
	beqz	a1,.L272
.L271:
	andi	a4,a1,1
	srli	a1,a1,1
	beqz	a4,.L270
	add	a0,a0,a5
.L270:
	slli	a5,a5,1
	bnez	a1,.L271
	ret
.L272:
	ret
	.size	__umulsi3, .-__umulsi3
	.align	2
	.globl	__mulsi3
	.type	__mulsi3, @function
__mulsi3:
	li	a2,0
	bgez	a0,.L278
	sub	a0,zero,a0
	li	a2,1
.L278:
	mv	a5,a0
	bltz	a1,.L295
	mv	a4,a1
	li	t1,0
	bgtu	a1,a0,.L280
	mv	a4,a0
	li	t1,0
	mv	a5,a1
.L280:
	beqz	a5,.L290
.L281:
	li	a0,0
.L284:
	andi	a3,a5,1
	srli	a5,a5,1
	beqz	a3,.L283
	add	a0,a0,a4
.L283:
	slli	a4,a4,1
	bnez	a5,.L284
.L282:
	beq	a2,t1,.L277
	sub	a0,zero,a0
.L277:
	ret
.L295:
	sub	a4,zero,a1
	bgtu	a4,a0,.L288
	mv	a5,a4
	li	t1,1
	mv	a4,a0
	j	.L281
.L288:
	li	t1,1
	bnez	a5,.L281
.L290:
	li	a0,0
	j	.L282
	.size	__mulsi3, .-__mulsi3
	.align	2
	.globl	__udiv_umod_si3
	.type	__udiv_umod_si3, @function
__udiv_umod_si3:
	beqz	a1,.L297
	tail	__udiv_umod_si3.part.1
.L297:
	li	a0,0
	ret
	.size	__udiv_umod_si3, .-__udiv_umod_si3
	.align	2
	.globl	__udivsi3
	.type	__udivsi3, @function
__udivsi3:
	beqz	a1,.L299
	li	a2,1
	tail	__udiv_umod_si3.part.1
.L299:
	li	a0,0
	ret
	.size	__udivsi3, .-__udivsi3
	.align	2
	.globl	__umodsi3
	.type	__umodsi3, @function
__umodsi3:
	beqz	a1,.L301
	li	a2,0
	tail	__udiv_umod_si3.part.1
.L301:
	li	a0,0
	ret
	.size	__umodsi3, .-__umodsi3
	.align	2
	.globl	__div_mod_si3
	.type	__div_mod_si3, @function
__div_mod_si3:
	beqz	a1,.L303
	tail	__div_mod_si3.part.2
.L303:
	li	a0,0
	ret
	.size	__div_mod_si3, .-__div_mod_si3
	.align	2
	.globl	__divsi3
	.type	__divsi3, @function
__divsi3:
	beqz	a1,.L305
	li	a2,1
	tail	__div_mod_si3.part.2
.L305:
	li	a0,0
	ret
	.size	__divsi3, .-__divsi3
	.align	2
	.globl	__modsi3
	.type	__modsi3, @function
__modsi3:
	beqz	a1,.L307
	li	a2,0
	tail	__div_mod_si3.part.2
.L307:
	li	a0,0
	ret
	.size	__modsi3, .-__modsi3
	.align	2
	.globl	usleep
	.type	usleep, @function
usleep:
	addi	a4,a0,-1
	beqz	a0,.L308
	li	a2,-128
	li	a3,-1
.L311:
	.LA33: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA33)
	sb	a2,3(a5)
.L310:
	.LA34: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA34)
	lbu	a5,3(a5)
	andi	a5,a5,0xff
	beqz	a5,.L310
	addi	a4,a4,-1
	bne	a4,a3,.L311
.L308:
	ret
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
	.type	nxt.1110, @object
	.size	nxt.1110, 4
nxt.1110:
	.zero	4
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
