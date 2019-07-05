	.file	"main.c"
	.option nopic
	.text
	.globl	__mulsi3
	.globl	__modsi3
	.globl	__divsi3
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-124
	sw	ra,120(sp)
	sw	s0,116(sp)
	sw	s1,112(sp)
	lui	s0,%hi(io)
	call	banner
	lbu	a5,%lo(io)(s0)
	lui	a4,%hi(board_name)
	addi	a4,a4,%lo(board_name)
	slli	a5,a5,2
	add	a5,a5,a4
	lw	a1,0(a5)
	lbu	a2,%lo(io)(s0)
	lui	a0,%hi(.LC0)
	addi	a0,a0,%lo(.LC0)
	call	printf
	addi	s1,s0,%lo(io)
	lbu	a2,1(s1)
	lbu	a3,2(s1)
	lui	a1,%hi(.LC1)
	lui	a0,%hi(.LC2)
	addi	a1,a1,%lo(.LC1)
	addi	a0,a0,%lo(.LC2)
	call	printf
	lhu	a1,6(s1)
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	printf
	lw	a1,12(s1)
	lui	a0,%hi(.LC4)
	addi	a0,a0,%lo(.LC4)
	call	printf
	lui	a1,%hi(.LC5)
	lui	a0,%hi(.LC6)
	addi	a1,a1,%lo(.LC5)
	addi	a0,a0,%lo(.LC6)
	call	printf
	li	a0,10
	call	putchar
	lui	a0,%hi(.LC7)
	addi	a0,a0,%lo(.LC7)
	call	puts
	addi	a5,s0,%lo(io)
	sw	a5,4(sp)
.L44:
	lui	a5,%hi(.LC8)
	addi	a0,a5,%lo(.LC8)
	call	printf
	li	a2,64
	li	a1,0
	addi	a0,sp,48
	call	memset
	li	a1,64
	addi	a0,sp,48
	call	gets
	li	s0,0
	addi	a0,sp,48
	lui	s1,%hi(.LC9)
.L2:
	addi	a1,s1,%lo(.LC9)
	call	strtok
	slli	a5,s0,2
	addi	a4,sp,112
	add	a5,a4,a5
	sw	a0,-96(a5)
	beqz	a0,.L3
	addi	s0,s0,1
	li	a5,8
	li	a0,0
	bne	s0,a5,.L2
.L3:
	lw	s0,16(sp)
	beqz	s0,.L44
	lui	a1,%hi(.LC10)
	addi	a1,a1,%lo(.LC10)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L7
	lui	a0,%hi(.LC11)
	addi	a0,a0,%lo(.LC11)
	call	printf
	j	.L44
.L7:
	lui	a1,%hi(.LC12)
	addi	a1,a1,%lo(.LC12)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L8
	call	banner
	lui	a0,%hi(.LC13)
	addi	a0,a0,%lo(.LC13)
	call	puts
	j	.L44
.L8:
	lui	a1,%hi(.LC14)
	addi	a1,a1,%lo(.LC14)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L9
	lw	s0,20(sp)
	beqz	s0,.L10
	mv	a0,s0
	call	xtoi
	mv	s0,a0
.L10:
	addi	s1,s0,256
.L14:
	lui	a5,%hi(.LC15)
	mv	a1,s0
	addi	a0,a5,%lo(.LC15)
	call	printf
	li	a4,0
	lui	a2,%hi(.LC16)
.L11:
	add	a3,s0,a4
	lbu	a1,0(a3)
	addi	a0,a2,%lo(.LC16)
	sw	a4,0(sp)
	call	printf
	lw	a4,0(sp)
	li	a3,16
	lui	a2,%hi(.LC16)
	addi	a4,a4,1
	bne	a4,a3,.L11
	li	a4,0
.L13:
	add	a3,s0,a4
	lbu	a0,0(a3)
	li	a2,94
	addi	a3,a0,-32
	andi	a3,a3,0xff
	bleu	a3,a2,.L12
	li	a0,46
.L12:
	sw	a4,0(sp)
	call	putchar
	lw	a4,0(sp)
	li	a3,16
	addi	a4,a4,1
	bne	a4,a3,.L13
	li	a0,10
	addi	s0,s0,16
	call	putchar
	bne	s1,s0,.L14
	j	.L44
.L9:
	lui	a1,%hi(.LC17)
	li	a2,2
	addi	a1,a1,%lo(.LC17)
	mv	a0,s0
	call	strncmp
	sw	a0,0(sp)
	bnez	a0,.L16
	lw	a0,20(sp)
	call	xtoi
	lbu	a4,2(s0)
	li	a5,98
	mv	s1,a0
	bne	a4,a5,.L17
	lbu	a2,0(a0)
	mv	a1,a0
	lui	a0,%hi(.LC18)
	addi	a0,a0,%lo(.LC18)
	call	printf
.L17:
	lbu	a4,2(s0)
	li	a5,119
	bne	a4,a5,.L18
	lh	a2,0(s1)
	lui	a0,%hi(.LC18)
	mv	a1,s1
	addi	a0,a0,%lo(.LC18)
	call	printf
