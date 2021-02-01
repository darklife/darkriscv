MEMORY
{
    IO (rw!x) : ORIGIN = 0x80000000, LENGTH = 0x10
    MEM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x2000
}
SECTIONS
{
    .text :
    {
        *(.boot)
        *(.text)
    } > MEM
    .data :
    {
        *(.rodata*)
        *(.data)
        _global = . + 0x800;
        *(.sbss)
        *(.bss)
 _heap = .;
    } > MEM
   PROVIDE ( _stack = ORIGIN(MEM) + LENGTH(MEM) );
    .io : { io.o(COMMON) } > IO
}
