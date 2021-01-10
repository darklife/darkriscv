MEMORY
{
    IO (rw!x) : ORIGIN = 0x80000000, LENGTH = 0x10
    ROM (x!rw) : ORIGIN = 0x00000000, LENGTH = 0x1000
    RAM (rw!x) : ORIGIN = 0x00001000, LENGTH = 0x1000
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
    } > ROM
    .data :
    {
        *(.sbss)
        *(.rodata*)
        *(.data)
        *(.bss)
        *(.rela*)
 *(COMMON)
    } > RAM
}
