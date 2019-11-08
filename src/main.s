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
	addi	sp,sp,-120
	sw	s0,112(sp)
	lui	s0,%hi(io)
	lbu	a0,%lo(io)(s0)
	sw	ra,116(sp)
	sw	s1,108(sp)
	call	board_name
	lbu	a2,%lo(io)(s0)
	mv	a1,a0
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	printf
	lui	a1,%hi(.LC4)
	lui	a0,%hi(.LC5)
	addi	a1,a1,%lo(.LC4)
	addi	a0,a0,%lo(.LC5)
	call	printf
	addi	a5,s0,%lo(io)
	lui	s1,%hi(threads)
	lbu	t1,1(a5)
	lw	a4,%lo(threads)(s1)
	lbu	t0,2(a5)
	li	a5,1
	andi	t1,t1,0xff
	andi	t0,t0,0xff
	addi	s0,s0,%lo(io)
	bgt	a4,a5,.L20
	lui	a4,%hi(.LC1)
	addi	a4,a4,%lo(.LC1)
.L2:
	li	a2,16
	li	a1,16
	li	a0,1000
	sw	a4,8(sp)
	sw	t0,4(sp)
	sw	t1,0(sp)
	call	mac
	li	a5,1256
	lw	t1,0(sp)
	lw	t0,4(sp)
	lw	a4,8(sp)
	beq	a0,a5,.L21
	lui	a5,%hi(.LC1)
	addi	a5,a5,%lo(.LC1)
.L3:
	lui	a3,%hi(.LC6)
	lui	a0,%hi(.LC7)
	mv	a2,t0
	mv	a1,t1
	addi	a3,a3,%lo(.LC6)
	addi	a0,a0,%lo(.LC7)
	call	printf
	lhu	a1,6(s0)
	lui	a0,%hi(.LC8)
	addi	a0,a0,%lo(.LC8)
	sw	zero,%lo(threads)(s1)
	call	printf
	lbu	a0,1(s0)
	lbu	s1,2(s0)
	lw	a4,12(s0)
	lw	a2,12(s0)
	li	a1,999424
	addi	a1,a1,576
	sw	a2,4(sp)
	sw	a4,8(sp)
	call	__mulsi3
	andi	s1,s1,0xff
	li	a1,8192
	sw	a0,0(sp)
	addi	a1,a1,1808
	mv	a0,s1
	call	__mulsi3
	lw	a4,8(sp)
	lw	a5,0(sp)
	addi	a1,a4,1
	add	a0,a5,a0
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
	li	a0,1000
	call	usleep
.L19:
	lui	a5,%hi(.LC11)
	addi	a0,a5,%lo(.LC11)
	call	printf
	li	a2,64
	li	a1,0
	addi	a0,sp,44
	call	memset
	li	a1,64
	addi	a0,sp,44
	call	gets
	li	s1,0
	addi	a0,sp,44
	lui	a4,%hi(.LC12)
.L4:
	addi	a1,a4,%lo(.LC12)
	call	strtok
	addi	a4,sp,108
	slli	a5,s1,2
	add	a5,a4,a5
	sw	a0,-96(a5)
	lui	a4,%hi(.LC12)
	beqz	a0,.L5
	addi	s1,s1,1
	li	a5,8
	li	a0,0
	bne	s1,a5,.L4
.L5:
	lw	s1,12(sp)
	beqz	s1,.L19
	lui	a1,%hi(.LC13)
	addi	a1,a1,%lo(.LC13)
	mv	a0,s1
	call	strcmp
	bnez	a0,.L8
	lui	a0,%hi(.LC14)
	addi	a0,a0,%lo(.LC14)
	call	printf
	j	.L19
.L20:
	lui	a4,%hi(.LC0)
	addi	a4,a4,%lo(.LC0)
	j	.L2
.L21:
	lui	a5,%hi(.LC2)
	addi	a5,a5,%lo(.LC2)
	j	.L3
.L8:
	lui	a1,%hi(.LC15)
	addi	a1,a1,%lo(.LC15)
	mv	a0,s1
	call	strcmp
	bnez	a0,.L9
	lui	a0,%hi(.LC16)
	addi	a0,a0,%lo(.LC16)
	call	puts
	li	a0,4096
	addi	a0,a0,-1096
	call	usleep
	lui	a0,%hi(.LC17)
	addi	a0,a0,%lo(.LC17)
	call	printf
	lw	ra,116(sp)
	lw	s0,112(sp)
	lw	s1,108(sp)
	addi	sp,sp,120
	jr	ra
