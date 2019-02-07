.DEFAULT_GOAL := all

############################################################################################
# General config
MAIN_SRC = main.c
MAP_FILE = memory.map
OUT_DIR = build
OUT_NAME = main
OUT_PATH = $(OUT_DIR)/$(OUT_NAME)
ifeq ($(OS),Windows_NT)
	MSP430_GCC_PATH = C:/ti/msp430-gcc
else
	MSP430_GCC_PATH = ~/ti/msp430-gcc
endif

############################################################################################
# Target-related files
LINKER_FILE = msp430f5529.ld
SUPPORT_FILES = $(MSP430_GCC_PATH)/include

############################################################################################
# Executables
CC = $(MSP430_GCC_PATH)/bin/msp430-elf-gcc
OBJCOPY = $(MSP430_GCC_PATH)/bin/msp430-elf-objcopy
CODESIZE = $(MSP430_GCC_PATH)/bin/msp430-elf-size

############################################################################################
# Hardware Abstraction Layer / TI Driverlib
HAL_DIR = driverlib
HAL_SRC = $(wildcard $(HAL_DIR)/*.c)

############################################################################################
# FreeRTOS Sources
FREERTOS_DIR = FreeRTOS/Source
FREERTOS_SRC = $(wildcard $(FREERTOS_DIR)/*.c) $(wildcard $(FREERTOS_DIR)/portable/GCC/MSP430F5529/*.c)
MEMORY_MGMT_SRC = $(wildcard $(FREERTOS_DIR)/portable/MemMang/*.c)

############################################################################################
# Objects
OBJECTS = $(MAIN_SRC:.c=.o) $(FREERTOS_SRC:.c=.o) $(MEMORY_MGMT_SRC:.c=.o) $(HAL_SRC:.c=.o)

############################################################################################
# Flags
CFLAGS += -mmcu=msp430f5529
CFLAGS += -I$(FREERTOS_DIR)/include -I$(FREERTOS_DIR)/portable/GCC/MSP430F5529 -Iinclude -I$(HAL_DIR) -I$(SUPPORT_FILES) 

# Linker flags
LDFLAGS += -mmcu=msp430f5529
LDFLAGS += -T$(LINKER_FILE) -L$(SUPPORT_FILES)

ifdef DEBUG
# Best debugging experience
CFLAGS += -Og -ggdb
else
# Best code size
CFLAGS += -Os -fdata-sections -ffunction-sections
LDFLAGS += -Wl,--gc-sections
endif

# Just a simple function for printing bold text
define ECHO_BOLD
	@echo -e "\033[1;37m"$(1)"\033[0m"
endef

############################################################################################
outdir:
	@mkdir -p $(OUT_DIR)

%.o: %.c
	@echo -e -n "Compiling " $<"..." 
	@$(CC) -c $(CFLAGS) $^ -o $@
	@echo -e "\033[1;32m\033[2m DONE\033[0m"

# Targets & build commands
elf: $(OBJECTS)
	$(call ECHO_BOLD,"Compilation done. Linking...")
	$(CC) $(LDFLAGS) -o $(OUT_PATH).out -Xlinker -Map=$(OUT_DIR)/$(MAP_FILE) $^

hex: elf
	$(OBJCOPY) -O ihex $(OUT_PATH).out $(OUT_PATH).hex

all: clean outdir elf hex
	$(call ECHO_BOLD,"Done! .out and .hex generated in build directory.")
	$(call ECHO_BOLD,"Printing code size...")
	$(CODESIZE) $(OUT_PATH).out
	@rm $(MAIN_SRC:.c=.o)

clean:
	$(call ECHO_BOLD,"Cleaning...")
	rm -rf $(OUT_DIR)/
	rm -rf $(OBJECTS)