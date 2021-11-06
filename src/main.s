	.file	"main.c"
	.option nopic
	.text
	.align	2
	.globl	irq_handler
	.type	irq_handler, @function
irq_handler:
	addi	sp,sp,-12
	sw	a5,0(sp)
	.LA0: auipc	a5,%pcrel_hi(io)
	sw	a4,4(sp)
	sw	a3,8(sp)
	addi	a5,a5,%pcrel_lo(.LA0)
	lbu	a5,3(a5)
	li	a4,128
	beq	a4,a5,.L6
	lw	a3,8(sp)
	lw	a4,4(sp)
	lw	a5,0(sp)
	addi	sp,sp,12
	mret
.L6:
	.LA1: auipc	a5,%pcrel_hi(utimers)
	lw	a5,%pcrel_lo(.LA1)(a5)
	.LA2: auipc	a4,%pcrel_hi(utimers)
	addi	a3,a5,-1
	sw	a3,%pcrel_lo(.LA2)(a4)
	bnez	a5,.L3
	.LA3: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA3)
	lhu	a5,8(a5)
	.LA4: auipc	a4,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA4)
	addi	a5,a5,1
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,8(a4)
	li	a4,999424
	.LA5: auipc	a5,%pcrel_hi(utimers)
	addi	a4,a4,575
	sw	a4,%pcrel_lo(.LA5)(a5)
.L3:
	.LA6: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA6)
	li	a4,-128
	sb	a4,3(a5)
	lw	a3,8(sp)
	lw	a4,4(sp)
	lw	a5,0(sp)
	addi	sp,sp,12
	mret
	.size	irq_handler, .-irq_handler
	.globl	__udivsi3
	.globl	__mulsi3
	.globl	__modsi3
	.globl	__divsi3
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	.LA13: auipc	a5,%pcrel_hi(io)
	lbu	a0,%pcrel_lo(.LA13)(a5)
	addi	sp,sp,-128
	sw	ra,124(sp)
	sw	s0,120(sp)
	sw	s1,116(sp)
	call	board_name
	.LA14: auipc	a5,%pcrel_hi(io)
	lbu	a2,%pcrel_lo(.LA14)(a5)
	mv	a1,a0
	.LA15: auipc	a0,%pcrel_hi(.LC5)
	addi	a0,a0,%pcrel_lo(.LA15)
	call	printf
	.LA16: auipc	a2,%pcrel_hi(.LC6)
	.LA17: auipc	a1,%pcrel_hi(.LC7)
	.LA18: auipc	a0,%pcrel_hi(.LC8)
	addi	a2,a2,%pcrel_lo(.LA16)
	addi	a1,a1,%pcrel_lo(.LA17)
	addi	a0,a0,%pcrel_lo(.LA18)
	call	printf
	.LA19: auipc	a5,%pcrel_hi(threads)
	lw	a5,%pcrel_lo(.LA19)(a5)
	li	s0,0
	beqz	a5,.L14
.L8:
	.LA29: auipc	a4,%pcrel_hi(io)
	.LA30: auipc	a5,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA29)
	addi	a5,a5,%pcrel_lo(.LA30)
	lbu	s1,1(a4)
	lbu	a5,2(a5)
	.LA7: auipc	a4,%pcrel_hi(.LC0)
	sw	a4,8(sp)
	andi	a5,a5,0xff
	sw	a5,4(sp)
	call	check4rv32i
	.LA31: auipc	a5,%pcrel_hi(threads)
	lw	a4,8(sp)
	lw	a3,%pcrel_lo(.LA31)(a5)
	andi	s1,s1,0xff
	li	a2,16
	li	a1,16
	.LA9: auipc	a5,%pcrel_hi(.LC2)
	addi	a4,a4,%pcrel_lo(.LA7)
	bnez	a0,.L11
	.LA8: auipc	a4,%pcrel_hi(.LC1)
	addi	a4,a4,%pcrel_lo(.LA8)
.L11:
	li	t1,1
	li	a0,1000
	addi	a5,a5,%pcrel_lo(.LA9)
	bgt	a3,t1,.L12
	.LA10: auipc	a5,%pcrel_hi(.LC3)
	addi	a5,a5,%pcrel_lo(.LA10)
