	.file	"main.c"
	.option nopic
	.text
	.globl	__udivsi3
	.globl	__mulsi3
	.globl	__modsi3
	.globl	__divsi3
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	.LA6: auipc	a5,%pcrel_hi(io)
	lbu	a0,%pcrel_lo(.LA6)(a5)
	addi	sp,sp,-124
	sw	ra,120(sp)
	sw	s0,116(sp)
	sw	s1,112(sp)
	call	board_name
	.LA7: auipc	a5,%pcrel_hi(io)
	lbu	a2,%pcrel_lo(.LA7)(a5)
	mv	a1,a0
	.LA8: auipc	a0,%pcrel_hi(.LC5)
	addi	a0,a0,%pcrel_lo(.LA8)
	call	printf
	.LA9: auipc	a2,%pcrel_hi(.LC6)
	.LA10: auipc	a1,%pcrel_hi(.LC7)
	.LA11: auipc	a0,%pcrel_hi(.LC8)
	addi	a2,a2,%pcrel_lo(.LA9)
	addi	a1,a1,%pcrel_lo(.LA10)
	addi	a0,a0,%pcrel_lo(.LA11)
	call	printf
	.LA12: auipc	a5,%pcrel_hi(threads)
	lw	a5,%pcrel_lo(.LA12)(a5)
	li	s0,0
	beqz	a5,.L7
.L2:
	.LA23: auipc	a4,%pcrel_hi(io)
	.LA24: auipc	a5,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA23)
	addi	a5,a5,%pcrel_lo(.LA24)
	lbu	s1,1(a4)
	lbu	a5,2(a5)
	.LA0: auipc	a4,%pcrel_hi(.LC0)
	sw	a4,8(sp)
	andi	a5,a5,0xff
	sw	a5,4(sp)
	call	check4rv32i
	.LA25: auipc	a5,%pcrel_hi(threads)
	lw	a4,8(sp)
	lw	a3,%pcrel_lo(.LA25)(a5)
	andi	s1,s1,0xff
	li	a2,16
	li	a1,16
	.LA2: auipc	a5,%pcrel_hi(.LC2)
	addi	a4,a4,%pcrel_lo(.LA0)
	bnez	a0,.L4
	.LA1: auipc	a4,%pcrel_hi(.LC1)
	addi	a4,a4,%pcrel_lo(.LA1)
.L4:
	li	t1,1
	li	a0,1000
	addi	a5,a5,%pcrel_lo(.LA2)
	bgt	a3,t1,.L5
	.LA3: auipc	a5,%pcrel_hi(.LC3)
	addi	a5,a5,%pcrel_lo(.LA3)
.L5:
	sw	a5,12(sp)
	sw	a4,8(sp)
	call	mac
	.LA4: auipc	t1,%pcrel_hi(.LC4)
	li	t0,1256
	mv	a1,s0
	lw	a5,12(sp)
	lw	a4,8(sp)
	lw	a3,4(sp)
	mv	a2,s1
	addi	s0,s0,1
	addi	t1,t1,%pcrel_lo(.LA4)
	beq	a0,t0,.L6
	.LA5: auipc	t1,%pcrel_hi(.LC3)
	addi	t1,t1,%pcrel_lo(.LA5)
.L6:
	.LA26: auipc	a0,%pcrel_hi(.LC13)
	sw	t1,0(sp)
	addi	a0,a0,%pcrel_lo(.LA26)
	call	printf
	.LA27: auipc	a5,%pcrel_hi(threads)
	lw	a5,%pcrel_lo(.LA27)(a5)
	bne	a5,s0,.L2
