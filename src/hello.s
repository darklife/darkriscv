	.file	"hello.c"
	.option nopic
	.text
	.align	2
	.globl	putchar
	.type	putchar, @function
putchar:
	li	a4,-2147483648
.L2:
	lw	a5,0(a4)
	bnez	a5,.L2
	sw	a0,0(a4)
	ret
	.size	putchar, .-putchar
	.align	2
	.globl	puts
	.type	puts, @function
puts:
	lbu	a3,0(a0)
	beqz	a3,.L6
	li	a4,-2147483648
.L8:
	addi	a0,a0,1
.L7:
	lw	a5,0(a4)
	bnez	a5,.L7
	sw	a3,0(a4)
	lbu	a3,0(a0)
	bnez	a3,.L8
.L6:
	li	a4,-2147483648
.L9:
	lw	a5,0(a4)
	bnez	a5,.L9
	li	a5,10
	sw	a5,0(a4)
	li	a4,-2147483648
.L10:
	lw	a5,0(a4)
	bnez	a5,.L10
	li	a5,13
	sw	a5,0(a4)
	ret
	.size	puts, .-puts
	.section	.text.startup,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
	lui	a3,%hi(.LC0)
	li	a2,104
	addi	a3,a3,%lo(.LC0)
	li	a4,-2147483648
.L20:
	addi	a3,a3,1
.L19:
	lw	a5,0(a4)
	bnez	a5,.L19
	sw	a2,0(a4)
	lbu	a2,0(a3)
	bnez	a2,.L20
	li	a4,-2147483648
.L21:
	lw	a5,0(a4)
	bnez	a5,.L21
	li	a5,10
	sw	a5,0(a4)
	li	a4,-2147483648
.L22:
	lw	a5,0(a4)
	bnez	a5,.L22
	li	a5,13
	sw	a5,0(a4)
	ret
	.size	main, .-main
	.section	.rodata.str1.4,"aMS",@progbits,1
	.align	2
.LC0:
	.string	"hello world!"
	.ident	"GCC: (GNU) 9.0.0 20180818 (experimental)"
