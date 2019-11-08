	.file	"main.c"
	.option nopic
	.text
	.globl	__mulsi3
	.globl	__udivsi3
	.globl	__modsi3
	.globl	__divsi3
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	.LA4: auipc	a5,%pcrel_hi(io)
	lbu	a0,%pcrel_lo(.LA4)(a5)
	addi	sp,sp,-128
	sw	ra,124(sp)
	sw	s0,120(sp)
	sw	s1,116(sp)
	call	board_name
	.LA5: auipc	a5,%pcrel_hi(io)
	lbu	a2,%pcrel_lo(.LA5)(a5)
	mv	a1,a0
	.LA6: auipc	a0,%pcrel_hi(.LC3)
	addi	a0,a0,%pcrel_lo(.LA6)
	call	printf
	.LA7: auipc	a1,%pcrel_hi(.LC4)
	.LA8: auipc	a0,%pcrel_hi(.LC5)
	addi	a1,a1,%pcrel_lo(.LA7)
	addi	a0,a0,%pcrel_lo(.LA8)
	call	printf
	.LA9: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA9)
	lbu	s0,1(a5)
	.LA10: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA10)
	lbu	s1,2(a5)
	.LA11: auipc	a5,%pcrel_hi(threads)
	lw	a3,%pcrel_lo(.LA11)(a5)
	.LA1: auipc	a4,%pcrel_hi(.LC1)
	li	a5,1
	andi	s0,s0,0xff
	andi	s1,s1,0xff
	addi	a4,a4,%pcrel_lo(.LA1)
	ble	a3,a5,.L2
	.LA0: auipc	a4,%pcrel_hi(.LC0)
	addi	a4,a4,%pcrel_lo(.LA0)
.L2:
	li	a2,16
	li	a1,16
	li	a0,1000
	sw	a4,0(sp)
	call	mac
	.LA2: auipc	a5,%pcrel_hi(.LC2)
	li	a3,1256
	addi	a5,a5,%pcrel_lo(.LA2)
	lw	a4,0(sp)
	beq	a0,a3,.L3
	.LA3: auipc	a5,%pcrel_hi(.LC1)
	addi	a5,a5,%pcrel_lo(.LA3)
.L3:
	.LA12: auipc	a3,%pcrel_hi(.LC6)
	.LA13: auipc	a0,%pcrel_hi(.LC7)
	addi	a3,a3,%pcrel_lo(.LA12)
	mv	a2,s1
	mv	a1,s0
	addi	a0,a0,%pcrel_lo(.LA13)
	call	printf
	.LA14: auipc	a5,%pcrel_hi(threads)
	sw	zero,%pcrel_lo(.LA14)(a5)
	.LA15: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA15)
	lhu	a1,6(a5)
	.LA16: auipc	a0,%pcrel_hi(.LC8)
	addi	a0,a0,%pcrel_lo(.LA16)
	call	printf
	.LA17: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA17)
	lbu	a0,1(a5)
	.LA18: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA18)
	lbu	a5,2(a5)
	li	a1,999424
	addi	a1,a1,576
	andi	s0,a5,0xff
	.LA19: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA19)
	lw	s1,12(a5)
	.LA20: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA20)
	lw	a2,12(a5)
	sw	a2,0(sp)
	call	__mulsi3
	slli	a5,s0,5
	sub	a5,a5,s0
	slli	a5,a5,2
	add	a5,a5,s0
	slli	a5,a5,3
	add	a0,a0,a5
	addi	a1,s1,1
	call	__udivsi3
	lw	a2,0(sp)
	mv	a1,a0
	.LA21: auipc	a0,%pcrel_hi(.LC9)
	addi	a0,a0,%pcrel_lo(.LA21)
	call	printf
	li	a0,10
	call	putchar
	.LA22: auipc	a0,%pcrel_hi(.LC10)
	addi	a0,a0,%pcrel_lo(.LA22)
	call	puts
.L38:
	.LA23: auipc	a0,%pcrel_hi(.LC11)
	addi	a0,a0,%pcrel_lo(.LA23)
	call	printf
	li	a2,64
	li	a1,0
	addi	a0,sp,52
	call	memset
	li	a1,64
	addi	a0,sp,52
	call	gets
	li	s0,0
	addi	a0,sp,52
.L4:
	.LA24: auipc	a1,%pcrel_hi(.LC12)
	addi	a1,a1,%pcrel_lo(.LA24)
	call	strtok
	slli	a5,s0,2
	addi	a4,sp,20
	add	a5,a4,a5
	sw	a0,0(a5)
	beqz	a0,.L5
	addi	s0,s0,1
	li	a5,8
	li	a0,0
	bne	s0,a5,.L4
