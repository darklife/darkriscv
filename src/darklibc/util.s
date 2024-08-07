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
    .text
    .section .text
    .align  2

    .globl  check4rv32i

    .globl  set_mstatus
    .globl  set_mtvec
    .globl  set_stvec
    .globl  set_mepc
    .globl  set_sepc
    .globl  set_mie

    .globl  get_mstatus
    .globl  get_mtvec
    .globl  get_stvec
    .globl  get_mepc
    .globl  get_sepc
    .globl  get_mie
    .globl  get_mip
    .globl  get_mcause
    .globl  get_mhartid

check4rv32i:

        .word   0x00000793  /* addi    x15,x0,0   */
        .word   0x00100f93  /* addi    x31,x0,1   */
        .word   0x40ff8533  /* sub     a0,x31,x15 */

    ret

/*
    access to CSR registers (set/get)
    always clear a0 before! because it will return zero case the csr
    instruction is not implemented...
*/

get_mstatus:
    addi a0,x0,0
    csrr a0,mstatus
    ret

get_mcause:
    addi  a0,x0,0
    csrr  a0,mcause
    ret

get_mhartid:
    addi  a0,x0,0
    csrr  a0,mhartid
    ret

get_mtvec:
    addi  a0,x0,0
    csrr a0,mtvec
    ret

get_mepc:
    addi a0,x0,0
    csrr a0,mepc
    ret

get_stvec:
    addi  a0,x0,0
    csrr a0,stvec
    ret

get_sepc:
    addi a0,x0,0
    csrr a0,sepc
    ret

get_mie:
    addi a0,x0,0
    csrr a0,mie
    ret

get_mip:
    addi a0,x0,0
    csrr a0,mip
    ret

set_mstatus:
    csrw mstatus,a0
    ret

set_mtvec:
    csrw mtvec,a0
    ret

set_mepc:
    csrw mepc,a0
    ret

set_stvec:
    csrw stvec,a0
    ret

set_sepc:
    csrw sepc,a0
    ret

set_mie:
    csrw mie,a0
    ret

/* csr instruction test */

.globl csr_test

csr_test:
    
    csrw mscratch,a0
    csrs mscratch,a1
    csrc mscratch,a2
    csrr a0,mscratch
    ret