.L12:
	sw	a5,12(sp)
	sw	a4,8(sp)
	call	mac
	.LA11: auipc	t1,%pcrel_hi(.LC4)
	li	t0,1256
	mv	a1,s0
	lw	a5,12(sp)
	lw	a4,8(sp)
	lw	a3,4(sp)
	mv	a2,s1
	addi	s0,s0,1
	addi	t1,t1,%pcrel_lo(.LA11)
	beq	a0,t0,.L13
	.LA12: auipc	t1,%pcrel_hi(.LC3)
	addi	t1,t1,%pcrel_lo(.LA12)
.L13:
	.LA32: auipc	a0,%pcrel_hi(.LC11)
	sw	t1,0(sp)
	addi	a0,a0,%pcrel_lo(.LA32)
	call	printf
	.LA33: auipc	a5,%pcrel_hi(threads)
	lw	a5,%pcrel_lo(.LA33)(a5)
	bne	a5,s0,.L8
.L14:
	.LA20: auipc	a5,%pcrel_hi(threads)
	sw	zero,%pcrel_lo(.LA20)(a5)
	.LA21: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA21)
	lhu	a1,6(a5)
	.LA22: auipc	a0,%pcrel_hi(.LC9)
	addi	a0,a0,%pcrel_lo(.LA22)
	call	printf
	.LA23: auipc	a4,%pcrel_hi(io)
	.LA24: auipc	a5,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA23)
	addi	a5,a5,%pcrel_lo(.LA24)
	lbu	t1,1(a4)
	lbu	a4,2(a5)
	.LA25: auipc	a2,%pcrel_hi(io)
	slli	a3,t1,5
	slli	a5,a4,2
	sub	a3,a3,t1
	add	a5,a5,a4
	slli	a0,a3,6
	slli	a5,a5,3
	sub	a5,a5,a4
	addi	a2,a2,%pcrel_lo(.LA25)
	sub	a0,a0,a3
	lw	a1,12(a2)
	slli	a0,a0,3
	slli	a5,a5,4
	add	a0,a0,t1
	add	a5,a5,a4
	.LA26: auipc	a3,%pcrel_hi(io)
	addi	a3,a3,%pcrel_lo(.LA26)
	slli	a5,a5,4
	slli	a0,a0,6
	lw	s0,12(a3)
	add	a0,a0,a5
	addi	a1,a1,1
	call	__udivsi3
	mv	a1,a0
	.LA27: auipc	a0,%pcrel_hi(.LC10)
	mv	a2,s0
	addi	a0,a0,%pcrel_lo(.LA27)
	call	printf
	.LA28: auipc	a0,%pcrel_hi(irq_handler)
	addi	a0,a0,%pcrel_lo(.LA28)
	call	set_mtvec
	li	a0,0
	call	get_mtvec
	sw	a0,16(sp)
	beqz	a0,.L77
	lw	a1,16(sp)
	.LA34: auipc	a0,%pcrel_hi(.LC12)
	addi	a0,a0,%pcrel_lo(.LA34)
	call	printf
	li	a0,1
	call	set_mie
	.LA35: auipc	a0,%pcrel_hi(.LC13)
	addi	a0,a0,%pcrel_lo(.LA35)
	call	printf
.L15:
	.LA38: auipc	a0,%pcrel_hi(.LC15)
	.LA37: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA37)
	li	a4,-128
	addi	a0,a0,%pcrel_lo(.LA38)
	sb	a4,3(a5)
	call	printf
	.LA39: auipc	a0,%pcrel_hi(.LC16)
	addi	a0,a0,%pcrel_lo(.LA39)
	call	printf
.L46:
	.LA40: auipc	a0,%pcrel_hi(.LC17)
	addi	a0,a0,%pcrel_lo(.LA40)
	call	printf
	li	a2,64
	li	a1,0
	addi	a0,sp,52
	call	memset
	lw	a5,16(sp)
	beqz	a5,.L78
.L20:
	li	a1,64
	addi	a0,sp,52
	call	gets
	addi	s1,sp,20
	li	s0,1
	j	.L17
.L79:
	call	strtok
	sw	a0,0(s1)
	li	a5,8
	beqz	a0,.L26
	beq	s0,a5,.L26
.L21:
	addi	s0,s0,1
	addi	s1,s1,4