.L5:
	lw	s0,20(sp)
	beqz	s0,.L38
	.LA25: auipc	a1,%pcrel_hi(.LC13)
	addi	a1,a1,%pcrel_lo(.LA25)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L9
	.LA26: auipc	a0,%pcrel_hi(.LC14)
	addi	a0,a0,%pcrel_lo(.LA26)
	call	printf
	j	.L38
.L9:
	.LA27: auipc	a1,%pcrel_hi(.LC15)
	addi	a1,a1,%pcrel_lo(.LA27)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L10
	.LA28: auipc	a0,%pcrel_hi(.LC16)
	addi	a0,a0,%pcrel_lo(.LA28)
	call	printf
	lw	ra,124(sp)
	lw	s0,120(sp)
	lw	s1,116(sp)
	addi	sp,sp,128
	jr	ra
.L10:
	.LA29: auipc	a1,%pcrel_hi(.LC17)
	addi	a1,a1,%pcrel_lo(.LA29)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L11
	lw	s1,24(sp)
	beqz	s1,.L12
	mv	a0,s1
	call	xtoi
	mv	s1,a0
.L12:
	addi	a5,s1,256
	sw	a5,0(sp)
	li	s0,16
.L16:
	.LA30: auipc	a0,%pcrel_hi(.LC18)
	mv	a1,s1
	addi	a0,a0,%pcrel_lo(.LA30)
	call	printf
	li	a4,0
.L13:
	add	a3,s1,a4
	lbu	a1,0(a3)
	.LA31: auipc	a0,%pcrel_hi(.LC19)
	addi	a0,a0,%pcrel_lo(.LA31)
	sw	a4,4(sp)
	call	printf
	lw	a4,4(sp)
	addi	a4,a4,1
	bne	a4,s0,.L13
	li	a4,0
.L15:
	add	a3,s1,a4
	lbu	a0,0(a3)
	li	a2,94
	addi	a3,a0,-32
	andi	a3,a3,0xff
	bleu	a3,a2,.L14
	li	a0,46
.L14:
	sw	a4,4(sp)
	call	putchar
	lw	a4,4(sp)
	addi	a4,a4,1
	bne	a4,s0,.L15
	li	a0,10
	call	putchar
	lw	a5,0(sp)
	addi	s1,s1,16
	bne	s1,a5,.L16
	j	.L38
.L11:
	.LA32: auipc	a1,%pcrel_hi(.LC20)
	li	a2,2
	addi	a1,a1,%pcrel_lo(.LA32)
	mv	a0,s0
	call	strncmp
	beqz	a0,.L18
	.LA33: auipc	a1,%pcrel_hi(.LC21)
	li	a2,2
	addi	a1,a1,%pcrel_lo(.LA33)
	mv	a0,s0
	call	strncmp
	bnez	a0,.L19
.L18:
	lbu	a4,2(s0)
	li	a5,109
	bne	a4,a5,.L41
	lw	a0,24(sp)
	call	xtoi
	sw	a0,12(sp)
	li	a5,2
	li	a4,3
.L20:
	sw	a4,4(sp)
	addi	a4,a5,1
	sw	a4,8(sp)
	slli	a5,a5,2
	addi	a4,sp,116
	add	a5,a4,a5
	lw	a0,-96(a5)
	li	s1,0
	call	xtoi
	sw	a0,0(sp)
	mv	a1,a0
	.LA34: auipc	a0,%pcrel_hi(.LC18)
	addi	a0,a0,%pcrel_lo(.LA34)
	call	printf
	lw	a4,4(sp)
	add	a5,s0,a4
	sw	a5,4(sp)
.L21:
	lw	a5,12(sp)
	bne	a5,s1,.L28
	li	a0,10
	call	putchar
	j	.L38
.L41:
	li	a4,1
	sw	a4,12(sp)
	li	a5,1
	li	a4,2
	j	.L20
.L28:
	lbu	a4,0(s0)
	li	a5,114
	bne	a4,a5,.L22
	lw	a5,4(sp)
	lbu	a4,0(a5)
	li	a5,98
	bne	a4,a5,.L23
	lw	a5,0(sp)
	.LA35: auipc	a0,%pcrel_hi(.LC19)
	addi	a0,a0,%pcrel_lo(.LA35)
	add	a5,a5,s1
	lbu	a1,0(a5)
	call	printf
