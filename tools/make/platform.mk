# Platform handling

# List all available platform
platforms_files = $(wildcard $(PROJECT_BASE)/tools/make/platforms/*.mk)
platforms_available = $(patsubst $(PROJECT_BASE)/tools/make/platforms/%.mk,%, $(platforms_files))

# Find out if the requested platform exists
ifeq ($(filter $(PLATFORM),$(platforms_available)),)
$(info Platform '$(PLATFORM)' not found!)
$(info -------------------)
override PLATFORM=
undefine PLATFORM
endif

# Include the platform makefile configuration
include $(PROJECT_BASE)/tools/make/platforms/$(PLATFORM).mk
