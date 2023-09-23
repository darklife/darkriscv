/* 
 * Ported by Marcelo Samsoniuk, based on BASIC code from Satoshi Okue
 * https://twitter.com/okazunori68/status/1629832782280282113/photo/2
 *
 */

#include <stdio.h>

int main()
{
    int f,c,d,a,b,p,q,s,t,i,x,y;
    char *hex="0123456789ABCDEF";

        f=50; y=-12;    

    loop30:
    
        x=-39;
    
    loop40:
    
        c=x*229/100; d=y*416/100; a=c; b=d; i=0;

    loop90:
    
        q=b/f; s=b-q*f; t=(a*a-b*b)/f+c; b=2*(a*q+a*s/f)+d; a=t; p=a/f; q=b/f; 
        if((p*p+q*q)>4) goto loop180; 
        i++; 
        if(i<=15) goto loop90;
        printf(" ");        
        goto loop250;
        
    loop180:
                
        putchar(hex[(int)i]); // this line replace the BASIC lines 180-240

    loop250:
        
        x++;
        if(x<=39) goto loop40;
        printf("\n"); y++;
        if(y<=12) goto loop30;
        printf("ok\n");

        printf("press <enter> to restart...");
        getchar();
        return 0;
}
