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
	call	puts
	lui	a5,%hi(ip)
	lw	s0,%lo(ip)(a5)
	lui	a5,%hi(port)
	lhu	a5,%lo(port)(a5)
	srli	s1,s0,8
	srli	t1,s0,16
	andi	t0,s0,255
	andi	t1,t1,0xff
	srli	t2,s0,24
	andi	s1,s1,0xff
	lui	a0,%hi(.LC11)
	mv	a4,t2
	mv	a3,t1
	mv	a1,t0
	mv	a2,s1
	addi	a0,a0,%lo(.LC11)
	sw	t2,16(sp)
	sw	t1,12(sp)
	sw	t0,8(sp)
	sw	a5,4(sp)
	call	printf
	li	a5,305418240
	lui	a0,%hi(.LC12)
	addi	a5,a5,1656
	li	a4,18
	li	a3,52
	li	a2,86
	li	a1,120
	addi	a0,a0,%lo(.LC12)
	call	printf
	lw	t2,16(sp)
	lw	t1,12(sp)
	lw	t0,8(sp)
	lui	a0,%hi(.LC13)
	mv	a4,t2
	mv	a3,t1
	mv	a1,t0
	mv	a5,s0
	mv	a2,s1
	addi	a0,a0,%lo(.LC13)
	call	printf
	lw	a4,4(sp)
	lui	a0,%hi(.LC14)
	addi	a0,a0,%lo(.LC14)
	mv	a3,a4
	srli	a2,a4,8
	andi	a1,a4,0xff
	call	printf
	lui	a0,%hi(.LC15)
	li	a4,11
	li	a3,10
	li	a2,11
	li	a1,10
	addi	a0,a0,%lo(.LC15)
	call	printf
	li	a0,10
	call	putchar
	lui	a0,%hi(.LC16)
	addi	a0,a0,%lo(.LC16)
.L66:
	call	puts
.L38:
	lui	a5,%hi(.LC17)
	addi	a0,a5,%lo(.LC17)
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
	lui	s1,%hi(.LC18)
.L4:
	addi	a1,s1,%lo(.LC18)
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
	lui	a1,%hi(.LC19)
	addi	a1,a1,%lo(.LC19)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L9
	lui	a0,%hi(.LC20)
	addi	a0,a0,%lo(.LC20)
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
	lui	a1,%hi(.LC21)
	addi	a1,a1,%lo(.LC21)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L10
	call	banner
	lui	a0,%hi(.LC22)
	addi	a0,a0,%lo(.LC22)
	j	.L66
.L10:
	lui	a1,%hi(.LC23)
	addi	a1,a1,%lo(.LC23)
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
	lui	s1,%hi(.LC24)
.L16:
	mv	a1,s0
	addi	a0,s1,%lo(.LC24)
	call	printf
	li	a4,0
	lui	a2,%hi(.LC25)
.L13:
	add	a3,s0,a4
	lbu	a1,0(a3)
	addi	a0,a2,%lo(.LC25)
	sw	a4,8(sp)
	call	printf
	lw	a4,8(sp)
	li	a3,16
	lui	a2,%hi(.LC25)
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
	lui	a1,%hi(.LC26)
	li	a2,2
	addi	a1,a1,%lo(.LC26)
	mv	a0,s0
	call	strncmp
	beqz	a0,.L18
	lui	a1,%hi(.LC27)
	li	a2,2
	addi	a1,a1,%lo(.LC27)
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
	lui	a0,%hi(.LC24)
	addi	a0,a0,%lo(.LC24)
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
	lui	a5,%hi(.LC25)
	addi	a0,a5,%lo(.LC25)
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
	lui	a5,%hi(.LC25)
	addi	a0,a5,%lo(.LC25)
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
	lui	a5,%hi(.LC25)
	addi	a0,a5,%lo(.LC25)
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
	lui	a5,%hi(.LC25)
	andi	a1,a0,0xff
	add	a4,a4,s1
	sb	a0,0(a4)
	sw	a0,12(sp)
	addi	a0,a5,%lo(.LC25)
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
	lui	a5,%hi(.LC25)
	addi	a0,a5,%lo(.LC25)
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
	lui	a1,%hi(.LC28)
	addi	a1,a1,%lo(.LC28)
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
	lui	a0,%hi(.LC29)
	addi	a0,a0,%lo(.LC29)
	lhu	a1,8(a5)
