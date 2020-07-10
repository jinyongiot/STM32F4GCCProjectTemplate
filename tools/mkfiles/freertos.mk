VPATH += $(SUBMODULE_BASE)/FreeRTOS
VPATH += $(SUBMODULE_BASE)/FreeRTOS/portable/MemMang
VPATH += $(SUBMODULE_BASE)/FreeRTOS/portable/GCC/ARM_CM4F

CFLAGS += "-I$(SUBMODULE_BASE)/FreeRTOS/include"
CFLAGS += "-I$(SUBMODULE_BASE)/FreeRTOS/portable/GCC/ARM_CM4F"

CSRCS += croutine.c
CSRCS += event_groups.c
CSRCS += list.c
CSRCS += queue.c
CSRCS += stream_buffer.c
CSRCS += tasks.c
CSRCS += timers.c

CSRCS += port.c
CSRCS += heap_4.c
