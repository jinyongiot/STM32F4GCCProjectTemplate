/* Specify the memory areas */

MEMORY
{
  RAM (xrw)      : ORIGIN = 0x20000000, LENGTH = 192K
  CCMRAM (xrw)   : ORIGIN = 0x10000000, LENGTH = 64K
  FLASH (rx)     : ORIGIN = 0x8004000,  LENGTH = 496K
}

/* higher address of the user mode stack */
_estack = 0x20030000;