.L17:
	.LA49: auipc	a1,%pcrel_hi(.LC18)
	li	a5,1
	addi	a1,a1,%pcrel_lo(.LA49)
	li	a0,0
	bne	s0,a5,.L79
	.LA79: auipc	a1,%pcrel_hi(.LC18)
	addi	a1,a1,%pcrel_lo(.LA79)
	addi	a0,sp,52
	call	strtok
	sw	a0,0(s1)
	bnez	a0,.L21
.L26:
	lw	s0,20(sp)
	beqz	s0,.L46
	.LA50: auipc	a1,%pcrel_hi(.LC19)
	addi	a1,a1,%pcrel_lo(.LA50)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L80
	.LA52: auipc	a1,%pcrel_hi(.LC21)
	addi	a1,a1,%pcrel_lo(.LA52)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L74
	.LA55: auipc	a1,%pcrel_hi(.LC24)
	addi	a1,a1,%pcrel_lo(.LA55)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L81
	.LA58: auipc	a1,%pcrel_hi(.LC27)
	addi	a1,a1,%pcrel_lo(.LA58)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L36
	lw	a0,24(sp)
	beqz	a0,.L37
	call	xtoi
	slli	a0,a0,16
	.LA59: auipc	a5,%pcrel_hi(io)
	srli	a0,a0,16
	addi	a5,a5,%pcrel_lo(.LA59)
	sh	a0,8(a5)
.L37:
	.LA60: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA60)
	lhu	a1,8(a5)
	.LA61: auipc	a0,%pcrel_hi(.LC28)
	addi	a0,a0,%pcrel_lo(.LA61)
	call	printf
	j	.L46
.L78:
	li	a2,999424
	li	a1,-128
	addi	a2,a2,575
	j	.L16
.L18:
	lbu	a5,4(a5)
	andi	a5,a5,2
	bnez	a5,.L20
.L16:
	.LA41: auipc	a4,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA41)
	lbu	a4,3(a4)
	.LA48: auipc	a5,%pcrel_hi(io)
	.LA47: auipc	a3,%pcrel_hi(io)
	slli	a4,a4,24
	srai	a4,a4,24
	addi	a5,a5,%pcrel_lo(.LA48)
	addi	a3,a3,%pcrel_lo(.LA47)
	bgez	a4,.L18
	.LA44: auipc	a4,%pcrel_hi(io)
	addi	a0,a4,%pcrel_lo(.LA44)
	.LA42: auipc	a4,%pcrel_hi(utimers)
	lw	t1,%pcrel_lo(.LA42)(a4)
	.LA43: auipc	t0,%pcrel_hi(utimers)
	.LA45: auipc	a4,%pcrel_hi(io)
	addi	t2,t1,-1
	sw	t2,%pcrel_lo(.LA43)(t0)
	addi	a4,a4,%pcrel_lo(.LA45)
	bnez	t1,.L19
	lhu	a0,8(a0)
	addi	a0,a0,1
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,8(a4)
	.LA46: auipc	a4,%pcrel_hi(utimers)
	sw	a2,%pcrel_lo(.LA46)(a4)
.L19:
	sb	a1,3(a3)
	j	.L18
.L80:
	.LA51: auipc	a0,%pcrel_hi(.LC20)
	addi	a0,a0,%pcrel_lo(.LA51)
	call	printf
	j	.L46
.L81:
	lw	a5,24(sp)
	sw	a5,8(sp)
	beqz	a5,.L31
	mv	a0,a5
	call	xtoi
	sw	a0,8(sp)
.L31:
	lw	a5,8(sp)
	addi	s1,a5,16
	addi	a5,a5,256
	sw	a5,12(sp)
.L35:
	lw	a5,8(sp)
	.LA56: auipc	a0,%pcrel_hi(.LC25)
	addi	a0,a0,%pcrel_lo(.LA56)
	mv	a1,a5
	mv	s0,a5
	call	printf
	lw	a5,8(sp)
.L32:
	lbu	a1,0(a5)
	.LA57: auipc	a0,%pcrel_hi(.LC26)
	addi	a5,a5,1
	addi	a0,a0,%pcrel_lo(.LA57)
	sw	a5,4(sp)
	call	printf
	lw	a5,4(sp)
	bne	s1,a5,.L32
