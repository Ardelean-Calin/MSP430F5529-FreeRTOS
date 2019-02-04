.DEFAULT_GOAL := all

############################################################################################
# General config
MAIN_SRC = main.c
OUT_DIR = build
OUT_NAME = main
OUT_PATH = $(OUT_DIR)/$(OUT_NAME)

############################################################################################
# Target-related files
LINKER_FILE = msp430f5529.ld
SUPPORT_FILES = C:/ti/msp430-gcc-support-files/include

############################################################################################
# Executables
CC = C:/ti/msp430-gcc/bin/msp430-elf-gcc.exe
OBJCOPY = C:/ti/msp430-gcc/bin/msp430-elf-objcopy.exe

############################################################################################
# Hardware Abstraction Layer / TI Driverlib
HAL_DIR = driverlib
HAL_SRC = $(wildcard $(HAL_DIR)/*.c)

############################################################################################
# FreeRTOS Sources
FREERTOS_DIR = FreeRTOS/Source
FREERTOS_SRC = $(wildcard $(FREERTOS_DIR)/*.c) $(wildcard $(FREERTOS_DIR)/portable/GCC/MSP430F449/*.c)
MEMORY_MGMT_SRC = $(wildcard $(FREERTOS_DIR)/portable/MemMang/*.c)

############################################################################################
# Objects
OBJECTS=$(FREERTOS_SRC:.c=.o) $(MEMORY_MGMT_SRC:.c=.o) $(HAL_SRC:.c=.o) $(MAIN_SRC:.c=.o) 

############################################################################################
# Flags
CFLAGS += -mmcu=msp430f5529
CFLAGS += -I$(FREERTOS_DIR)/include -I$(FREERTOS_DIR)/portable/GCC/MSP430F449 -Iinclude -I$(HAL_DIR) -I$(SUPPORT_FILES) 

# Linker flags
LDFLAGS += -mmcu=msp430f5529
LDFLAGS += -T$(LINKER_FILE) -L$(SUPPORT_FILES)

# Enable for best debugging experience
CFLAGS += -Og
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
	$(CC) -g $(LDFLAGS) -o $(OUT_PATH).elf $^

hex: elf
	$(OBJCOPY) -O ihex $(OUT_PATH).elf $(OUT_PATH).hex

all: clean outdir elf hex
	$(call ECHO_BOLD,"Done! .elf and .hex generated in build directory.")
	@rm $(MAIN_SRC:.c=.o)

clean:
	$(call ECHO_BOLD,"Cleaning...")
	rm -rf $(OUT_DIR)/
	rm -rf **/*.o