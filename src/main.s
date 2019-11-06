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
	addi	sp,sp,-136
	sw	ra,132(sp)
	sw	s0,128(sp)
	sw	s1,124(sp)
	lui	s0,%hi(io)
	call	banner
	lbu	a5,%lo(io)(s0)
	lui	a4,%hi(board_name)
	addi	a4,a4,%lo(board_name)
	slli	a5,a5,2
	add	a5,a5,a4
	lbu	a2,%lo(io)(s0)
	lw	a1,0(a5)
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	printf
	lui	a1,%hi(.LC4)
	lui	a0,%hi(.LC5)
	addi	a1,a1,%lo(.LC4)
	addi	a0,a0,%lo(.LC5)
	call	printf
	addi	a5,s0,%lo(io)
	lbu	s1,1(a5)
	lbu	t1,2(a5)
	lui	a5,%hi(threads)
	lw	a3,%lo(threads)(a5)
	addi	a2,s0,%lo(io)
	li	a4,1
	sw	a2,0(sp)
	andi	s1,s1,0xff
	andi	t1,t1,0xff
	mv	s0,a5
	bgt	a3,a4,.L39
	lui	a4,%hi(.LC1)
	addi	a4,a4,%lo(.LC1)
.L2:
	li	a2,16
	li	a1,16
	li	a0,1000
	sw	a4,8(sp)
	sw	t1,4(sp)
	call	mac
	li	a5,1256
	lw	t1,4(sp)
	lw	a4,8(sp)
	beq	a0,a5,.L40
	lui	a5,%hi(.LC1)
	addi	a5,a5,%lo(.LC1)
.L3:
	lui	a3,%hi(.LC6)
	lui	a0,%hi(.LC7)
	mv	a2,t1
	addi	a3,a3,%lo(.LC6)
	mv	a1,s1
	addi	a0,a0,%lo(.LC7)
	call	printf
	lw	a5,0(sp)
	lui	a0,%hi(.LC8)
	addi	a0,a0,%lo(.LC8)
	lhu	a1,6(a5)
	sw	zero,%lo(threads)(s0)
	call	printf
	lw	a5,0(sp)
	li	a1,999424
	addi	a1,a1,576
	lbu	a0,1(a5)
	lbu	a5,2(a5)
	andi	s0,a5,0xff
	lw	a5,0(sp)
	lw	s1,12(a5)
	lw	a2,12(a5)
	sw	a2,4(sp)
	call	__mulsi3
	slli	a5,s0,5
	sub	a5,a5,s0
	slli	a5,a5,2
	add	a5,a5,s0
	slli	a5,a5,3
	add	a0,a0,a5
	addi	a1,s1,1
	call	__udivsi3
	lw	a2,4(sp)
	mv	a1,a0
	lui	a0,%hi(.LC9)
	addi	a0,a0,%lo(.LC9)
	call	printf
	li	a0,10
	call	putchar
	lui	a0,%hi(.LC10)
	addi	a0,a0,%lo(.LC10)
.L66:
	call	puts
.L38:
	lui	a5,%hi(.LC11)
	addi	a0,a5,%lo(.LC11)
	call	printf
	li	a2,64
	li	a1,0
	addi	a0,sp,60
	call	memset
	li	a1,64
	addi	a0,sp,60
	call	gets
	li	s0,0
	addi	a0,sp,60
	lui	s1,%hi(.LC12)
.L4:
	addi	a1,s1,%lo(.LC12)
	call	strtok
	slli	a5,s0,2
	addi	a4,sp,124
	add	a5,a4,a5
	sw	a0,-96(a5)
	beqz	a0,.L5
	addi	s0,s0,1
	li	a5,8
	li	a0,0
	bne	s0,a5,.L4
.L5:
	lw	s0,28(sp)
	beqz	s0,.L38
	lui	a1,%hi(.LC13)
	addi	a1,a1,%lo(.LC13)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L9
	lui	a0,%hi(.LC14)
	addi	a0,a0,%lo(.LC14)
	call	printf
	j	.L38
.L39:
	lui	a4,%hi(.LC0)
	addi	a4,a4,%lo(.LC0)
	j	.L2
.L40:
	lui	a5,%hi(.LC2)
	addi	a5,a5,%lo(.LC2)
	j	.L3
.L9:
	lui	a1,%hi(.LC15)
	addi	a1,a1,%lo(.LC15)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L10
	call	banner
	lui	a0,%hi(.LC16)
	addi	a0,a0,%lo(.LC16)
	j	.L66
