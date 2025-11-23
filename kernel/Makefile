# Compiler and assembler
CC = i686-elf-gcc
AS = i686-elf-as

# Source files
BOOT_SRC = boot.s
KERNEL_SRC = kernel.c

# Output files
BUILD_DIR = $(PWD)/build
BOOT_OBJ = $(BUILD_DIR)/boot.o
KERNEL_OBJ = $(BUILD_DIR)/kernel.o
OS_BIN = $(BUILD_DIR)/myos.bin
ISO_FILE = $(BUILD_DIR)/myos.iso

# Linker script
LINKER_SCRIPT = linker.ld

# Compiler flags
CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -ffreestanding -O2 -nostdlib

# Object files list
OBJS = $(BOOT_OBJ) $(KERNEL_OBJ)

# Default target
.PHONY: all clean grub
all: $(OS_BIN) grub

# Linking rule
$(OS_BIN): check_build_dir $(OBJS) $(LINKER_SCRIPT)
	$(CC) -T $(LINKER_SCRIPT) -o $@ $(LDFLAGS) $(OBJS) -lgcc

# Compilation rules
$(BOOT_OBJ): $(BOOT_SRC)
	$(AS) $< -o $@

$(KERNEL_OBJ): $(KERNEL_SRC)
	$(CC) -c $< -o $@ $(CFLAGS)

$(ISO_FILE): check_iso_dir $(OS_BIN)
	cp $(OS_BIN) isodir/boot/
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO_FILE) isodir

grub: $(ISO_FILE)

run_qemu:
	qemu-system-i386 -kernel ./build/myos.bin

check_build_dir:
	@if [ ! -d "$(BUILD_DIR)" ]; then mkdir -p "$(BUILD_DIR)"; fi

check_iso_dir:
	@if [ ! -d isodir/boot/grub ]; then mkdir -p isodir/boot/grub; fi

# Clean rule
clean:
	rm -f $(OBJS) $(OS_BIN) $(ISO_FILE)