.L34:
	lbu	a0,0(s0)
	li	a4,94
	addi	s0,s0,1
	addi	a5,a0,-32
	andi	a5,a5,0xff
	bleu	a5,a4,.L33
	li	a0,46
.L33:
	call	putchar
	bne	s1,s0,.L34
	lw	a5,8(sp)
	li	a0,10
	addi	s1,s1,16
	addi	a5,a5,16
	mv	s0,a5
	sw	a5,8(sp)
	call	putchar
	lw	a4,12(sp)
	bne	a4,s0,.L35
	j	.L46
.L36:
	.LA62: auipc	a1,%pcrel_hi(.LC29)
	addi	a1,a1,%pcrel_lo(.LA62)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L38
	lw	a0,24(sp)
	beqz	a0,.L39
	call	atoi
	.LA63: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA63)
	sw	a0,12(a5)
.L39:
	.LA64: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA64)
	lw	a1,12(a5)
	.LA65: auipc	a0,%pcrel_hi(.LC30)
	addi	a0,a0,%pcrel_lo(.LA65)
	call	printf
	j	.L46
.L74:
	.LA53: auipc	a0,%pcrel_hi(.LC22)
	addi	a0,a0,%pcrel_lo(.LA53)
	li	s0,999424
	call	printf
	addi	a0,s0,576
	call	usleep
	li	a0,46
	call	putchar
	addi	a0,s0,576
	call	usleep
	li	a0,46
	call	putchar
	addi	a0,s0,576
	call	usleep
	li	a0,46
	call	putchar
	.LA54: auipc	a0,%pcrel_hi(.LC23)
	addi	a0,a0,%pcrel_lo(.LA54)
	call	printf
	lw	ra,124(sp)
	lw	s0,120(sp)
	lw	s1,116(sp)
	li	a0,0
	addi	sp,sp,128
	jr	ra
.L38:
	.LA66: auipc	a1,%pcrel_hi(.LC31)
	addi	a1,a1,%pcrel_lo(.LA66)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L40
	lw	a0,24(sp)
	beqz	a0,.L41
	call	xtoi
	slli	a0,a0,16
	.LA67: auipc	a5,%pcrel_hi(io)
	srli	a0,a0,16
	addi	a5,a5,%pcrel_lo(.LA67)
	sh	a0,10(a5)
.L41:
	.LA68: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA68)
	lhu	a1,10(a5)
	.LA69: auipc	a0,%pcrel_hi(.LC32)
	addi	a0,a0,%pcrel_lo(.LA69)
	call	printf
	j	.L46
.L77:
	.LA36: auipc	a0,%pcrel_hi(.LC14)
	addi	a0,a0,%pcrel_lo(.LA36)
	call	printf
	j	.L15
.L40:
	.LA70: auipc	a1,%pcrel_hi(.LC33)
	addi	a1,a1,%pcrel_lo(.LA70)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L42
	lw	a0,24(sp)
	call	atoi
	mv	s0,a0
	lw	a0,28(sp)
	call	atoi
	mv	a1,a0
	mv	a0,s0
	call	__mulsi3
	mv	a1,a0
	.LA71: auipc	a0,%pcrel_hi(.LC34)
	addi	a0,a0,%pcrel_lo(.LA71)
	call	printf
	j	.L46
.L42:
	.LA72: auipc	a1,%pcrel_hi(.LC35)
	addi	a1,a1,%pcrel_lo(.LA72)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L82
	.LA74: auipc	a1,%pcrel_hi(.LC37)
	addi	a1,a1,%pcrel_lo(.LA74)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L44
	lw	a0,24(sp)
	call	atoi
	mv	s0,a0
	lw	a0,28(sp)
	call	atoi
	mv	s1,a0
	lw	a0,32(sp)
	call	atoi
	slli	a2,a0,16
	slli	a1,s1,16
	srai	a2,a2,16
	srai	a1,a1,16
	mv	a0,s0
	call	mac
	mv	a1,a0
	.LA75: auipc	a0,%pcrel_hi(.LC38)
	addi	a0,a0,%pcrel_lo(.LA75)
	call	printf
	j	.L46