.L23:
	lw	a5,4(sp)
	lbu	a4,0(a5)
	li	a5,119
	bne	a4,a5,.L24
	lw	a4,0(sp)
	slli	a5,s1,1
	.LA36: auipc	a0,%pcrel_hi(.LC19)
	add	a5,a5,a4
	lh	a1,0(a5)
	addi	a0,a0,%pcrel_lo(.LA36)
	call	printf
.L24:
	lw	a5,4(sp)
	lbu	a4,0(a5)
	li	a5,108
	bne	a4,a5,.L25
	lw	a4,0(sp)
	slli	a5,s1,2
	.LA37: auipc	a0,%pcrel_hi(.LC19)
	add	a5,a5,a4
	lw	a1,0(a5)
	addi	a0,a0,%pcrel_lo(.LA37)
.L68:
	call	printf
.L25:
	addi	s1,s1,1
	j	.L21
.L22:
	lw	a5,8(sp)
	addi	a4,sp,116
	addi	a5,a5,1
	sw	a5,16(sp)
	lw	a5,8(sp)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a0,-96(a5)
	call	xtoi
	lw	a4,4(sp)
	mv	a5,a0
	lbu	a3,0(a4)
	li	a4,98
	bne	a3,a4,.L26
	lw	a4,0(sp)
	andi	a1,a0,0xff
	sw	a0,8(sp)
	add	a4,a4,s1
	sb	a0,0(a4)
	.LA38: auipc	a0,%pcrel_hi(.LC19)
	addi	a0,a0,%pcrel_lo(.LA38)
	call	printf
	lw	a5,8(sp)
.L26:
	lw	a4,4(sp)
	lbu	a3,0(a4)
	li	a4,119
	bne	a3,a4,.L27
	slli	a1,a5,16
	sw	a5,8(sp)
	lw	a5,0(sp)
	slli	a4,s1,1
	srai	a1,a1,16
	add	a4,a4,a5
	.LA39: auipc	a0,%pcrel_hi(.LC19)
	sh	a1,0(a4)
	addi	a0,a0,%pcrel_lo(.LA39)
	call	printf
	lw	a5,8(sp)
.L27:
	lw	a4,4(sp)
	lw	a2,16(sp)
	lbu	a3,0(a4)
	sw	a2,8(sp)
	li	a4,108
	bne	a3,a4,.L25
	lw	a3,0(sp)
	slli	a4,s1,2
	.LA40: auipc	a0,%pcrel_hi(.LC19)
	add	a4,a4,a3
	sw	a5,0(a4)
	mv	a1,a5
	addi	a0,a0,%pcrel_lo(.LA40)
	j	.L68
.L19:
	.LA41: auipc	a1,%pcrel_hi(.LC22)
	addi	a1,a1,%pcrel_lo(.LA41)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L29
	lw	a0,24(sp)
	beqz	a0,.L30
	call	xtoi
	slli	a0,a0,16
	.LA42: auipc	a5,%pcrel_hi(io)
	srli	a0,a0,16
	addi	a5,a5,%pcrel_lo(.LA42)
	sh	a0,8(a5)
.L30:
	.LA43: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA43)
	lhu	a1,8(a5)
	.LA44: auipc	a0,%pcrel_hi(.LC23)
	addi	a0,a0,%pcrel_lo(.LA44)
.L67:
	call	printf
	j	.L38
.L29:
	.LA45: auipc	a1,%pcrel_hi(.LC24)
	addi	a1,a1,%pcrel_lo(.LA45)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L31
	lw	a0,24(sp)
	beqz	a0,.L32
	call	atoi
	.LA46: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA46)
	sw	a0,12(a5)
.L32:
	.LA47: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA47)
	.LA48: auipc	a0,%pcrel_hi(.LC25)
	lw	a1,12(a5)
	addi	a0,a0,%pcrel_lo(.LA48)
	j	.L67
.L31:
	.LA49: auipc	a1,%pcrel_hi(.LC26)
	addi	a1,a1,%pcrel_lo(.LA49)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L33
	lw	a0,24(sp)
	beqz	a0,.L34
	call	xtoi
	slli	a0,a0,16
	.LA50: auipc	a5,%pcrel_hi(io)
	srli	a0,a0,16
	addi	a5,a5,%pcrel_lo(.LA50)
	sh	a0,10(a5)
.L34:
	.LA51: auipc	a5,%pcrel_hi(io)
	addi	a5,a5,%pcrel_lo(.LA51)
	.LA52: auipc	a0,%pcrel_hi(.LC27)
	lhu	a1,10(a5)
	addi	a0,a0,%pcrel_lo(.LA52)
	j	.L67
