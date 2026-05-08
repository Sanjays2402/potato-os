PROJECT := potato-os
BUILD_DIR := build
BOOT_BIN := $(BUILD_DIR)/boot.bin
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
IMAGE := $(BUILD_DIR)/$(PROJECT).img
ASM_BOOT := boot/boot.asm
ASM_KERNEL := boot/kernel.asm
KERNEL_SECTORS := 8

.PHONY: all help clean run verify hexdump

all: $(IMAGE) ## Build the bootable disk image (default)

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "PotatoOS targets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  %-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BOOT_BIN): $(ASM_BOOT) | $(BUILD_DIR)
	nasm -f bin $(ASM_BOOT) -o $(BOOT_BIN)
	@test $$(stat -f%z $(BOOT_BIN) 2>/dev/null || stat -c%s $(BOOT_BIN)) -eq 512

$(KERNEL_BIN): $(ASM_KERNEL) | $(BUILD_DIR)
	nasm -f bin $(ASM_KERNEL) -o $(KERNEL_BIN)
	@python3 scripts/pad_to_sectors.py $(KERNEL_BIN) $(KERNEL_SECTORS)

$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	cat $(BOOT_BIN) $(KERNEL_BIN) > $(IMAGE)

run: $(IMAGE) ## Boot the image in QEMU
	qemu-system-i386 -drive format=raw,file=$(IMAGE)

verify: $(IMAGE) ## Verify boot signature, image size, and stage-2 markers
	@python3 scripts/verify_boot_image.py $(IMAGE) $(KERNEL_SECTORS)
	@echo "OK: $(IMAGE) is a valid PotatoOS boot image."

hexdump: $(IMAGE) ## Tail-hexdump the disk image
	xxd $(IMAGE) | tail

clean: ## Remove build artifacts
	rm -rf $(BUILD_DIR)
