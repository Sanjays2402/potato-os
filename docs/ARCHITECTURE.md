# PotatoOS Architecture

PotatoOS v0.1.0 is a tiny BIOS-bootable OS with a two-stage real-mode design.

## Boot flow

1. BIOS loads the first disk sector into memory at `0000:7C00`.
2. Stage 1 (`boot/boot.asm`) initializes segment registers and stack.
3. Stage 1 uses BIOS interrupt `0x13` to load 8 disk sectors starting at sector 2 into `0000:8000`.
4. Execution jumps to the stage-2 kernel at `0x8000`.
5. Stage 2 (`boot/kernel.asm`) switches to text mode, prints the banner, and starts the shell.
6. Keyboard input uses BIOS interrupt `0x16`; text output uses BIOS interrupt `0x10`, function `0x0E`.

## Memory map

```text
0x7C00  stage-1 bootloader (512 bytes)
0x8000  stage-2 shell kernel (currently padded to 8 sectors)
```

## Why two stages?

A single BIOS boot sector has only 512 bytes, and two bytes are reserved for the `0x55AA` signature. A second stage keeps the bootloader auditable while giving the shell enough room to be useful.

## Current limits

- 16-bit real mode only
- BIOS services only
- No filesystem yet
- No hardware interrupts/IDT yet
- No protected/long mode yet

## Next milestones

1. Add a timer interrupt and real uptime counter.
2. Split command handling into a tiny kernel command table.
3. Enter 32-bit protected mode.
4. Add a basic VGA text driver independent of BIOS teletype.
