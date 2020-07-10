# Project's Makefile
# Copyright (c) 2011,2012 Bitcraze AB
# This Makefile compiles all the object file to ./bin/ and the resulting firmware
# image in ./cfX.elf and ./cfX.bin

PROJECT_BASE   ?= ./
SUBMODULE_BASE ?= $(PROJECT_BASE)/vendor
SRC_BASE       ?= $(PROJECT_BASE)/src
MKFILE_BASE    ?= $(PROJECT_BASE)/tools/mkfiles

CSRCS =
ASRCS =

CFLAGS =

######### JTAG and environment configuration ##########
OPENOCD           ?= openocd
OPENOCD_INTERFACE ?= interface/stlink-v2.cfg
OPENOCD_CMDS      ?=
CROSS_COMPILE     ?= arm-none-eabi-
PYTHON            ?= python3
DFU_UTIL          ?= dfu-util
CLOAD             ?= 0
USE_RTOS          ?= 1
DEBUG             ?= 0
PLATFORM          ?= template

# Platform configuration handling
include $(PROJECT_BASE)/tools/make/platform.mk

############### CPU-specific build configuration ################

ifeq ($(CPU), STM32F429IE)
LINKER_DIR = $(PROJECT_BASE)/tools/make/STM32F429IE/linker
ST_MK_DIR  = $(PROJECT_BASE)/tools/make/STM32F429IE

OPENOCD_TARGET    ?= target/stm32f4x_stlink.cfg

PROCESSOR = -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -fno-math-errno  -D__TARGET_FPU_VFP -mfp16-format=ieee

include $(ST_MK_DIR)/st.mk

CFLAGS += -DUSE_FULL_ASSERT=1U
CFLAGS += -DUSE_FULL_LL_DRIVER
CFLAGS += -DUSE_HAL_DRIVER
CFLAGS += -DSTM32F429xx

LOAD_ADDRESS_STM32F429IE = 0x8000000
LOAD_ADDRESS_CLOAD_STM32F429IE = 0x8004000
MEM_SIZE_FLASH_K = 496
MEM_SIZE_RAM_K = 192
MEM_SIZE_CCM_K = 64
endif

################ Build configuration ##################

# Project sources
include $(SRC_BASE)/src.mk

ifeq ($(USE_RTOS), 1)
  include $(MKFILE_BASE)/freertos.mk
endif

OBJ  = version.o
OBJ += $(CSRCS:%.c=%.o)
OBJ += $(ASRCS:%.s=%.o)

############### Compilation configuration ################
AS = $(CROSS_COMPILE)as
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)gcc
SIZE = $(CROSS_COMPILE)size
OBJCOPY = $(CROSS_COMPILE)objcopy
GDB = $(CROSS_COMPILE)gdb

ifeq ($(DEBUG), 1)
  CFLAGS += -O0 -g3 -DDEBUG
  # Prevent silent errors when converting between types (requires explicit casting)
  CFLAGS += -Wconversion
else
	# Fail on warnings
  CFLAGS += -Os -g3 -Werror
endif

ifeq ($(LTO), 1)
  CFLAGS += -flto
endif

CFLAGS += $(PROCESSOR)


CFLAGS += -Wall -Wmissing-braces -fno-strict-aliasing $(C_PROFILE) -std=gnu11
# Compiler flags to generate dependency files:
CFLAGS += -MD -MP -MF $(BIN)/dep/$(@).d -MQ $(@)
#Permits to remove un-used functions and global variables from output file
CFLAGS += -ffunction-sections -fdata-sections
# Prevent promoting floats to doubles
CFLAGS += -Wdouble-promotion


ASFLAGS = $(CCFLAGS)
LDFLAGS = --specs=nosys.specs --specs=nano.specs $(PROCESSOR) -Wl,-Map=$(PROG).map,--cref,--gc-sections,--undefined=uxTopUsedPriority
LDFLAGS += -L$(LINKER_DIR)

#Flags required by the ST library
ifeq ($(CLOAD), 1)
  LDFLAGS += -T $(LINKER_DIR)/FLASH_CLOAD.ld
  LOAD_ADDRESS = $(LOAD_ADDRESS_CLOAD_$(CPU))
else
  LDFLAGS += -T $(LINKER_DIR)/FLASH.ld
  LOAD_ADDRESS = $(LOAD_ADDRESS_$(CPU))
endif

ifeq ($(LTO), 1)
  LDFLAGS += -Os -flto -fuse-linker-plugin
endif

#Program name
PROG = $(PLATFORM)
#Where to compile the .o
BIN = bin
VPATH += $(BIN)

#Dependency files to include
DEPS := $(foreach o,$(OBJ),$(BIN)/dep/$(o).d)