.L65:
	call	printf
	j	.L38
.L29:
	lui	a1,%hi(.LC30)
	addi	a1,a1,%lo(.LC30)
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
	lui	a0,%hi(.LC31)
	addi	a0,a0,%lo(.LC31)
	lw	a1,12(a5)
	j	.L65
.L31:
	lui	a1,%hi(.LC32)
	addi	a1,a1,%lo(.LC32)
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
	lui	a0,%hi(.LC33)
	addi	a0,a0,%lo(.LC33)
	lhu	a1,10(a5)
	j	.L65
.L33:
	lui	a1,%hi(.LC34)
	addi	a1,a1,%lo(.LC34)
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
	lui	a0,%hi(.LC35)
	addi	a0,a0,%lo(.LC35)
	j	.L65
.L35:
	lui	a1,%hi(.LC36)
	addi	a1,a1,%lo(.LC36)
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
	lui	a0,%hi(.LC37)
	addi	a0,a0,%lo(.LC37)
	call	printf
	j	.L38
.L36:
	lui	a1,%hi(.LC38)
	addi	a1,a1,%lo(.LC38)
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
	lui	a0,%hi(.LC39)
	addi	a0,a0,%lo(.LC39)
	j	.L65
.L37:
	lbu	a5,0(s0)
	beqz	a5,.L38
	lui	a0,%hi(.LC40)
	mv	a1,s0
	addi	a0,a0,%lo(.LC40)
	j	.L65
	.size	main, .-main
	.globl	opts
	.globl	port
	.globl	ip
	.globl	test
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
	.string	"Sun, 18 Aug 2019 21:15:44 -0300"
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
	.string	"endian-test (little-endian):"
	.zero	3
.LC11:
	.string	"ip:port=%d.%d.%d.%d:%d\n"
.LC12:
	.string	"data.ref  = %x %x %x %x = %x\n"
	.zero	2
.LC13:
	.string	"data.ip   = %x %x %x %x = %x\n"
	.zero	2
.LC14:
	.string	"data.port = %x %x = %x/%d\n"
	.zero	1
.LC15:
	.string	"data.opts = %x %x = %x %x\n"
	.zero	1
.LC16:
	.string	"Welcome to DarkRISCV!"
	.zero	2
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
	.string	"atros"
	.zero	2
.LC22:
	.string	"wow! hello atros! o/"
	.zero	3
.LC23:
	.string	"dump"
	.zero	3
.LC24:
	.string	"%x: "
	.zero	3
.LC25:
	.string	"%x "
.LC26:
	.string	"rd"
	.zero	1
.LC27:
	.string	"wr"
	.zero	1
.LC28:
	.string	"led"
.LC29:
	.string	"led = %x\n"
	.zero	2
.LC30:
	.string	"timer"
	.zero	2
.LC31:
	.string	"timer = %d\n"
.LC32:
	.string	"gpio"
	.zero	3
.LC33:
	.string	"gpio = %x\n"
	.zero	1
.LC34:
	.string	"mul"
.LC35:
	.string	"mul = %d\n"
	.zero	2
.LC36:
	.string	"div"
.LC37:
	.string	"div = %d, mod = %d\n"
.LC38:
	.string	"mac"
.LC39:
	.string	"mac = %d\n"
	.zero	2
.LC40:
	.string	"command: [%s] not found.\nvalid commands: clear, dump <hex>, led <hex>, timer <dec>, gpio <hex>\n                mul <dec> <dec>, div <dec> <dec>, mac <dec> <dec> <dec>\n                rd[m][bwl] <hex> [<hex> when m], wr[m][bwl] <hex> <hex> [<hex> when m]\n"
	.section	.sdata,"aw"
	.align	2
	.type	opts, @object
	.size	opts, 2
opts:
	.half	-21555
	.type	port, @object
	.size	port, 2
port:
	.half	3128
	.type	ip, @object
	.size	ip, 4
ip:
	.word	-1408237567
	.type	test, @object
	.size	test, 4
test:
	.word	305419896
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
