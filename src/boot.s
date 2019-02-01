	.file	"boot.c"
	.option nopic
	.text
	.align	2
	.globl	_start
	.type	_start, @function
_start:
	addi	sp,sp,-304
	sw	ra,300(sp)
	sw	s0,296(sp)
	sw	s1,292(sp)
	sw	s2,288(sp)
	sw	s3,284(sp)
	sw	s4,280(sp)
	sw	s5,276(sp)
	lui	a5,%hi(io)
	li	a4,-2147483648
	sw	a4,%lo(io)(a5)
	lui	s0,%hi(.LC0)
	addi	s0,s0,%lo(.LC0)
	li	s2,0
	li	s1,0
	lui	s5,%hi(.LC1)
	lui	s4,%hi(.LC2)
	j	.L6
.L3:
	beqz	s3,.L4
	mv	s1,s3
	li	s2,1
.L5:
	addi	s0,s0,1
.L6:
	lbu	s3,0(s0)
	beq	s3,s1,.L2
	beqz	s1,.L3
	addi	a0,s5,%lo(.LC1)
	call	printf
	mv	a0,s1
	call	putx
	addi	a0,s4,%lo(.LC2)
	call	printf
	mv	a0,s2
	call	putx
	li	a0,32
	call	putchar
	j	.L3
.L2:
	addi	s2,s2,1
	j	.L5
.L4:
	lui	a0,%hi(.LC3)
	addi	a0,a0,%lo(.LC3)
	call	printf
	call	getchar
	lui	a5,%hi(.LC4)
	addi	a5,a5,%lo(.LC4)
	mv	a4,sp
	addi	a3,a5,264
.L7:
	lw	t1,0(a5)
	lw	a7,4(a5)
	lw	a6,8(a5)
	lw	a0,12(a5)
	lw	a1,16(a5)
	lw	a2,20(a5)
	sw	t1,0(a4)
	sw	a7,4(a4)
	sw	a6,8(a4)
	sw	a0,12(a4)
	sw	a1,16(a4)
	sw	a2,20(a4)
	addi	a5,a5,24
	addi	a4,a4,24
	bne	a5,a3,.L7
	lw	a3,0(a5)
	sw	a3,0(a4)
	lbu	a5,4(a5)
	sb	a5,4(a4)
	lui	a0,%hi(.LC5)
	addi	a0,a0,%lo(.LC5)
	call	printf
	lbu	a5,0(sp)
	beqz	a5,.L8
	mv	s2,sp
	li	s1,-1
.L11:
	mv	s3,a5
	addi	s2,s2,2
	lbu	a5,-1(s2)
	addi	s0,a5,-1
	beqz	a5,.L9
.L10:
	mv	a0,s3
	call	putchar
	addi	s0,s0,-1
	bne	s0,s1,.L10
.L9:
	lbu	a5,0(s2)
	bnez	a5,.L11
.L8:
	call	main
.L12:
	j	.L12
	.size	_start, .-_start
	.comm	io,4,4
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.ascii	"              vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv\n            "
	.ascii	"      vvvvvvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrr       vvvv"
	.ascii	"vvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrrrrr      vvvvvvvvvvvvvv"
	.ascii	"vvvvvvvvvv\nrrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\n"
	.ascii	"rrrrrrrrrrrrrrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrr"
	.ascii	"rrrrrr    vvvvvvvvvvvvvvvvvvvvvvvv\nrrrrrrrrrrrrrrrr      vv"
	.ascii	"vvvvvvvvvvvvvvvvvvvv  \nrrrrrrrrrrrrr       vvvvvvvvvvvvvvvv"
	.ascii	"vvvvvv    \nrr                vvvvvvvvvvvvvvvvvvvvvv      \n"
	.ascii	"rr            vvvvvvvvvvvvvvvvvvvvvvvv      rr\nrrrr      vv"
	.ascii	"vvvvvvvvvvvvvvvvvvvvvvvv      rrrr\nrrrrrr      vvvvvvvvvvvv"
	.ascii	"vvvvvvvvvv      rrrrrr\nrrrrrrrr      vvvvvvvvvvvvvvvvvv    "
	.ascii	"  rrrrrrrr\nrrrrrrrrrr      vvvvvvvvvvvvvv      rrrrrrrrrr\n"
	.ascii	"rrrrrrrrrrrr      vvvvvvvvvv      rrrrrrrrrrrr\nrrrrrrrrrrrr"
	.ascii	"rr      v"
	.string	"vvvvv      rrrrrrrrrrrrrr\nrrrrrrrrrrrrrrrr      vv      rrrrrrrrrrrrrrrr\nrrrrrrrrrrrrrrrrrr          rrrrrrrrrrrrrrrrrr\nrrrrrrrrrrrrrrrrrrrr      rrrrrrrrrrrrrrrrrrrr\nrrrrrrrrrrrrrrrrrrrrrr  rrrrrrrrrrrrrrrrrrrrrr\n\n       INSTRUCTION SETS WANT TO BE FREE\n\n"
	.zero	2
.LC1:
	.string	"0x"
	.zero	1
.LC2:
	.string	", 0x"
	.zero	3
.LC3:
	.string	"press any key to continue..."
	.zero	3
.LC5:
	.string	"\033[H\033[2J"
.LC4:
	.ascii	" \016v \n\001 \022v\034\n\001"
	.string	"r\r \007v\032\n\001r\020 \006v\030\n\001r\022 \004v\030\n\001r\022 \004v\030\n\001r\022 \004v\030\n\001r\020 \006v\026 \002\n\001r\r \007v\026 \004\n\001r\002 \020v\026 \006\n\001r\002 \fv\030 \006r\002\n\001r\004 \006v\032 \006r\004\n\001r\006 \006v\026 \006r\006\n\001r\b \006v\022 \006r\b\n\001r\n \006v\016 \006r\n\n\001r\f \006v\n \006r\f\n\001r\016 \006v\006 \006r\016\n\001r\020 \006v\002 \006r\020\n\001r\022 \nr\022\n\001r\024 \006r\024\n\001r\026 \002r\026\n\002 \007I\001N\001S\001T\001R\001U\001C\001T\001I\001O\001N\001 \001S\001E\001T\001S\001 \001W\001A\001N\001T\001 \001T\001O\001 \001B\001E\001 \001F\001R\001E\002\n\002"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