.L10:
	lui	a1,%hi(.LC17)
	addi	a1,a1,%lo(.LC17)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L11
	lw	s0,32(sp)
	beqz	s0,.L12
	mv	a0,s0
	call	xtoi
	mv	s0,a0
.L12:
	addi	a5,s0,256
	sw	a5,4(sp)
	lui	s1,%hi(.LC18)
.L16:
	mv	a1,s0
	addi	a0,s1,%lo(.LC18)
	call	printf
	li	a4,0
	lui	a2,%hi(.LC19)
.L13:
	add	a3,s0,a4
	lbu	a1,0(a3)
	addi	a0,a2,%lo(.LC19)
	sw	a4,8(sp)
	call	printf
	lw	a4,8(sp)
	li	a3,16
	lui	a2,%hi(.LC19)
	addi	a4,a4,1
	bne	a4,a3,.L13
	li	a4,0
.L15:
	add	a3,s0,a4
	lbu	a0,0(a3)
	li	a2,94
	addi	a3,a0,-32
	andi	a3,a3,0xff
	bleu	a3,a2,.L14
	li	a0,46
.L14:
	sw	a4,8(sp)
	call	putchar
	lw	a4,8(sp)
	li	a3,16
	addi	a4,a4,1
	bne	a4,a3,.L15
	li	a0,10
	call	putchar
	lw	a5,4(sp)
	addi	s0,s0,16
	bne	s0,a5,.L16
	j	.L38
.L11:
	lui	a1,%hi(.LC20)
	li	a2,2
	addi	a1,a1,%lo(.LC20)
	mv	a0,s0
	call	strncmp
	beqz	a0,.L18
	lui	a1,%hi(.LC21)
	li	a2,2
	addi	a1,a1,%lo(.LC21)
	mv	a0,s0
	call	strncmp
	bnez	a0,.L19
.L18:
	lbu	a4,2(s0)
	li	a5,109
	bne	a4,a5,.L41
	lw	a0,32(sp)
	call	xtoi
	sw	a0,20(sp)
	li	a5,2
	li	a4,3
.L67:
	sw	a4,16(sp)
	addi	a4,a5,1
	sw	a4,12(sp)
	slli	a5,a5,2
	addi	a4,sp,124
	add	a5,a4,a5
	lw	a0,-96(a5)
	li	s1,0
	call	xtoi
	sw	a0,4(sp)
	mv	a1,a0
	lui	a0,%hi(.LC18)
	addi	a0,a0,%lo(.LC18)
	call	printf
.L21:
	lw	a5,20(sp)
	bne	a5,s1,.L28
	li	a0,10
	call	putchar
	j	.L38
.L41:
	li	a4,1
	sw	a4,20(sp)
	li	a5,1
	li	a4,2
	j	.L67
.L28:
	lw	a5,16(sp)
	lbu	a4,0(s0)
	add	a5,s0,a5
	sw	a5,8(sp)
	li	a5,114
	bne	a4,a5,.L22
	lw	a5,8(sp)
	lbu	a4,0(a5)
	li	a5,98
	bne	a4,a5,.L23
	lw	a5,4(sp)
	add	a5,a5,s1
	lbu	a1,0(a5)
	lui	a5,%hi(.LC19)
	addi	a0,a5,%lo(.LC19)
	call	printf
.L23:
	lw	a5,8(sp)
	lbu	a4,0(a5)
	li	a5,119
	bne	a4,a5,.L24
	lw	a4,4(sp)
	slli	a5,s1,1
	add	a5,a5,a4
	lh	a1,0(a5)
	lui	a5,%hi(.LC19)
	addi	a0,a5,%lo(.LC19)
	call	printf
.L24:
	lw	a5,8(sp)
	lbu	a4,0(a5)
	li	a5,108
	bne	a4,a5,.L25
	lw	a4,4(sp)
	slli	a5,s1,2
	add	a5,a5,a4
	lw	a1,0(a5)
.L68:
	lui	a5,%hi(.LC19)
	addi	a0,a5,%lo(.LC19)
	call	printf
.L25:
	addi	s1,s1,1
	j	.L21
