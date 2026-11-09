# AlphaOS: Bare-Metal Low-Latency Option Trading Engine

A C++ bare-metal kernel project described as a low-latency parser and alpha engine for real-time OPRA options feeds. The repository description says it uses zero-copy DMA ring buffers and fixed-point math to detect pricing distortions in the OS kernel.

## Features

- Freestanding, heapless design; the existing project documentation specifies `-ffreestanding` and `-nostdlib`.
- Triple-buffer data flow (`display`, `render`, `spare`) with pointer swaps.
- 64-byte alignment for data frames and option structures.
- Fixed-point arithmetic (documented scale: 10,000) instead of floating-point math.

## Build

The documented prerequisites on Ubuntu are:

```bash
sudo apt-get install clang lld nasm qemu-system-x86_64 xorriso grub-pc-bin
```

Build the ISO using the repository script:

```bash
chmod +x scripts/build.sh
./scripts/build.sh
```

## Emulate

The README documents this QEMU command for the generated image:

```bash
qemu-system-x86_64 -cdrom AlphaOS_XAUUSD_15Apr2026.iso -m 512 -nographic
```

## Performance figures in the original documentation

The original README reports approximately 18 CPU cycles (~5.1 ns) for `alpha_ratio()`, 82 ns for a 16-strike snapshot, and mean absolute error of 2.1% (maximum 3.8%) for an XAUUSD backtest dated 15 April 2026. These figures are project-reported and have not been independently verified here.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
