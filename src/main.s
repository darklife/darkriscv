	.file	"main.c"
	.option nopic
	.text
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	addi	sp,sp,-112
	sw	ra,108(sp)
	sw	s0,104(sp)
	sw	s1,100(sp)
	lui	s0,%hi(io)
	sw	s4,88(sp)
	sw	s5,84(sp)
	sw	s6,80(sp)
	sw	s7,76(sp)
	sw	s2,96(sp)
	sw	s3,92(sp)
	sw	s8,72(sp)
	sw	s9,68(sp)
	sw	s10,64(sp)
	sw	s11,60(sp)
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
	addi	s1,s0,%lo(io)
	call	printf
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
	addi	s0,s0,%lo(io)
	lui	s1,%hi(.LC6)
	lui	s4,%hi(.LC11)
	lui	s5,%hi(.LC14)
	lui	s6,%hi(.LC16)
	lui	s7,%hi(.LC18)
.L2:
	lui	a5,%hi(.LC5)
	addi	a0,a5,%lo(.LC5)
	call	printf
	li	a1,32
	addi	a0,sp,16
	call	gets
	addi	a1,s1,%lo(.LC6)
	addi	a0,sp,16
	call	strtok
	mv	s2,a0
	beqz	a0,.L2
	lui	a5,%hi(.LC7)
	addi	a1,a5,%lo(.LC7)
	call	strcmp
	bnez	a0,.L4
	lui	a0,%hi(.LC8)
	addi	a0,a0,%lo(.LC8)
	call	printf
	j	.L2
.L4:
	lui	a5,%hi(.LC9)
	addi	a1,a5,%lo(.LC9)
	mv	a0,s2
	call	strcmp
	bnez	a0,.L6
	call	banner
	lui	a0,%hi(.LC10)
	addi	a0,a0,%lo(.LC10)
.L41:
	call	puts
	j	.L2
.L6:
	addi	a1,s4,%lo(.LC11)
	mv	a0,s2
	call	strcmp
	bnez	a0,.L7
	addi	a1,s1,%lo(.LC6)
	call	strtok
	mv	s3,a0
	beqz	a0,.L8
	call	atoi
	mv	s3,a0
.L8:
	addi	s8,s3,512
	lui	s9,%hi(.LC12)
	lui	s10,%hi(.LC13)
	li	s2,32
	li	s11,94
.L12:
	mv	a1,s3
	addi	a0,s9,%lo(.LC12)
	call	printf
	li	a4,0
.L9:
	add	a3,s3,a4
	lbu	a1,0(a3)
	addi	a0,s10,%lo(.LC13)
	sw	a4,12(sp)
	call	printf
	lw	a4,12(sp)
	addi	a4,a4,1
	bne	a4,s2,.L9
	li	a4,0
.L11:
	add	a3,s3,a4
	lbu	a0,0(a3)
	addi	a3,a0,-32
	andi	a3,a3,0xff
	bleu	a3,s11,.L10
	li	a0,46
.L10:
	sw	a4,12(sp)
	call	putchar
	lw	a4,12(sp)
	addi	a4,a4,1
	bne	a4,s2,.L11
	li	a0,10
	addi	s3,s3,32
	call	putchar
	bne	s8,s3,.L12
	j	.L2
.L7:
	addi	a1,s5,%lo(.LC14)
	mv	a0,s2
	call	strcmp
	bnez	a0,.L13
	addi	a1,s1,%lo(.LC6)
	call	strtok
	beqz	a0,.L14
	call	atoi
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,8(s0)
.L14:
	lhu	a1,8(s0)
	lui	a0,%hi(.LC15)
	addi	a0,a0,%lo(.LC15)
.L42:
	call	printf
	j	.L2
.L13:
	addi	a1,s6,%lo(.LC16)
	mv	a0,s2
	call	strcmp
	bnez	a0,.L15
	addi	a1,s1,%lo(.LC6)
	call	strtok
	beqz	a0,.L16
	call	atoi
	sw	a0,12(s0)
.L16:
	lui	a0,%hi(.LC17)
	lw	a1,12(s0)
	addi	a0,a0,%lo(.LC17)
	j	.L42
.L15:
	addi	a1,s7,%lo(.LC18)
	mv	a0,s2
	call	strcmp
	bnez	a0,.L17
	addi	a1,s1,%lo(.LC6)
	call	strtok
	beqz	a0,.L18
	call	atoi
	slli	a0,a0,16
	srli	a0,a0,16
	sh	a0,10(s0)
.L18:
	lui	a0,%hi(.LC19)
	lhu	a1,10(s0)
	addi	a0,a0,%lo(.LC19)
	j	.L42
.L17:
	lbu	a5,0(s2)
	beqz	a5,.L2
	lui	a0,%hi(.LC20)
	mv	a1,s2
	addi	a0,a0,%lo(.LC20)
	call	printf
	lui	a0,%hi(.LC21)
	addi	a0,a0,%lo(.LC21)
	j	.L41
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
	.string	"command: [%s] not found.\n"
	.zero	2
.LC21:
	.string	"valid commands: clear, dump <val>, led <val>, timer <val>, gpio <val>"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
