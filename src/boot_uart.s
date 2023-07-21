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
	- read and increent thread counter
	- case not zero, jump to multi thread boot
	- otherwise continue	
*/

_start:

	la	a0,threads
	lw 	a1,0(a0)
	addi	a2,a1,1
	sw	a2,0(a0)
	la	a3,io
	bne	a1,x0,_multi_thread_boot

    la  a0,0x80000000
    lb  a0,0(a0)
    beq a0,x0,_normal_boot

/*
    uart boot here:
    
    - check for uart 3x w/ 1s timeout
    - case there is data, download it to main()
    - otherwise, go to normal boot
*/

    li  a0,'u'
    call _uart_putchar

    la a3,main
    li a4,5
    li a5,8192000

    _uart_boot_loop1:

        _uart_boot_loop2:

            addi a0,a5,0
            call _uart_getchar

            blt a0,x0,_uart_boot_exit

            sb a0,0(a3)
            addi a3,a3,1

            j _uart_boot_loop2

        _uart_boot_exit:
        
        li a0,'.'
        call _uart_putchar
        addi a4,a4,-1
        bgt a4,x0,_uart_boot_loop1

    li  a0,'b'

    call _uart_putchar

/*
	normal boot here:

	- call main
	- set stack
	- set global pointer
	- plot boot banner
	- repeat forever
*/

_normal_boot:

/*
    register int c,s;
    register char *p = rle_logo; // = a3
   
    while(*p)
    {
        c = *p++; // = a0
        s = *p++; // = a4
      
        while(s--) putchar(c); // uses a0, a1, a2
    }
*/
    addi a0,x0,'\n'
    call _uart_putchar

    la a3,_rle_banner
   
    _rle_banner_loop1:
 
        lbu a0,0(a3)
        lbu a4,1(a3)
        addi a3,a3,2

        _rle_banner_loop2:

            call _uart_putchar
            addi a4,a4,-1

        bgt a4,x0,_rle_banner_loop2
        
    bne a0,x0,_rle_banner_loop1    

    la a3,_str_banner

    _str_banner_loop:

        lbu a0,0(a3)
        call _uart_putchar
        addi a3,a3,1
        bne a0,x0,_str_banner_loop

	la	sp,_stack
	la	gp,_global

    xor    a0,a0,a0 /* argc = 0 */
    xor    a1,a1,a1 /* argv = 0 */
    xor    a2,a2,a2 /* envp = 0 */

	call	main

	j	_start

/*
	multi-thread boot:
	- set io base
	- write thread number to io.gpio
	- increent thread number
	- repeat forever
*/

_multi_thread_boot:

	sh	a1,10(a3)
	addi	a1,a1,1
	j 	_multi_thread_boot

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
    uart_getchar:

    - a0 = time out in loops
    - a1 = soc.uart0.stat
    - a2 = *soc.uart0.stat
    - a0 = return *soc.uart0.fifo or -1
*/

_uart_getchar:

    la  a1,0x80000000

    _uart_getchar_busy:

        beq     a0,x0,_uart_getchar_tout
        addi    a0,a0,-1

        lb      a2,4(a1)
        andi    a2,a2,2
        beq     a2,x0,_uart_getchar_busy

    lbu a0,5(a1)
    ret

    _uart_getchar_tout:

        li a0,-1
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

set_mtvec:
    csrw mtvec,a0
    ret

set_mepc:
    csrw mepc,a0
    ret

set_mie:
    csrw mie,a0
    ret

get_mtvec:
    addi  a0,x0,0
    csrr a0,mtvec
    ret

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

/*
    data segment here!
*/

       .section .rodata
       .align   2

_rle_banner:

    .byte 0x20, 0x0e, 0x76, 0x20, 0x0a, 0x01, 0x20, 0x12, 0x76, 0x1c, 0x0a
    .byte 0x01, 0x72, 0x0d, 0x20, 0x07, 0x76, 0x1a, 0x0a, 0x01, 0x72, 0x10
    .byte 0x20, 0x06, 0x76, 0x18, 0x0a, 0x01, 0x72, 0x12, 0x20, 0x04, 0x76
    .byte 0x18, 0x0a, 0x01, 0x72, 0x12, 0x20, 0x04, 0x76, 0x18, 0x0a, 0x01
    .byte 0x72, 0x12, 0x20, 0x04, 0x76, 0x18, 0x0a, 0x01, 0x72, 0x10, 0x20
    .byte 0x06, 0x76, 0x16, 0x20, 0x02, 0x0a, 0x01, 0x72, 0x0d, 0x20, 0x07
    .byte 0x76, 0x16, 0x20, 0x04, 0x0a, 0x01, 0x72, 0x02, 0x20, 0x10, 0x76
    .byte 0x16, 0x20, 0x06, 0x0a, 0x01, 0x72, 0x02, 0x20, 0x0c, 0x76, 0x18
    .byte 0x20, 0x06, 0x72, 0x02, 0x0a, 0x01, 0x72, 0x04, 0x20, 0x06, 0x76
    .byte 0x1a, 0x20, 0x06, 0x72, 0x04, 0x0a, 0x01, 0x72, 0x06, 0x20, 0x06
    .byte 0x76, 0x16, 0x20, 0x06, 0x72, 0x06, 0x0a, 0x01, 0x72, 0x08, 0x20
    .byte 0x06, 0x76, 0x12, 0x20, 0x06, 0x72, 0x08, 0x0a, 0x01, 0x72, 0x0a
    .byte 0x20, 0x06, 0x76, 0x0e, 0x20, 0x06, 0x72, 0x0a, 0x0a, 0x01, 0x72
    .byte 0x0c, 0x20, 0x06, 0x76, 0x0a, 0x20, 0x06, 0x72, 0x0c, 0x0a, 0x01
    .byte 0x72, 0x0e, 0x20, 0x06, 0x76, 0x06, 0x20, 0x06, 0x72, 0x0e, 0x0a
    .byte 0x01, 0x72, 0x10, 0x20, 0x06, 0x76, 0x02, 0x20, 0x06, 0x72, 0x10
    .byte 0x0a, 0x01, 0x72, 0x12, 0x20, 0x0a, 0x72, 0x12, 0x0a, 0x01, 0x72
    .byte 0x14, 0x20, 0x06, 0x72, 0x14, 0x0a, 0x01, 0x72, 0x16, 0x20, 0x02
    .byte 0x72, 0x16, 0x0a, 0x01, 0x0a, 0x01, 0x20, 0x07, 0x00 

_str_banner:
    .string "INSTRUCTION SETS WANT TO BE FREE\n\n"

        .section .data
        .align   2

threads:
    .word  0