.L82:
	lw	a0,24(sp)
	call	atoi
	mv	s0,a0
	lw	a0,28(sp)
	call	atoi
	mv	s1,a0
	mv	a1,a0
	mv	a0,s0
	call	__modsi3
	sw	a0,4(sp)
	mv	a1,s1
	mv	a0,s0
	call	__divsi3
	lw	a2,4(sp)
	mv	a1,a0
	.LA73: auipc	a0,%pcrel_hi(.LC36)
	addi	a0,a0,%pcrel_lo(.LA73)
	call	printf
	j	.L46
.L44:
	.LA76: auipc	a1,%pcrel_hi(.LC39)
	addi	a1,a1,%pcrel_lo(.LA76)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L83
	lbu	a5,0(s0)
	beqz	a5,.L46
	.LA78: auipc	a0,%pcrel_hi(.LC41)
	mv	a1,s0
	addi	a0,a0,%pcrel_lo(.LA78)
	call	printf
	j	.L46
.L83:
	lw	a0,24(sp)
	call	xtoi
	mv	a1,a0
	.LA77: auipc	a0,%pcrel_hi(.LC40)
	srai	a2,a1,1
	addi	a0,a0,%pcrel_lo(.LA77)
	call	printf
	j	.L46
	.size	main, .-main
	.globl	lalala
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"i"
	.zero	2
.LC1:
	.string	"e"
	.zero	2
.LC2:
	.string	"+MT"
.LC3:
	.string	""
	.zero	3
.LC4:
	.string	"+MAC"
	.zero	3
.LC5:
	.string	"board: %s (id=%d)\n"
	.zero	1
.LC6:
	.string	"rv32e"
	.zero	2
.LC7:
	.string	"Sat, 06 Nov 2021 14:57:50 -0300"
.LC8:
	.string	"build: %s for %s\n"
	.zero	2
.LC9:
	.string	"uart0: 115200 bps (div=%d)\n"
.LC10:
	.string	"timr0: frequency=%dHz (io.timer=%d)\n"
	.zero	3
.LC11:
	.string	"core0/thread%d: darkriscv@%d.%dMHz rv32%s%s%s\n"
	.zero	1
.LC12:
	.string	"mtvec: handler@%x, enabling interrupts...\n"
	.zero	1
.LC13:
	.string	"mtvec: interrupts enabled!\n"
.LC14:
	.string	"mtvec: not found (polling only)\n"
	.zero	3
.LC15:
	.string	"\n"
	.zero	2
.LC16:
	.string	"Welcome to DarkRISCV!\n"
	.zero	1
.LC17:
	.string	"> "
	.zero	1
.LC18:
	.string	" "
	.zero	2
.LC19:
	.string	"clear"
	.zero	2
.LC20:
	.string	"\033[H\033[2J"
.LC21:
	.string	"reboot"
	.zero	1
.LC22:
	.string	"core0: reboot in 3 seconds"
	.zero	1
.LC23:
	.string	"done.\n"
	.zero	1
.LC24:
	.string	"dump"
	.zero	3
.LC25:
	.string	"%x: "
	.zero	3
.LC26:
	.string	"%x "
.LC27:
	.string	"led"
.LC28:
	.string	"led = %x\n"
	.zero	2
.LC29:
	.string	"timer"
	.zero	2
.LC30:
	.string	"timer = %d\n"
.LC31:
	.string	"gpio"
	.zero	3
.LC32:
	.string	"gpio = %x\n"
	.zero	1
.LC33:
	.string	"mul"
.LC34:
	.string	"mul = %d\n"
	.zero	2
.LC35:
	.string	"div"
.LC36:
	.string	"div = %d, mod = %d\n"
.LC37:
	.string	"mac"
.LC38:
	.string	"mac = %d\n"
	.zero	2
.LC39:
	.string	"srai"
	.zero	3
.LC40:
	.string	"srai %x >> 1 = %x\n"
	.zero	1
.LC41:
	.string	"command: [%s] not found.\nvalid commands: clear, dump <hex>, led <hex>, timer <dec>, gpio <hex>\n                mul <dec> <dec>, div <dec> <dec>, mac <dec> <dec> <dec>\n                rd[m][bwl] <hex> [<hex> when m], wr[m][bwl] <hex> <hex> [<hex> when m]\n"
	.section	.sdata,"aw"
	.align	2
	.type	lalala, @object
	.size	lalala, 4
lalala:
	.word	-559038737
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
