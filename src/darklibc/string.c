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

#include <string.h>
#include <stddef.h>

// string manipulation

char *strncpy(char *s1,char *s2,int len)
{
    char *ret = s1;

    while(--len && (*s1++=*s2++));
    
    return ret;
}


char *strcpy(char *s1,char *s2)
{
    return strncpy(s1,s2,-1);
}

int strncmp(char *s1,char *s2,int len)
{
    while(--len && *s1 && *s2 && (*s1==*s2)) s1++, s2++;
    
    return (*s1-*s2);
}

int strcmp(char *s1, char *s2)
{
    return strncmp(s1,s2,-1);
}

int strlen(char *s1)
{
    int len;
    
    for(len=0;s1&&*s1++;len++);

    return len;
}

char *strtok(char *str,char *dptr)
{
    static char *nxt = NULL;

    int dlen = strlen(dptr);
    char *tmp;

         if(str) tmp=str;
    else if(nxt) tmp=nxt;
    else return NULL;
    
    char *ret=tmp;

    while(*tmp)
    {
        if(strncmp(tmp,dptr,dlen)==0)
        {
            *tmp=NUL;
            nxt = tmp+1;
            return ret;
        }
        tmp++;
    }
    nxt = NULL;
    return ret;
}

// memory manipulation

char *memcpy(char *dptr,char *sptr,int len)
{
    char *ret = dptr;

    while(len--) *dptr++ = *sptr++;

    return ret;
}

char *memcmp(char *dptr, char *sptr,int len)
{
    while(len--)
        if(*dptr++ != *sptr++) 
            return --dptr;

    return 0;
}

char *memset(char *dptr, int c, int len)
{
    char *ret = dptr;
    
    while(len--) *dptr++ = c;
    
    return ret;
}
