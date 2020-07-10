CFLAGS += "-I$(SRC_BASE)/config"

ifeq ($(USE_RTOS), 1)
  VPATH += $(SRC_BASE)/config
  CSRCS += FreeRTOSConfig.c
endif