.L18:
	lbu	a4,2(s0)
	li	a5,108
	bne	a4,a5,.L19
	lw	a2,0(s1)
	lui	a0,%hi(.LC18)
	mv	a1,s1
	addi	a0,a0,%lo(.LC18)
	call	printf
.L19:
	lbu	a4,2(s0)
	li	a5,109
	bne	a4,a5,.L44
	lw	a0,24(sp)
	call	xtoi
	sw	a0,8(sp)
	lui	a0,%hi(.LC15)
	mv	a1,s1
	addi	a0,a0,%lo(.LC15)
	call	printf
.L20:
	lw	a5,0(sp)
	lw	a4,8(sp)
	bne	a5,a4,.L24
.L34:
	li	a0,10
	call	putchar
	j	.L44
.L24:
	lbu	a4,3(s0)
	li	a5,98
	bne	a4,a5,.L21
	lw	a5,0(sp)
	add	a5,s1,a5
	lbu	a1,0(a5)
	lui	a5,%hi(.LC16)
	addi	a0,a5,%lo(.LC16)
	call	printf
.L21:
	lbu	a4,3(s0)
	li	a5,119
	bne	a4,a5,.L22
	lw	a5,0(sp)
	slli	a5,a5,1
	add	a5,a5,s1
	lh	a1,0(a5)
	lui	a5,%hi(.LC16)
	addi	a0,a5,%lo(.LC16)
	call	printf
.L22:
	lbu	a4,3(s0)
	li	a5,108
	bne	a4,a5,.L23
	lw	a5,0(sp)
	slli	a5,a5,2
	add	a5,a5,s1
	lw	a1,0(a5)
	lui	a5,%hi(.LC16)
	addi	a0,a5,%lo(.LC16)
	call	printf
.L23:
	lw	a5,0(sp)
	addi	a5,a5,1
	sw	a5,0(sp)
	j	.L20
.L16:
	lui	a1,%hi(.LC19)
	li	a2,2
	addi	a1,a1,%lo(.LC19)
	mv	a0,s0
	call	strncmp
	sw	a0,0(sp)
	bnez	a0,.L25
	lw	a0,20(sp)
	call	xtoi
	sw	a0,8(sp)
	lw	a0,24(sp)
	call	xtoi
	lbu	a3,2(s0)
	li	a4,98
	mv	s1,a0
	lw	a5,8(sp)
	bne	a3,a4,.L26
	sb	a0,0(a5)
	andi	a2,a0,0xff
	lui	a0,%hi(.LC18)
	mv	a1,a5
	addi	a0,a0,%lo(.LC18)
	call	printf
	lw	a5,8(sp)
.L26:
	lbu	a3,2(s0)
	li	a4,119
	bne	a3,a4,.L27
	slli	a2,s1,16
	srai	a2,a2,16
	lui	a0,%hi(.LC18)
	sh	a2,0(a5)
	mv	a1,a5
	addi	a0,a0,%lo(.LC18)
	sw	a5,8(sp)
	call	printf
	lw	a5,8(sp)
.L27:
	lbu	a3,2(s0)
	li	a4,108
	bne	a3,a4,.L28
	lui	a0,%hi(.LC18)
	sw	s1,0(a5)
	mv	a2,s1
	mv	a1,a5
	addi	a0,a0,%lo(.LC18)
	call	printf
.L28:
	lbu	a4,2(s0)
	li	a5,109
	bne	a4,a5,.L44
	mv	a0,s0
	call	xtoi
	sw	a0,8(sp)
	mv	a0,s0
	call	xtoi
	mv	a1,a0
	lui	a0,%hi(.LC15)
	addi	a0,a0,%lo(.LC15)
	call	printf
.L29:
	lw	a5,0(sp)
	lw	a4,8(sp)
	beq	a5,a4,.L34
	lw	a0,28(sp)
	call	xtoi
	lbu	a3,3(s0)
	li	a4,98
	mv	a5,a0
	bne	a3,a4,.L30
	lw	a4,0(sp)
	lui	a5,%hi(.LC16)
	andi	a1,a0,0xff
	add	a4,s1,a4
	sb	a0,0(a4)
	sw	a0,12(sp)
	addi	a0,a5,%lo(.LC16)
	call	printf
	lw	a5,12(sp)
.L30:
	lbu	a3,3(s0)
	li	a4,119
	bne	a3,a4,.L31
	slli	a1,a5,16
	sw	a5,12(sp)
	lw	a5,0(sp)
	srai	a1,a1,16
	slli	a4,a5,1
	add	a4,a4,s1
	lui	a5,%hi(.LC16)
	addi	a0,a5,%lo(.LC16)
	sh	a1,0(a4)
	call	printf
	lw	a5,12(sp)
.L31:
	lbu	a3,3(s0)
	li	a4,108
	bne	a3,a4,.L32
	lw	a4,0(sp)
	mv	a1,a5
	slli	a4,a4,2
	add	a4,a4,s1
	sw	a5,0(a4)
	lui	a5,%hi(.LC16)
	addi	a0,a5,%lo(.LC16)
	call	printf
