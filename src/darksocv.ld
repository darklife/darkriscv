MEMORY
{
    XO : ORIGIN = 0x00000000, LENGTH = 4096
    RW : ORIGIN = 0x40000000, LENGTH = 4096
}

SECTIONS
{
    .text :
    {
        boot.o(.text)
        *(.text)
        *(.rodata)

    } > XO

    .data :
    {
        *(.data)

    } > RW

    .bss :
    {
        *(.bss)

    } > RW
}
