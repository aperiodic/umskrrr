
# explicitly set shell for compatibility with non-GNU make
SHELL = /bin/bash

.SUFFIXES:
.SUFFIXES: .c .o .hex .elf .S

# Source files
CSRC = threads.c
ASRC = save_pc.S load_pc.S suspend_thread.S resume_thread.S load_context.S save_context.S
OBJECTS = $(CSRC:.c=.o) $(ASRC:.S=.o)
	
PROG = threads

# AVR-related settings
PORT = /dev/tty.usbserial-A9007QiA
MCU = atmega328p
F_CPU = 16000000
FORMAT = ihex
UPLOAD_RATE = 19200

# Programming support using avrdude. Settings and variables.
AVRDUDE_PROGRAMMER = stk500v1
AVRDUDE_CONF = -C/Applications/Arduino.app/Contents/Resources/Java/hardware/tools/avr/etc/avrdude.conf
AVRDUDE_MCU = -patmega328p
AVRDUDE_BAUD = -b57600
AVRDUDE_PORT = $(PORT)
AVRDUDE_WRITE_FLASH = -Uflash:w:$(PROG).hex
AVRDUDE_FLAGS = -F $(AVRDUDE_CONF) $(AVRDUDE_MCU) $(AVRDUDE_BAUD) -P$(AVRDUDE_PORT) -c$(AVRDUDE_PROGRAMMER) 

MAKEFILE = Makefile

# compiler flags
OPT = s
DEBUG = 
CDEBUG = -g$(DEBUG)
CWARN = -Wall -Wstrict-prototypes
CDEFS = -DF_CPU=$(F_CPU)
CFLAGS = -mmcu=$(MCU) -I. $(CDEFS) $(CDEBUG) -O$(OPT) $(CWARN) 
ASFLAGS = -mmcu=$(MCU) -x assembler
LDFLAGS = -Wl 

CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
AR = avr-ar
SIZE = avr-size
M = avr-nm
AVRDUDE = avrdude
RM = rm -f
MV = mv -f


# default target
all: build

build: elf lst hex 

elf: $(PROG).elf
lst: $(PROG).lst
hex: $(PROG).hex

upload: $(PROG).hex 
	$(AVRDUDE) $(AVRDUDE_FLAGS) $(AVRDUDE_WRITE_FLASH)

.elf.hex:
	$(OBJCOPY) -O $(FORMAT) -R .eeprom $< $@

$(PROG).lst: $(PROG).elf
	$(OBJDUMP) -h -S $(PROG).elf > $(PROG).lst

$(PROG).elf: $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ $(OBJECTS) -L/usr/local/CrossPack-AVR/avr/lib -lc $(LDFLAGS)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.S.o:
	$(CC) $(ASFLAGS) -c $< -o $@

.PHONY: clean

clean:
	$(RM) $(ASRC:.S=.o) $(CSRC:.c=.o) $(PROG).elf $(PROG).hex $(PROG).map

depend:
	makedepend -- $(CFLAGS) -- $(CSRC)

# DO NOT DELETE THIS LINE -- make depend depends on it.

threads.o: threads.h