.L33:
	.LA53: auipc	a1,%pcrel_hi(.LC28)
	addi	a1,a1,%pcrel_lo(.LA53)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L35
	lw	a0,24(sp)
	call	atoi
	mv	s0,a0
	lw	a0,28(sp)
	call	atoi
	mv	a1,a0
	mv	a0,s0
	call	__mulsi3
	mv	a1,a0
	.LA54: auipc	a0,%pcrel_hi(.LC29)
	addi	a0,a0,%pcrel_lo(.LA54)
	j	.L67
.L35:
	.LA55: auipc	a1,%pcrel_hi(.LC30)
	addi	a1,a1,%pcrel_lo(.LA55)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L36
	lw	a0,24(sp)
	call	atoi
	mv	s0,a0
	lw	a0,28(sp)
	call	atoi
	mv	s1,a0
	mv	a1,a0
	mv	a0,s0
	call	__modsi3
	sw	a0,0(sp)
	mv	a1,s1
	mv	a0,s0
	call	__divsi3
	lw	a2,0(sp)
	mv	a1,a0
	.LA56: auipc	a0,%pcrel_hi(.LC31)
	addi	a0,a0,%pcrel_lo(.LA56)
	call	printf
	j	.L38
.L36:
	.LA57: auipc	a1,%pcrel_hi(.LC32)
	addi	a1,a1,%pcrel_lo(.LA57)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L37
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
	srai	a1,a1,16
	srai	a2,a2,16
	mv	a0,s0
	call	mac
	mv	a1,a0
	.LA58: auipc	a0,%pcrel_hi(.LC33)
	addi	a0,a0,%pcrel_lo(.LA58)
	j	.L67
.L37:
	lbu	a5,0(s0)
	beqz	a5,.L38
	.LA59: auipc	a0,%pcrel_hi(.LC34)
	mv	a1,s0
	addi	a0,a0,%pcrel_lo(.LA59)
	j	.L67
	.size	main, .-main
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"+MT"
.LC1:
	.string	""
	.zero	3
.LC2:
	.string	"+MAC"
	.zero	3
.LC3:
	.string	"board: %s (id=%d)\n"
	.zero	1
.LC4:
	.string	"Fri, 08 Nov 2019 12:54:33 -0300"
.LC5:
	.string	"build: darkriscv fw build %s\n"
	.zero	2
.LC6:
	.string	"rv32e"
	.zero	2
.LC7:
	.string	"core0: darkriscv@%d.%dMHz with %s%s%s\n"
	.zero	1
.LC8:
	.string	"uart0: 115200 bps (div=%d)\n"
.LC9:
	.string	"timr0: periodic timer=%dHz (io.timer=%d)\n"
	.zero	2
.LC10:
	.string	"Welcome to DarkRISCV!"
	.zero	2
.LC11:
	.string	"> "
	.zero	1
.LC12:
	.string	" "
	.zero	2
.LC13:
	.string	"clear"
	.zero	2
.LC14:
	.string	"\033[H\033[2J"
.LC15:
	.string	"atros"
	.zero	2
.LC16:
	.string	"wow! hello atros! o/\n\n"
	.zero	1
.LC17:
	.string	"dump"
	.zero	3
.LC18:
	.string	"%x: "
	.zero	3
.LC19:
	.string	"%x "
.LC20:
	.string	"rd"
	.zero	1
.LC21:
	.string	"wr"
	.zero	1
.LC22:
	.string	"led"
.LC23:
	.string	"led = %x\n"
	.zero	2
.LC24:
	.string	"timer"
	.zero	2
.LC25:
	.string	"timer = %d\n"
.LC26:
	.string	"gpio"
	.zero	3
.LC27:
	.string	"gpio = %x\n"
	.zero	1
.LC28:
	.string	"mul"
.LC29:
	.string	"mul = %d\n"
	.zero	2
.LC30:
	.string	"div"
.LC31:
	.string	"div = %d, mod = %d\n"
.LC32:
	.string	"mac"
.LC33:
	.string	"mac = %d\n"
	.zero	2
.LC34:
	.string	"command: [%s] not found.\nvalid commands: clear, dump <hex>, led <hex>, timer <dec>, gpio <hex>\n                mul <dec> <dec>, div <dec> <dec>, mac <dec> <dec> <dec>\n                rd[m][bwl] <hex> [<hex> when m], wr[m][bwl] <hex> <hex> [<hex> when m]\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