.L7:
	.LA13: auipc	a5,%pcrel_hi(threads)
	sw	zero,%pcrel_lo(.LA13)(a5)
	.LA14: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA14)
	lhu	a1,6(a5)
	.LA15: auipc	a0,%pcrel_hi(.LC9)
	addi	a0,a0,%pcrel_lo(.LA15)
	call	printf
	.LA16: auipc	a4,%pcrel_hi(io)
	.LA17: auipc	a5,%pcrel_hi(io)
	addi	a4,a4,%pcrel_lo(.LA16)
	addi	a5,a5,%pcrel_lo(.LA17)
	lbu	t1,1(a4)
	lbu	a4,2(a5)
	.LA18: auipc	a2,%pcrel_hi(io)
	slli	a3,t1,5
	slli	a5,a4,2
	sub	a3,a3,t1
	add	a5,a5,a4
	slli	a0,a3,6
	slli	a5,a5,3
	sub	a5,a5,a4
	addi	a2,a2,%pcrel_lo(.LA18)
	sub	a0,a0,a3
	lw	a1,12(a2)
	slli	a0,a0,3
	slli	a5,a5,4
	add	a0,a0,t1
	add	a5,a5,a4
	.LA19: auipc	a3,%pcrel_hi(io)
	addi	a3,a3,%pcrel_lo(.LA19)
	slli	a5,a5,4
	slli	a0,a0,6
	lw	s0,12(a3)
	add	a0,a0,a5
	addi	a1,a1,1
	call	__udivsi3
	mv	a1,a0
	.LA20: auipc	a0,%pcrel_hi(.LC10)
	mv	a2,s0
	addi	a0,a0,%pcrel_lo(.LA20)
	call	printf
	.LA21: auipc	a0,%pcrel_hi(.LC11)
	addi	a0,a0,%pcrel_lo(.LA21)
	call	printf
	.LA22: auipc	a0,%pcrel_hi(.LC12)
	addi	a0,a0,%pcrel_lo(.LA22)
	call	printf
.L3:
	.LA28: auipc	a0,%pcrel_hi(.LC14)
	addi	a0,a0,%pcrel_lo(.LA28)
	call	printf
	li	a2,64
	li	a1,0
	addi	a0,sp,48
	call	memset
	li	a1,64
	addi	a0,sp,48
	call	gets
	addi	s1,sp,16
	li	s0,1
	j	.L8
.L63:
	call	strtok
	sw	a0,0(s1)
	li	a5,8
	beqz	a0,.L14
	beq	s0,a5,.L14
.L9:
	addi	s0,s0,1
	addi	s1,s1,4
.L8:
	.LA29: auipc	a1,%pcrel_hi(.LC15)
	li	a5,1
	addi	a1,a1,%pcrel_lo(.LA29)
	li	a0,0
	bne	s0,a5,.L63
	.LA59: auipc	a1,%pcrel_hi(.LC15)
	addi	a1,a1,%pcrel_lo(.LA59)
	addi	a0,sp,48
	call	strtok
	sw	a0,0(s1)
	bnez	a0,.L9
.L14:
	lw	s0,16(sp)
	beqz	s0,.L3
	.LA30: auipc	a1,%pcrel_hi(.LC16)
	addi	a1,a1,%pcrel_lo(.LA30)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L64
	.LA32: auipc	a1,%pcrel_hi(.LC18)
	addi	a1,a1,%pcrel_lo(.LA32)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L59
	.LA35: auipc	a1,%pcrel_hi(.LC21)
	addi	a1,a1,%pcrel_lo(.LA35)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L65
	.LA38: auipc	a1,%pcrel_hi(.LC24)
	addi	a1,a1,%pcrel_lo(.LA38)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L24
	lw	a0,20(sp)
	beqz	a0,.L25
	call	xtoi
	slli	a0,a0,16
	.LA39: auipc	a5,%pcrel_hi(io)
	srli	a0,a0,16
	addi	a5,a5,%pcrel_lo(.LA39)
	sh	a0,8(a5)
.L25:
	.LA40: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA40)
	lhu	a1,8(a5)
	.LA41: auipc	a0,%pcrel_hi(.LC25)
	addi	a0,a0,%pcrel_lo(.LA41)
	call	printf
	j	.L3
.L64:
	.LA31: auipc	a0,%pcrel_hi(.LC17)
	addi	a0,a0,%pcrel_lo(.LA31)
	call	printf
	j	.L3
