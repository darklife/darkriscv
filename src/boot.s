/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

	.option nopic
	.text
	.section .text
	.align	2
    .globl  _start
	.globl  check4rv32i
    .globl  set_mtvec
    .globl  set_mepc
    .globl  set_mie
    .globl  get_mtvec
    .globl  get_mepc
    .globl  get_mie
    .globl  get_mip
    .globl  threads

/*
	start:

        - RV banner
        - set gp/sp
        - set argc,argv,argp
        - call main
        - repeat
*/

_start:
   
    /* check core id, boot only core 0 */

    la a1,0x80000000
    lbu a2,2(a1)

_thread_lock:
    bne a2,x0,_thread_lock

    addi a0,x0,'\n'
    call _uart_putchar

    /* RLL banner code begin */

    la a3,_rle_banner
    la a5,_rle_dict
   
    _rle_banner_loop1:
 
        lbu a4,0(a3)

        beq a4,x0,_rle_banner_end

        srli a0,a4,6
        add a0,a0,a5
        lbu a0,0(a0)

        andi a4,a4,63
        addi a3,a3,1

        _rle_banner_loop2:

            call _uart_putchar
            addi a4,a4,-1

            bgt a4,x0,_rle_banner_loop2

        j _rle_banner_loop1

    _rle_banner_end:

        la a3,_str_banner

        _str_banner_loop3:

            lbu a0,0(a3)
            call _uart_putchar
            addi a3,a3,1
            bne a0,x0,_str_banner_loop3

    /* RLL banner code end */

	la	sp,_stack
	la	gp,_global

    xor    a0,a0,a0 /* argc = 0 */
    xor    a1,a1,a1 /* argv = 0 */
    xor    a2,a2,a2 /* envp = 0 */

	call	main

	j	_start

/* 
    uart_putchar:
    
    - wait until not busy
    - a0 = char to print
    - a1 = soc.uart0.stat
    - a2 = *soc.uart0.stat
    - a0 = return the same data
*/

_uart_putchar:

    la a1,0x80000000

    _uart_putchar_busy:

        lb      a2,4(a1)
        not     a2,a2
        andi    a2,a2,1
        beq     a2,x0,_uart_putchar_busy

    sb a0,5(a1)
    li a1,'\n'

    bne a0,a1,_uart_putchar_exit

    li a0,'\r'
    j _uart_putchar

    _uart_putchar_exit:

        ret

/*
	rv32e/rv32i detection:
	- set x15 0
	- set x31 1
	- sub x31-x15 and return the value
	why this works?!
	- the rv32i have separate x15 and x31, but the rv32e will make x15 = x31
	- this "feature" probably works only in the darkriscv! :)
*/

check4rv32i:

        .word 	0x00000793 	/* addi    x15,x0,0   */
        .word   0x00100f93	/* addi    x31,x0,1   */
        .word   0x40ff8533	/* sub     a0,x31,x15 */

	ret

/*
    access to CSR registers (set/get)
*/

get_mtvec:
    addi  a0,x0,0
    csrr a0,mtvec
    ret
/*
get_mepc:
    addi a0,x0,0
    csrr a0,mepc
    ret

get_mie:
    addi a0,x0,0
    csrr a0,mie
    ret

get_mip:
    addi a0,x0,0
    csrr a0,mip
    ret

set_mtvec:
    csrw mtvec,a0
    ret

set_mepc:
    csrw mepc,a0
    ret

set_mie:
    csrw mie,a0
    ret
*/
/*
    data segment here!
*/

       .section .rodata
       .align   2

_rle_banner:

    .byte 0x0e, 0xa0, 0xc1, 0x12, 0x9c, 0xc1, 0x4d, 0x07, 0x9a, 0xc1, 0x50 
    .byte 0x06, 0x98, 0xc1, 0x52, 0x04, 0x98, 0xc1, 0x52, 0x04, 0x98, 0xc1 
    .byte 0x52, 0x04, 0x98, 0xc1, 0x50, 0x06, 0x96, 0x02, 0xc1, 0x4d, 0x07 
    .byte 0x96, 0x04, 0xc1, 0x42, 0x10, 0x96, 0x06, 0xc1, 0x42, 0x0c, 0x98 
    .byte 0x06, 0x42, 0xc1, 0x44, 0x06, 0x9a, 0x06, 0x44, 0xc1, 0x46, 0x06 
    .byte 0x96, 0x06, 0x46, 0xc1, 0x48, 0x06, 0x92, 0x06, 0x48, 0xc1, 0x4a 
    .byte 0x06, 0x8e, 0x06, 0x4a, 0xc1, 0x4c, 0x06, 0x8a, 0x06, 0x4c, 0xc1 
    .byte 0x4e, 0x06, 0x86, 0x06, 0x4e, 0xc1, 0x50, 0x06, 0x82, 0x06, 0x50 
    .byte 0xc1, 0x52, 0x0a, 0x52, 0xc1, 0x54, 0x06, 0x54, 0xc1, 0x56, 0x02 
    .byte 0x56, 0xc2, 0x07, 0x00

_rle_dict:
    
    .byte 0x20, 0x72, 0x76, 0x0a

_str_banner:
    .string "INSTRUCTION SETS WANT TO BE FREE\n\n"

        .section .data
        .align   2

threads:
    .word  1