#################### Targets ###############################


all: bin/ bin/dep build check_submodules
build:
# Each target is in a different line, so they are executed one after the other even when the processor has multiple cores (when the -j option for the make command is > 1). See: https://www.gnu.org/software/make/manual/html_node/Parallel.html
	@$(MAKE) --no-print-directory clean_version PROJECT_BASE=$(PROJECT_BASE)
	@$(MAKE) --no-print-directory compile PROJECT_BASE=$(PROJECT_BASE)
	@$(MAKE) --no-print-directory print_version PROJECT_BASE=$(PROJECT_BASE)
	@$(MAKE) --no-print-directory size PROJECT_BASE=$(PROJECT_BASE)
compile: $(PROG).hex $(PROG).bin $(PROG).dfu

bin/:
	mkdir -p bin

bin/dep:
	mkdir -p bin/dep

clean_version:
ifeq ($(SHELL),/bin/sh)
	@echo "  CLEAN_VERSION"
	@rm -f version.c
endif

print_version:
	@echo "Build for the $(PLATFORM_NAME_$(PLATFORM))!"
	@$(PYTHON) $(PROJECT_BASE)/tools/make/versionTemplate.py --project-base $(PROJECT_BASE) --print-version
ifeq ($(CLOAD), 1)
	@echo "Bootloader build!"
endif
ifeq ($(FATFS_DISKIO_TESTS), 1)
	@echo "WARNING: FatFS diskio tests enabled. Erases SD-card!"
endif

size:
	@$(PYTHON) $(PROJECT_BASE)/tools/make/size.py $(SIZE) $(PROG).elf $(MEM_SIZE_FLASH_K) $(MEM_SIZE_RAM_K) $(MEM_SIZE_CCM_K)

#Flash the stm.
flash:
	$(OPENOCD) -d2 -f $(OPENOCD_INTERFACE) $(OPENOCD_CMDS) -f $(OPENOCD_TARGET) -c init -c targets -c "reset halt" \
                 -c "flash write_image erase $(PROG).bin $(LOAD_ADDRESS) bin" \
                 -c "verify_image $(PROG).bin $(LOAD_ADDRESS) bin" -c "reset run" -c shutdown

#verify only
flash_verify:
	$(OPENOCD) -d2 -f $(OPENOCD_INTERFACE) $(OPENOCD_CMDS) -f $(OPENOCD_TARGET) -c init -c targets -c "reset halt" \
                 -c "verify_image $(PROG).bin $(LOAD_ADDRESS) bin" -c "reset run" -c shutdown

flash_dfu:
	$(DFU_UTIL) -a 0 -D $(PROG).dfu

#STM utility targets
halt:
	$(OPENOCD) -d0 -f $(OPENOCD_INTERFACE) $(OPENOCD_CMDS) -f $(OPENOCD_TARGET) -c init -c targets -c "halt" -c shutdown

reset:
	$(OPENOCD) -d0 -f $(OPENOCD_INTERFACE) $(OPENOCD_CMDS) -f $(OPENOCD_TARGET) -c init -c targets -c "reset" -c shutdown

openocd:
	$(OPENOCD) -d2 -f $(OPENOCD_INTERFACE) $(OPENOCD_CMDS) -f $(OPENOCD_TARGET) -c init -c targets -c "\$$_TARGETNAME configure -rtos auto"

trace:
	$(OPENOCD) -d2 -f $(OPENOCD_INTERFACE) $(OPENOCD_CMDS) -f $(OPENOCD_TARGET) -c init -c targets -f tools/trace/enable_trace.cfg

gdb: $(PROG).elf
	$(GDB) -ex "target remote localhost:3333" -ex "monitor reset halt" $^

erase:
	$(OPENOCD) -d2 -f $(OPENOCD_INTERFACE) -f $(OPENOCD_TARGET) -c init -c targets -c "halt" -c "stm32f4x mass_erase 0" -c shutdown

#Print preprocessor #defines
prep:
	@$(CC) $(CFLAGS) -dM -E - < /dev/null

check_submodules:
	@cd $(PROJECT_BASE); $(PYTHON) tools/make/check-for-submodules.py

include $(PROJECT_BASE)/tools/make/targets.mk

#include dependencies
-include $(DEPS)

unit:
# The flag "-DUNITY_INCLUDE_DOUBLE" allows comparison of double values in Unity. See: https://stackoverflow.com/a/37790196
	rake unit "DEFINES=$(CFLAGS) -DUNITY_INCLUDE_DOUBLE" "FILES=$(FILES)" "UNIT_TEST_STYLE=$(UNIT_TEST_STYLE)"
