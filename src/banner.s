	.file	"banner.c"
	.option nopic
	.text
	.align	2
	.globl	banner
	.type	banner, @function
banner:
	addi	sp,sp,-288
	.LA0: auipc	a1,%pcrel_hi(.LC0)
	li	a2,269
	addi	a1,a1,%pcrel_lo(.LA0)
	addi	a0,sp,4
	sw	ra,284(sp)
	sw	s0,280(sp)
	sw	s1,276(sp)
	call	memcpy
	li	a0,10
	call	putchar
	addi	s0,sp,4
.L2:
	lbu	a5,0(s0)
	bnez	a5,.L5
	lw	ra,284(sp)
	lw	s0,280(sp)
	lw	s1,276(sp)
	addi	sp,sp,288
	jr	ra
.L5:
	addi	s0,s0,2
	lbu	s1,-1(s0)
.L3:
	addi	s1,s1,-1
	li	a4,-1
	beq	s1,a4,.L2
	mv	a0,a5
	sw	a5,0(sp)
	call	putchar
	lw	a5,0(sp)
	j	.L3
	.size	banner, .-banner
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.ascii	" \016v \n\001 \022v\034\n\001"
	.string	"r\r \007v\032\n\001r\020 \006v\030\n\001r\022 \004v\030\n\001r\022 \004v\030\n\001r\022 \004v\030\n\001r\020 \006v\026 \002\n\001r\r \007v\026 \004\n\001r\002 \020v\026 \006\n\001r\002 \fv\030 \006r\002\n\001r\004 \006v\032 \006r\004\n\001r\006 \006v\026 \006r\006\n\001r\b \006v\022 \006r\b\n\001r\n \006v\016 \006r\n\n\001r\f \006v\n \006r\f\n\001r\016 \006v\006 \006r\016\n\001r\020 \006v\002 \006r\020\n\001r\022 \nr\022\n\001r\024 \006r\024\n\001r\026 \002r\026\n\002 \007I\001N\001S\001T\001R\001U\001C\001T\001I\001O\001N\001 \001S\001E\001T\001S\001 \001W\001A\001N\001T\001 \001T\001O\001 \001B\001E\001 \001F\001R\001E\002\n\002"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