.L32:
	lw	a5,0(sp)
	addi	a5,a5,1
	sw	a5,0(sp)
	j	.L29
.L25:
	lui	a1,%hi(.LC20)
	addi	a1,a1,%lo(.LC20)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L35
	lw	a0,20(sp)
	beqz	a0,.L36
	call	xtoi
	lw	a5,4(sp)
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,8(a5)
.L36:
	lw	a5,4(sp)
	lui	a0,%hi(.LC21)
	addi	a0,a0,%lo(.LC21)
	lhu	a1,8(a5)
.L64:
	call	printf
	j	.L44
.L35:
	lui	a1,%hi(.LC22)
	addi	a1,a1,%lo(.LC22)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L37
	lw	a0,20(sp)
	beqz	a0,.L38
	call	atoi
	lw	a5,4(sp)
	sw	a0,12(a5)
.L38:
	lw	a5,4(sp)
	lui	a0,%hi(.LC23)
	addi	a0,a0,%lo(.LC23)
	lw	a1,12(a5)
	j	.L64
.L37:
	lui	a1,%hi(.LC24)
	addi	a1,a1,%lo(.LC24)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L39
	lw	a0,20(sp)
	beqz	a0,.L40
	call	xtoi
	lw	a5,4(sp)
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,10(a5)
.L40:
	lw	a5,4(sp)
	lui	a0,%hi(.LC25)
	addi	a0,a0,%lo(.LC25)
	lhu	a1,10(a5)
	j	.L64
.L39:
	lui	a1,%hi(.LC26)
	addi	a1,a1,%lo(.LC26)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L41
	lw	a0,20(sp)
	call	atoi
	mv	s0,a0
	lw	a0,24(sp)
	call	atoi
	mv	a1,a0
	mv	a0,s0
	call	__mulsi3
	mv	a1,a0
	lui	a0,%hi(.LC27)
	addi	a0,a0,%lo(.LC27)
	j	.L64
.L41:
	lui	a1,%hi(.LC28)
	addi	a1,a1,%lo(.LC28)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L42
	lw	a0,20(sp)
	call	atoi
	mv	s0,a0
	lw	a0,24(sp)
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
	lui	a0,%hi(.LC29)
	addi	a0,a0,%lo(.LC29)
	call	printf
	j	.L44
.L42:
	lui	a1,%hi(.LC30)
	addi	a1,a1,%lo(.LC30)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L43
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
	srai	a1,a1,16
	srai	a2,a2,16
	mv	a0,s0
	call	mac
	mv	a1,a0
	lui	a0,%hi(.LC31)
	addi	a0,a0,%lo(.LC31)
	j	.L64
.L43:
	lbu	a5,0(s0)
	beqz	a5,.L44
	lui	a0,%hi(.LC32)
	mv	a1,s0
	addi	a0,a0,%lo(.LC32)
	j	.L64
	.size	main, .-main
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"board: %s (id=%d)\n"
	.zero	1
.LC1:
	.string	"rv32e"
	.zero	2
.LC2:
	.string	"core0: darkriscv/%s at %d.%dMHz\n"
	.zero	3
.LC3:
	.string	"uart0: baudrate counter=%d\n"
.LC4:
	.string	"timr0: periodic timer=%d\n"
	.zero	2
.LC5:
	.string	"Fri, 05 Jul 2019 03:51:43 -0300"
.LC6:
	.string	"build: %s\n"
	.zero	1
.LC7:
	.string	"Welcome to DarkRISCV!"
	.zero	2
.LC8:
	.string	"> "
	.zero	1
.LC9:
	.string	" "
	.zero	2
.LC10:
	.string	"clear"
	.zero	2
.LC11:
	.string	"\033[H\033[2J"
.LC12:
	.string	"atros"
	.zero	2
.LC13:
	.string	"wow! hello atros! o/"
	.zero	3
.LC14:
	.string	"dump"
	.zero	3
.LC15:
	.string	"%x: "
	.zero	3
.LC16:
	.string	"%x "
.LC17:
	.string	"rd"
	.zero	1
.LC18:
	.string	"%x: %x\n"
.LC19:
	.string	"wr"
	.zero	1
.LC20:
	.string	"led"
.LC21:
	.string	"led = %x\n"
	.zero	2
.LC22:
	.string	"timer"
	.zero	2
.LC23:
	.string	"timer = %d\n"
.LC24:
	.string	"gpio"
	.zero	3
.LC25:
	.string	"gpio = %x\n"
	.zero	1
.LC26:
	.string	"mul"
.LC27:
	.string	"mul = %d\n"
	.zero	2
.LC28:
	.string	"div"
.LC29:
	.string	"div = %d, mod = %d\n"
.LC30:
	.string	"mac"
.LC31:
	.string	"mac = %d\n"
	.zero	2
.LC32:
	.string	"command: [%s] not found.\nvalid commands: clear, dump <hex>, led <hex>, timer <dec>, gpio <hex>\n                mul <dec> <dec>, div <dec> <dec>, mac <dec> <dec> <dec>\n                rd[m][bwl] <hex> [<hex> when m], wr[m][bwl] <hex> <hex> [<hex> when m]\n"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
