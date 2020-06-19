MEMORY
{
    IO (rw!x) : ORIGIN = 0x80000000, LENGTH = 0x10
    MEM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x2000
}
SECTIONS
{
    .io :
    {
        io.o(COMMON)
    } > IO
    .text :
    {
        boot.o(.text)
        *(.text)
    } > MEM
    .data :
    {
        *(.sbss)
        *(.rodata*)
        *(.data)
        *(.bss)
        *(.rela*)
 *(COMMON)
    } > MEM
}