.L65:
	lw	a5,20(sp)
	sw	a5,8(sp)
	beqz	a5,.L19
	mv	a0,a5
	call	xtoi
	sw	a0,8(sp)
.L19:
	lw	a5,8(sp)
	addi	s1,a5,16
	addi	a5,a5,256
	sw	a5,12(sp)
.L23:
	lw	a5,8(sp)
	.LA36: auipc	a0,%pcrel_hi(.LC22)
	addi	a0,a0,%pcrel_lo(.LA36)
	mv	a1,a5
	mv	s0,a5
	call	printf
	lw	a5,8(sp)
.L20:
	lbu	a1,0(a5)
	.LA37: auipc	a0,%pcrel_hi(.LC23)
	addi	a5,a5,1
	addi	a0,a0,%pcrel_lo(.LA37)
	sw	a5,4(sp)
	call	printf
	lw	a5,4(sp)
	bne	s1,a5,.L20
.L22:
	lbu	a0,0(s0)
	li	a4,94
	addi	s0,s0,1
	addi	a5,a0,-32
	andi	a5,a5,0xff
	bleu	a5,a4,.L21
	li	a0,46
.L21:
	call	putchar
	bne	s1,s0,.L22
	lw	a5,8(sp)
	li	a0,10
	addi	s1,s1,16
	addi	a5,a5,16
	mv	s0,a5
	sw	a5,8(sp)
	call	putchar
	lw	a4,12(sp)
	bne	s0,a4,.L23
	j	.L3
.L24:
	.LA42: auipc	a1,%pcrel_hi(.LC26)
	addi	a1,a1,%pcrel_lo(.LA42)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L26
	lw	a0,20(sp)
	beqz	a0,.L27
	call	atoi
	.LA43: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA43)
	sw	a0,12(a5)
.L27:
	.LA44: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA44)
	lw	a1,12(a5)
	.LA45: auipc	a0,%pcrel_hi(.LC27)
	addi	a0,a0,%pcrel_lo(.LA45)
	call	printf
	j	.L3
.L59:
	.LA33: auipc	a0,%pcrel_hi(.LC19)
	addi	a0,a0,%pcrel_lo(.LA33)
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
	.LA34: auipc	a0,%pcrel_hi(.LC20)
	addi	a0,a0,%pcrel_lo(.LA34)
	call	printf
	lw	ra,120(sp)
	lw	s0,116(sp)
	lw	s1,112(sp)
	li	a0,0
	addi	sp,sp,124
	jr	ra
.L26:
	.LA46: auipc	a1,%pcrel_hi(.LC28)
	addi	a1,a1,%pcrel_lo(.LA46)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L28
	lw	a0,20(sp)
	beqz	a0,.L29
	call	xtoi
	slli	a0,a0,16
	.LA47: auipc	a5,%pcrel_hi(io)
	srli	a0,a0,16
	addi	a5,a5,%pcrel_lo(.LA47)
	sh	a0,10(a5)
.L29:
	.LA48: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA48)
	lhu	a1,10(a5)
	.LA49: auipc	a0,%pcrel_hi(.LC29)
	addi	a0,a0,%pcrel_lo(.LA49)
	call	printf
	j	.L3
.L28:
	.LA50: auipc	a1,%pcrel_hi(.LC30)
	addi	a1,a1,%pcrel_lo(.LA50)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L30
	lw	a0,20(sp)
	call	atoi
	mv	s0,a0
	lw	a0,24(sp)
	call	atoi
	mv	a1,a0
	mv	a0,s0
	call	__mulsi3
	mv	a1,a0
	.LA51: auipc	a0,%pcrel_hi(.LC31)
	addi	a0,a0,%pcrel_lo(.LA51)
	call	printf
	j	.L3