.L22:
	lw	a5,12(sp)
	addi	a4,sp,124
	addi	a5,a5,1
	sw	a5,24(sp)
	lw	a5,12(sp)
	slli	a5,a5,2
	add	a5,a4,a5
	lw	a0,-96(a5)
	call	xtoi
	lw	a4,8(sp)
	mv	a5,a0
	lbu	a3,0(a4)
	li	a4,98
	bne	a3,a4,.L26
	lw	a4,4(sp)
	lui	a5,%hi(.LC19)
	andi	a1,a0,0xff
	add	a4,a4,s1
	sb	a0,0(a4)
	sw	a0,12(sp)
	addi	a0,a5,%lo(.LC19)
	call	printf
	lw	a5,12(sp)
.L26:
	lw	a4,8(sp)
	lbu	a3,0(a4)
	li	a4,119
	bne	a3,a4,.L27
	slli	a1,a5,16
	sw	a5,12(sp)
	lw	a5,4(sp)
	slli	a4,s1,1
	srai	a1,a1,16
	add	a4,a4,a5
	lui	a5,%hi(.LC19)
	addi	a0,a5,%lo(.LC19)
	sh	a1,0(a4)
	call	printf
	lw	a5,12(sp)
.L27:
	lw	a4,8(sp)
	lw	a2,24(sp)
	lbu	a3,0(a4)
	sw	a2,12(sp)
	li	a4,108
	bne	a3,a4,.L25
	lw	a3,4(sp)
	slli	a4,s1,2
	mv	a1,a5
	add	a4,a4,a3
	sw	a5,0(a4)
	j	.L68
.L19:
	lui	a1,%hi(.LC22)
	addi	a1,a1,%lo(.LC22)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L29
	lw	a0,32(sp)
	beqz	a0,.L30
	call	xtoi
	lw	a5,0(sp)
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,8(a5)
.L30:
	lw	a5,0(sp)
	lui	a0,%hi(.LC23)
	addi	a0,a0,%lo(.LC23)
	lhu	a1,8(a5)
.L65:
	call	printf
	j	.L38
.L29:
	lui	a1,%hi(.LC24)
	addi	a1,a1,%lo(.LC24)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L31
	lw	a0,32(sp)
	beqz	a0,.L32
	call	atoi
	lw	a5,0(sp)
	sw	a0,12(a5)
.L32:
	lw	a5,0(sp)
	lui	a0,%hi(.LC25)
	addi	a0,a0,%lo(.LC25)
	lw	a1,12(a5)
	j	.L65
.L31:
	lui	a1,%hi(.LC26)
	addi	a1,a1,%lo(.LC26)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L33
	lw	a0,32(sp)
	beqz	a0,.L34
	call	xtoi
	lw	a5,0(sp)
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,10(a5)
.L34:
	lw	a5,0(sp)
	lui	a0,%hi(.LC27)
	addi	a0,a0,%lo(.LC27)
	lhu	a1,10(a5)
	j	.L65
.L33:
	lui	a1,%hi(.LC28)
	addi	a1,a1,%lo(.LC28)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L35
	lw	a0,32(sp)
	call	atoi
	mv	s0,a0
	lw	a0,36(sp)
	call	atoi
	mv	a1,a0
	mv	a0,s0
	call	__mulsi3
	mv	a1,a0
	lui	a0,%hi(.LC29)
	addi	a0,a0,%lo(.LC29)
	j	.L65
.L35:
	lui	a1,%hi(.LC30)
	addi	a1,a1,%lo(.LC30)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L36
	lw	a0,32(sp)
	call	atoi
	mv	s0,a0
	lw	a0,36(sp)
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
	lui	a0,%hi(.LC31)
	addi	a0,a0,%lo(.LC31)
	call	printf
	j	.L38
.L36:
	lui	a1,%hi(.LC32)
	addi	a1,a1,%lo(.LC32)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L37
	lw	a0,32(sp)
	call	atoi
	mv	s0,a0
	lw	a0,36(sp)
	call	atoi
	mv	s1,a0
	lw	a0,40(sp)
	call	atoi
	slli	a2,a0,16
	slli	a1,s1,16
	srai	a1,a1,16
	srai	a2,a2,16
	mv	a0,s0
	call	mac
	mv	a1,a0
	lui	a0,%hi(.LC33)
	addi	a0,a0,%lo(.LC33)
	j	.L65
.L37:
	lbu	a5,0(s0)
	beqz	a5,.L38
	lui	a0,%hi(.LC34)
	mv	a1,s0
	addi	a0,a0,%lo(.LC34)
	j	.L65
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
	.string	"Wed, 06 Nov 2019 03:30:30 -0200"
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
	.string	"wow! hello atros! o/"
	.zero	3
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
