.DEFAULT_GOAL := all

############################################################################################
# General config
MAIN_SRC = main.c
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

# Enable for best debugging experience
CFLAGS += -Og -ggdb
LDFLAGS += -Og -ggdb
# Enable for maximum optimisation
# CFLAGS+=-fdata-sections -ffunction-sections -Wl,--gc-sections

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
	$(CC) -g $(LDFLAGS) -o $(OUT_PATH).out $^

hex: elf
	$(OBJCOPY) -O ihex $(OUT_PATH).out $(OUT_PATH).hex

all: clean outdir elf hex
	$(call ECHO_BOLD,"Done! .out and .hex generated in build directory.")
	@rm $(MAIN_SRC:.c=.o)

clean:
	$(call ECHO_BOLD,"Cleaning...")
	rm -rf $(OUT_DIR)/
	rm -rf $(OBJECTS)