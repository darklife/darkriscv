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

	.option pic
	.section .text
	.align	2
    .globl  _start

/*
    start:
    - read and increent thread counter
    - case not zero, jump to multi thread boot
    - otherwise continue

    note: a5 register points to DarkIO block!
*/

_start:

    /* check core id, boot only core 0 */

    addi a0,x0,0
    csrr a0,mhartid
    beq  a0,x0,_uart_boot

_thread_lock:

    j _thread_lock

_uart_boot:
    
    /* check simulation, skip uart boot */

    la  a5,0x40000000
    lb  a0,0(a5)
    beq a0,x0,_normal_boot

/*
    uart boot here:
    
    - check for uart 5x w/ 1s timeout
    - case there is data, download it to main()
    - otherwise, go to normal boot
*/

    li  a0,'u'
    call _uart_putchar

    li a1,8192000
    la a2,main
    li a3,5

    _uart_boot_loop1:

        _uart_boot_loop2:

            addi a0,a1,0
            call _uart_getchar

            blt a0,x0,_uart_boot_exit

            sb a0,0(a2)
            addi a2,a2,1

            j _uart_boot_loop2

        _uart_boot_exit:

        li a0,'.'
        call _uart_putchar
        addi a3,a3,-1
        bgt a3,x0,_uart_boot_loop1

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
    RLE code start here:

    register int c,s;
    register char *p = rle_logo; // = a2
   
    while(*p)
    {
        c = *p++; // = a0
        s = *p++; // = a3
      
        while(s--) putchar(c); // uses a0, a5, a2
    }
*/

#ifndef NOBANNER

    addi a0,x0,'\n'
    call _uart_putchar

    lla a2,_rle_banner
    lla a1,_rle_dict

     lbu a3,0(a2)
   
    _rle_banner_loop1:
 
        srli a0,a3,6
        add a0,a0,a1
        lbu a0,0(a0)

        andi a3,a3,63
        addi a2,a2,1

        _rle_banner_loop2:

            call _uart_putchar
            addi a3,a3,-1

            bgt a3,x0,_rle_banner_loop2

        lbu a3,0(a2)
        bne a3,x0,_rle_banner_loop1        

    lla a2,_str_banner

    _str_banner_loop3:

        lbu a0,0(a2)
        beq a0,x0,_str_banner_loop4
        call _uart_putchar
        addi a2,a2,1
        j _str_banner_loop3

    _str_banner_loop4:

#endif

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
    - a5 = soc.uart0.stat
    - t0 = *soc.uart0.stat
    - a0 = return the same data
*/

_uart_putchar:

    _uart_putchar_busy:

        lb      t0,4(a5)
        not     t0,t0
        andi    t0,t0,1
        beq     t0,x0,_uart_putchar_busy

    sb a0,5(a5)
    li t0,'\n'

    bne a0,t0,_uart_putchar_exit

    li a0,'\r'
    j _uart_putchar

    _uart_putchar_exit:

        ret

/* 
    uart_getchar:

    - a0 = time out in loops
    - a5 = soc.uart0.stat
    - t0 = *soc.uart0.stat
    - a0 = return *soc.uart0.fifo or -1
*/

_uart_getchar:

    _uart_getchar_busy:

        beq     a0,x0,_uart_getchar_tout
        addi    a0,a0,-1

        lb      t0,4(a5)
        andi    t0,t0,2
        beq     t0,x0,_uart_getchar_busy

    lbu a0,5(a5)
    ret

    _uart_getchar_tout:

        li a0,-1
        ret

/*
    data segment here!
*/
/*
    .section .rodata
    .align   1
*/
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
