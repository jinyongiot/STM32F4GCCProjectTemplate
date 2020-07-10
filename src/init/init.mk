VPATH += $(SRC_BASE)/init

CFLAGS += "-I$(SRC_BASE)/init"

CSRCS += main.c
CSRCS += lowleveldriver.c
CSRCS += system_stm32f4xx.c
CSRCS += stm32f4xx_hal_timebase_tim.c

ASRCS += startup_stm32f429xx.s
