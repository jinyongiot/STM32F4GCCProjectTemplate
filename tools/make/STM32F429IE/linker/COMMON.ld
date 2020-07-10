/*
Common part of the linker scripts for STM32 devices
Copyright RAISONANCE 2009
You can use, modify and distribute this file freely, but without any waranty.
*/

/* Entry Point */
ENTRY(Reset_Handler)

/* Generate a link error if heap and stack don't fit into RAM */
_Min_Heap_Size = 0x200;      /* required amount of heap  */
_Min_Stack_Size = 0x400; /* required amount of stack */
