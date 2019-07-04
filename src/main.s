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
	addi	sp,sp,-64
	sw	ra,60(sp)
	sw	s0,56(sp)
	sw	s1,52(sp)
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
	lbu	a1,1(s1)
	lbu	a2,2(s1)
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	printf
	lhu	a1,6(s1)
	lui	a0,%hi(.LC2)
	addi	a0,a0,%lo(.LC2)
	call	printf
	lw	a1,12(s1)
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	printf
	lui	a0,%hi(.LC4)
	addi	a0,a0,%lo(.LC4)
	call	puts
	addi	a5,s0,%lo(io)
	sw	a5,8(sp)
.L2:
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	printf
	li	a2,32
	li	a1,0
	addi	a0,sp,16
	call	memset
	li	a1,32
	addi	a0,sp,16
	call	gets
	lui	s1,%hi(.LC6)
	addi	a1,s1,%lo(.LC6)
	addi	a0,sp,16
	call	strtok
	mv	s0,a0
	beqz	a0,.L2
	lui	a1,%hi(.LC7)
	addi	a1,a1,%lo(.LC7)
	call	strcmp
	bnez	a0,.L4
	lui	a0,%hi(.LC8)
	addi	a0,a0,%lo(.LC8)
	call	printf
	j	.L2
.L4:
	lui	a1,%hi(.LC9)
	addi	a1,a1,%lo(.LC9)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L6
	call	banner
	lui	a0,%hi(.LC10)
	addi	a0,a0,%lo(.LC10)
.L66:
	call	puts
	j	.L2
.L6:
	lui	a1,%hi(.LC11)
	addi	a1,a1,%lo(.LC11)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L7
	addi	a1,s1,%lo(.LC6)
	call	strtok
	mv	s0,a0
	beqz	a0,.L8
	call	atoi
	mv	s0,a0
.L8:
	addi	s1,s0,512
.L12:
	lui	a5,%hi(.LC12)
	mv	a1,s0
	addi	a0,a5,%lo(.LC12)
	call	printf
	li	a4,0
	lui	a2,%hi(.LC13)
.L9:
	add	a3,s0,a4
	lbu	a1,0(a3)
	addi	a0,a2,%lo(.LC13)
	sw	a4,12(sp)
	call	printf
	lw	a4,12(sp)
	li	a3,32
	lui	a2,%hi(.LC13)
	addi	a4,a4,1
	bne	a4,a3,.L9
	li	a4,0
.L11:
	add	a3,s0,a4
	lbu	a0,0(a3)
	li	a2,94
	addi	a3,a0,-32
	andi	a3,a3,0xff
	bleu	a3,a2,.L10
	li	a0,46
.L10:
	sw	a4,12(sp)
	call	putchar
	lw	a4,12(sp)
	li	a3,32
	addi	a4,a4,1
	bne	a4,a3,.L11
	li	a0,10
	addi	s0,s0,32
	call	putchar
	bne	s1,s0,.L12
	j	.L2
.L7:
	lui	a1,%hi(.LC14)
	addi	a1,a1,%lo(.LC14)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L13
	addi	a1,s1,%lo(.LC6)
	call	strtok
	beqz	a0,.L14
	call	atoi
	lw	a5,8(sp)
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,8(a5)
.L14:
	lw	a5,8(sp)
	lui	a0,%hi(.LC15)
	addi	a0,a0,%lo(.LC15)
	lhu	a1,8(a5)
.L67:
	call	printf
	j	.L2
.L13:
	lui	a1,%hi(.LC16)
	addi	a1,a1,%lo(.LC16)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L15
	addi	a1,s1,%lo(.LC6)
	call	strtok
	beqz	a0,.L16
	call	atoi
	lw	a5,8(sp)
	sw	a0,12(a5)
.L16:
	lw	a5,8(sp)
	lui	a0,%hi(.LC17)
	addi	a0,a0,%lo(.LC17)
	lw	a1,12(a5)
	j	.L67
.L15:
	lui	a1,%hi(.LC18)
	addi	a1,a1,%lo(.LC18)
	mv	a0,s0
	call	strcmp
	bnez	a0,.L17
	addi	a1,s1,%lo(.LC6)
	call	strtok
	beqz	a0,.L18
	call	atoi
	lw	a5,8(sp)
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,10(a5)
.L18:
	lw	a5,8(sp)
	lui	a0,%hi(.LC19)
	addi	a0,a0,%lo(.LC19)
	lhu	a1,10(a5)
	j	.L67
.L17:
	lui	a1,%hi(.LC20)
	addi	a1,a1,%lo(.LC20)
	mv	a0,s0
	call	strcmp
	mv	s1,a0
	bnez	a0,.L19
	lui	a5,%hi(.LC6)
	addi	a1,a5,%lo(.LC6)
	call	strtok
	li	s0,0
	beqz	a0,.L20
	call	atoi
	mv	s0,a0
