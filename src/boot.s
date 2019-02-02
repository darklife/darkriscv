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
	lui	a5,%hi(.LC0)
	addi	a5,a5,%lo(.LC0)
	mv	a4,sp
	addi	a3,a5,264
.L2:
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
	bne	a5,a3,.L2
	lw	a3,0(a5)
	sw	a3,0(a4)
	lbu	a5,4(a5)
	sb	a5,4(a4)
	lui	a0,%hi(.LC1)
	addi	a0,a0,%lo(.LC1)
	call	printf
	lbu	a5,0(sp)
	beqz	a5,.L3
	mv	s2,sp
	li	s1,-1
.L6:
	mv	s3,a5
	addi	s2,s2,2
	lbu	a5,-1(s2)
	addi	s0,a5,-1
	beqz	a5,.L4
.L5:
	mv	a0,s3
	call	putchar
	addi	s0,s0,-1
	bne	s0,s1,.L5
.L4:
	lbu	a5,0(s2)
	bnez	a5,.L6
.L3:
	call	main
.L7:
	j	.L7
	.size	_start, .-_start
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC1:
	.string	"\033[H\033[2J"
.LC0:
	.ascii	" \016v \n\001 \022v\034\n\001"
	.string	"r\r \007v\032\n\001r\020 \006v\030\n\001r\022 \004v\030\n\001r\022 \004v\030\n\001r\022 \004v\030\n\001r\020 \006v\026 \002\n\001r\r \007v\026 \004\n\001r\002 \020v\026 \006\n\001r\002 \fv\030 \006r\002\n\001r\004 \006v\032 \006r\004\n\001r\006 \006v\026 \006r\006\n\001r\b \006v\022 \006r\b\n\001r\n \006v\016 \006r\n\n\001r\f \006v\n \006r\f\n\001r\016 \006v\006 \006r\016\n\001r\020 \006v\002 \006r\020\n\001r\022 \nr\022\n\001r\024 \006r\024\n\001r\026 \002r\026\n\002 \007I\001N\001S\001T\001R\001U\001C\001T\001I\001O\001N\001 \001S\001E\001T\001S\001 \001W\001A\001N\001T\001 \001T\001O\001 \001B\001E\001 \001F\001R\001E\002\n\002"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
