
VPATH += $(SUBMODULE_BASE)/STM32CubeF4/Drivers/STM32F4xx_HAL_Driver/Src

CFLAGS += "-I$(SUBMODULE_BASE)/STM32CubeF4/Drivers/STM32F4xx_HAL_Driver/Inc"
CFLAGS += "-I$(SUBMODULE_BASE)/STM32CubeF4/Drivers/STM32F4xx_HAL_Driver/Inc/Legacy"
CFLAGS += "-I$(SUBMODULE_BASE)/STM32CubeF4/Drivers/CMSIS/Device/ST/STM32F4xx/Include"
CFLAGS += "-I$(SUBMODULE_BASE)/STM32CubeF4/Drivers/CMSIS/Include"

CSRCS += stm32f4xx_ll_gpio.c
CSRCS += stm32f4xx_ll_rcc.c
CSRCS += stm32f4xx_ll_utils.c
CSRCS += stm32f4xx_ll_exti.c

CSRCS += stm32f4xx_hal_tim.c
CSRCS += stm32f4xx_hal_tim_ex.c
CSRCS += stm32f4xx_hal_rcc.c
CSRCS += stm32f4xx_hal_rcc_ex.c
CSRCS += stm32f4xx_hal_flash.c
CSRCS += stm32f4xx_hal_flash_ex.c
CSRCS += stm32f4xx_hal_flash_ramfunc.c
CSRCS += stm32f4xx_hal_gpio.c
CSRCS += stm32f4xx_hal_dma_ex.c
CSRCS += stm32f4xx_hal_dma.c
CSRCS += stm32f4xx_hal_pwr.c
CSRCS += stm32f4xx_hal_pwr_ex.c
CSRCS += stm32f4xx_hal_cortex.c
CSRCS += stm32f4xx_hal.c
CSRCS += stm32f4xx_hal_exti.c