.L20:
	lui	a5,%hi(.LC6)
	addi	a1,a5,%lo(.LC6)
	li	a0,0
	call	strtok
	beqz	a0,.L21
	call	atoi
	mv	s1,a0
.L21:
	mv	a1,s1
	mv	a0,s0
	call	__mulsi3
	mv	a1,a0
	lui	a0,%hi(.LC21)
	addi	a0,a0,%lo(.LC21)
	j	.L67
.L19:
	lui	a1,%hi(.LC22)
	addi	a1,a1,%lo(.LC22)
	mv	a0,s0
	call	strcmp
	mv	s1,a0
	bnez	a0,.L22
	lui	a5,%hi(.LC6)
	addi	a1,a5,%lo(.LC6)
	call	strtok
	beqz	a0,.L23
	call	atoi
	mv	s1,a0
.L23:
	lui	a5,%hi(.LC6)
	addi	a1,a5,%lo(.LC6)
	li	a0,0
	call	strtok
	beqz	a0,.L24
	call	atoi
	mv	s0,a0
	mv	a1,a0
	mv	a0,s1
	call	__modsi3
	sw	a0,12(sp)
	mv	a1,s0
	mv	a0,s1
	call	__divsi3
	lw	a2,12(sp)
	mv	a1,a0
	lui	a0,%hi(.LC23)
	addi	a0,a0,%lo(.LC23)
	call	printf
	j	.L2
.L22:
	lui	a1,%hi(.LC24)
	addi	a1,a1,%lo(.LC24)
	mv	a0,s0
	call	strcmp
	mv	s1,a0
	bnez	a0,.L25
	lui	a5,%hi(.LC6)
	addi	a1,a5,%lo(.LC6)
	li	a0,0
	call	strtok
	li	s0,0
	beqz	a0,.L26
	call	atoi
	mv	s0,a0
.L26:
	lui	a5,%hi(.LC6)
	addi	a1,a5,%lo(.LC6)
	li	a0,0
	call	strtok
	sw	zero,12(sp)
	beqz	a0,.L27
	call	atoi
	sw	a0,12(sp)
.L27:
	lui	a5,%hi(.LC6)
	addi	a1,a5,%lo(.LC6)
	li	a0,0
	call	strtok
	beqz	a0,.L28
	call	atoi
	mv	s1,a0
.L28:
	lh	a1,12(sp)
	slli	a2,s1,16
	srai	a2,a2,16
	mv	a0,s0
	call	mac
	mv	a1,a0
	lui	a0,%hi(.LC25)
	addi	a0,a0,%lo(.LC25)
	j	.L67
.L25:
	lbu	a5,0(s0)
	beqz	a5,.L2
	lui	a0,%hi(.LC26)
	mv	a1,s0
	addi	a0,a0,%lo(.LC26)
	call	printf
	lui	a0,%hi(.LC27)
	addi	a0,a0,%lo(.LC27)
	call	puts
	lui	a0,%hi(.LC28)
	addi	a0,a0,%lo(.LC28)
	call	puts
	lui	a0,%hi(.LC29)
	addi	a0,a0,%lo(.LC29)
	j	.L66
.L24:
	ebreak
	.size	main, .-main
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"board: %s (id=%d)\n"
	.zero	1
.LC1:
	.string	"core0: darkriscv at %d.%dMHz\n"
	.zero	2
.LC2:
	.string	"uart0: baudrate counter=%d\n"
.LC3:
	.string	"timr0: periodic timer=%d\n\n"
	.zero	1
.LC4:
	.string	"Welcome to DarkRISCV!"
	.zero	2
.LC5:
	.string	"> "
	.zero	1
.LC6:
	.string	" "
	.zero	2
.LC7:
	.string	"clear"
	.zero	2
.LC8:
	.string	"\033[H\033[2J"
.LC9:
	.string	"atros"
	.zero	2
.LC10:
	.string	"wow! hello atros! o/"
	.zero	3
.LC11:
	.string	"dump"
	.zero	3
.LC12:
	.string	"%d: "
	.zero	3
.LC13:
	.string	"%x "
.LC14:
	.string	"led"
.LC15:
	.string	"led = %d\n"
	.zero	2
.LC16:
	.string	"timer"
	.zero	2
.LC17:
	.string	"timer = %d\n"
.LC18:
	.string	"gpio"
	.zero	3
.LC19:
	.string	"gpio = %d\n"
	.zero	1
.LC20:
	.string	"mul"
.LC21:
	.string	"mul = %d\n"
	.zero	2
.LC22:
	.string	"div"
.LC23:
	.string	"div = %d, mod = %d\n"
.LC24:
	.string	"mac"
.LC25:
	.string	"mac = %d\n"
	.zero	2
.LC26:
	.string	"command: [%s] not found.\n"
	.zero	2
.LC27:
	.string	"valid commands: clear, dump <val>, led <val>, timer <val>, gpio <val>"
	.zero	2
.LC28:
	.string	"                mul <val1> <val2>, div <val1> <val2>"
	.zero	3
.LC29:
	.string	"                mac <acc> <val1> <val2>"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