.L9:
	lui	a1,%hi(.LC18)
	addi	a1,a1,%lo(.LC18)
	mv	a0,s1
	call	strcmp
	bnez	a0,.L10
	lw	a0,16(sp)
	beqz	a0,.L11
	call	xtoi
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,8(s0)
.L11:
	lhu	a1,8(s0)
	lui	a0,%hi(.LC19)
	addi	a0,a0,%lo(.LC19)
.L39:
	call	printf
	j	.L19
.L10:
	lui	a1,%hi(.LC20)
	addi	a1,a1,%lo(.LC20)
	mv	a0,s1
	call	strcmp
	bnez	a0,.L12
	lw	a0,16(sp)
	beqz	a0,.L13
	call	atoi
	sw	a0,12(s0)
.L13:
	lui	a0,%hi(.LC21)
	lw	a1,12(s0)
	addi	a0,a0,%lo(.LC21)
	j	.L39
.L12:
	lui	a1,%hi(.LC22)
	addi	a1,a1,%lo(.LC22)
	mv	a0,s1
	call	strcmp
	bnez	a0,.L14
	lw	a0,16(sp)
	beqz	a0,.L15
	call	xtoi
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,10(s0)
.L15:
	lui	a0,%hi(.LC23)
	lhu	a1,10(s0)
	addi	a0,a0,%lo(.LC23)
	j	.L39
.L14:
	lui	a1,%hi(.LC24)
	addi	a1,a1,%lo(.LC24)
	mv	a0,s1
	call	strcmp
	bnez	a0,.L16
	lw	a0,16(sp)
	call	atoi
	mv	s1,a0
	lw	a0,20(sp)
	call	atoi
	mv	a1,a0
	mv	a0,s1
	call	__mulsi3
	mv	a1,a0
	lui	a0,%hi(.LC25)
	addi	a0,a0,%lo(.LC25)
	j	.L39
.L16:
	lui	a1,%hi(.LC26)
	addi	a1,a1,%lo(.LC26)
	mv	a0,s1
	call	strcmp
	bnez	a0,.L17
	lw	a0,16(sp)
	call	atoi
	mv	s1,a0
	lw	a0,20(sp)
	call	atoi
	mv	a1,a0
	sw	a0,4(sp)
	mv	a0,s1
	call	__modsi3
	lw	a5,4(sp)
	sw	a0,0(sp)
	mv	a0,s1
	mv	a1,a5
	call	__divsi3
	lw	a2,0(sp)
	mv	a1,a0
	lui	a0,%hi(.LC27)
	addi	a0,a0,%lo(.LC27)
	call	printf
	j	.L19
.L17:
	lui	a1,%hi(.LC28)
	addi	a1,a1,%lo(.LC28)
	mv	a0,s1
	call	strcmp
	bnez	a0,.L18
	lw	a0,16(sp)
	call	atoi
	mv	s1,a0
	lw	a0,20(sp)
	call	atoi
	sw	a0,0(sp)
	lw	a0,24(sp)
	call	atoi
	lw	a1,0(sp)
	slli	a2,a0,16
	srai	a2,a2,16
	slli	a1,a1,16
	srai	a1,a1,16
	mv	a0,s1
	call	mac
	mv	a1,a0
	lui	a0,%hi(.LC29)
	addi	a0,a0,%lo(.LC29)
	j	.L39
.L18:
	lbu	a5,0(s1)
	beqz	a5,.L19
	lui	a0,%hi(.LC30)
	mv	a1,s1
	addi	a0,a0,%lo(.LC30)
	j	.L39
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
	.string	"Fri, 08 Nov 2019 20:24:23 -0300"
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
	.string	"core0: reboot in 3 seconds..."
	.zero	2
.LC17:
	.string	"wow! hello atros! o/\n\n"
	.zero	1
.LC18:
	.string	"led"
.LC19:
	.string	"led = %x\n"
	.zero	2
.LC20:
	.string	"timer"
	.zero	2
.LC21:
	.string	"timer = %d\n"
.LC22:
	.string	"gpio"
	.zero	3
.LC23:
	.string	"gpio = %x\n"
	.zero	1
.LC24:
	.string	"mul"
.LC25:
	.string	"mul = %d\n"
	.zero	2
.LC26:
	.string	"div"
.LC27:
	.string	"div = %d, mod = %d\n"
.LC28:
	.string	"mac"
.LC29:
	.string	"mac = %d\n"
	.zero	2
.LC30:
	.string	"command: [%s] not found.\nvalid commands: clear, dump <hex>, led <hex>, timer <dec>, gpio <hex>\n                mul <dec> <dec>, div <dec> <dec>, mac <dec> <dec> <dec>\n                rd[m][bwl] <hex> [<hex> when m], wr[m][bwl] <hex> <hex> [<hex> when m]\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
