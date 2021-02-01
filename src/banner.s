	.file	"banner.c"
	.option nopic
	.text
	.align	2
	.globl	banner
	.type	banner, @function
banner:
	.LA0: auipc	a5,%pcrel_hi(.LC0)
	addi	sp,sp,-292
	addi	a5,a5,%pcrel_lo(.LA0)
	sw	ra,288(sp)
	sw	s0,284(sp)
	sw	s1,280(sp)
	addi	a4,sp,8
	addi	t2,a5,264
.L2:
	lw	t0,0(a5)
	lw	t1,4(a5)
	lw	a0,8(a5)
	lw	a1,12(a5)
	lw	a2,16(a5)
	lw	a3,20(a5)
	sw	t0,0(a4)
	sw	t1,4(a4)
	sw	a0,8(a4)
	sw	a1,12(a4)
	sw	a2,16(a4)
	sw	a3,20(a4)
	addi	a5,a5,24
	addi	a4,a4,24
	bne	a5,t2,.L2
	lw	a3,0(a5)
	lbu	a5,4(a5)
	li	a0,10
	sw	a3,0(a4)
	sb	a5,4(a4)
	li	a5,118
	sw	a5,4(sp)
	call	putchar
	addi	a5,sp,8
	sw	a5,0(sp)
	li	a4,14
	li	s0,32
.L7:
	lw	a5,0(sp)
	addi	s1,a4,-1
	addi	a5,a5,2
	sw	a5,0(sp)
	beqz	a4,.L6
.L3:
	mv	a0,s0
	call	putchar
	addi	s1,s1,-1
	li	a5,-1
	bne	s1,a5,.L3
.L6:
	lw	a5,4(sp)
	beqz	a5,.L14
	lw	a5,0(sp)
	lw	s0,4(sp)
	lbu	a4,1(a5)
	lbu	a5,2(a5)
	sw	a5,4(sp)
	j	.L7
.L14:
	lw	ra,288(sp)
	lw	s0,284(sp)
	lw	s1,280(sp)
	addi	sp,sp,292
	jr	ra
	.size	banner, .-banner
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.ascii	" \016v \n\001 \022v\034\n\001"
	.string	"r\r \007v\032\n\001r\020 \006v\030\n\001r\022 \004v\030\n\001r\022 \004v\030\n\001r\022 \004v\030\n\001r\020 \006v\026 \002\n\001r\r \007v\026 \004\n\001r\002 \020v\026 \006\n\001r\002 \fv\030 \006r\002\n\001r\004 \006v\032 \006r\004\n\001r\006 \006v\026 \006r\006\n\001r\b \006v\022 \006r\b\n\001r\n \006v\016 \006r\n\n\001r\f \006v\n \006r\f\n\001r\016 \006v\006 \006r\016\n\001r\020 \006v\002 \006r\020\n\001r\022 \nr\022\n\001r\024 \006r\024\n\001r\026 \002r\026\n\002 \007I\001N\001S\001T\001R\001U\001C\001T\001I\001O\001N\001 \001S\001E\001T\001S\001 \001W\001A\001N\001T\001 \001T\001O\001 \001B\001E\001 \001F\001R\001E\002\n\002"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