.L30:
	.LA52: auipc	a1,%pcrel_hi(.LC32)
	addi	a1,a1,%pcrel_lo(.LA52)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L66
	.LA54: auipc	a1,%pcrel_hi(.LC34)
	addi	a1,a1,%pcrel_lo(.LA54)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L32
	lw	a0,20(sp)
	call	atoi
	mv	s0,a0
	lw	a0,24(sp)
	call	atoi
	mv	s1,a0
	lw	a0,28(sp)
	call	atoi
	slli	a2,a0,16
	slli	a1,s1,16
	srai	a2,a2,16
	srai	a1,a1,16
	mv	a0,s0
	call	mac
	mv	a1,a0
	.LA55: auipc	a0,%pcrel_hi(.LC35)
	addi	a0,a0,%pcrel_lo(.LA55)
	call	printf
	j	.L3
.L66:
	lw	a0,20(sp)
	call	atoi
	mv	s0,a0
	lw	a0,24(sp)
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
	.LA53: auipc	a0,%pcrel_hi(.LC33)
	addi	a0,a0,%pcrel_lo(.LA53)
	call	printf
	j	.L3
.L32:
	.LA56: auipc	a1,%pcrel_hi(.LC36)
	addi	a1,a1,%pcrel_lo(.LA56)
	mv	a0,s0
	call	strcmp
	beqz	a0,.L67
	lbu	a5,0(s0)
	beqz	a5,.L3
	.LA58: auipc	a0,%pcrel_hi(.LC38)
	mv	a1,s0
	addi	a0,a0,%pcrel_lo(.LA58)
	call	printf
	j	.L3
.L67:
	lw	a0,20(sp)
	call	xtoi
	mv	a1,a0
	.LA57: auipc	a0,%pcrel_hi(.LC37)
	srai	a2,a1,1
	addi	a0,a0,%pcrel_lo(.LA57)
	call	printf
	j	.L3
	.size	main, .-main
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
	.string	"Mon, 01 Feb 2021 04:06:48 -0300"
.LC8:
	.string	"build: %s for %s\n"
	.zero	2
.LC9:
	.string	"uart0: 115200 bps (div=%d)\n"
.LC10:
	.string	"timr0: frequency=%dHz (io.timer=%d)\n"
	.zero	3
.LC11:
	.string	"\n"
	.zero	2
.LC12:
	.string	"Welcome to DarkRISCV!\n"
	.zero	1
.LC13:
	.string	"core0/thread%d: darkriscv@%d.%dMHz rv32%s%s%s\n"
	.zero	1
.LC14:
	.string	"> "
	.zero	1
.LC15:
	.string	" "
	.zero	2
.LC16:
	.string	"clear"
	.zero	2
.LC17:
	.string	"\033[H\033[2J"
.LC18:
	.string	"reboot"
	.zero	1
.LC19:
	.string	"core0: reboot in 3 seconds"
	.zero	1
.LC20:
	.string	"done.\n"
	.zero	1
.LC21:
	.string	"dump"
	.zero	3
.LC22:
	.string	"%x: "
	.zero	3
.LC23:
	.string	"%x "
.LC24:
	.string	"led"
.LC25:
	.string	"led = %x\n"
	.zero	2
.LC26:
	.string	"timer"
	.zero	2
.LC27:
	.string	"timer = %d\n"
.LC28:
	.string	"gpio"
	.zero	3
.LC29:
	.string	"gpio = %x\n"
	.zero	1
.LC30:
	.string	"mul"
.LC31:
	.string	"mul = %d\n"
	.zero	2
.LC32:
	.string	"div"
.LC33:
	.string	"div = %d, mod = %d\n"
.LC34:
	.string	"mac"
.LC35:
	.string	"mac = %d\n"
	.zero	2
.LC36:
	.string	"srai"
	.zero	3
.LC37:
	.string	"srai %x >> 1 = %x\n"
	.zero	1
.LC38:
	.string	"command: [%s] not found.\nvalid commands: clear, dump <hex>, led <hex>, timer <dec>, gpio <hex>\n                mul <dec> <dec>, div <dec> <dec>, mac <dec> <dec> <dec>\n                rd[m][bwl] <hex> [<hex> when m], wr[m][bwl] <hex> <hex> [<hex> when m]\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
