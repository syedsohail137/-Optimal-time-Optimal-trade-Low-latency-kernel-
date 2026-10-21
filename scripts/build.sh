#!/bin/bash
# build.sh - Toolchain execution block compiling Bare-Metal Iso kernel environment
set -e

echo "=== Commencing Bare-Metal AlphaOS ISO Compilation Procedure ==="

# Check toolchain availability
if ! command -v nasm &> /dev/null || ! command -v clang++ &> /dev/null; then
    echo "Error: nasm or clang++ could not be found. Please install the target cross compilers."
    exit 1
fi

# Assemble standard hardware assembly initialization module
nasm -f elf32 src/_start.asm -o src/_start.o

# Execute cross compilation configuration generating pure freestanding system images
clang++ -target i386-pc-elf -ffreestanding -nostdlib -O3 \
    src/boot_opra_real.cpp src/_start.o \
    -T scripts/link.ld -o kernel.elf

echo "Kernel built successfully as kernel.elf."

# Construct structural GRUB ISO distribution if target building packages are available
if command -v grub-file &> /dev/null && command -v grub-mkrescue &> /dev/null; then
    grub-file --is-x86-multiboot2 kernel.elf
    
    mkdir -p isofiles/boot/grub
    cp kernel.elf isofiles/boot/kernel.elf
    
    cat << 'EOF' > isofiles/boot/grub/grub.cfg
menuentry "AlphaOS Option Trading Kernel" {
    multiboot2 /boot/kernel.elf
    boot
}
EOF
    
    grub-mkrescue -o AlphaOS_XAUUSD_15Apr2026.iso isofiles
    rm -rf isofiles
    echo "=== ISO generation completed: AlphaOS_XAUUSD_15Apr2026.iso ==="
else
    echo "Notice: Missing grub-mkrescue utility tools. Halting package compilation directly at kernel.elf."
fi
