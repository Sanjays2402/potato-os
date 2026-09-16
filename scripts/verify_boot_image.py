#!/usr/bin/env python3
"""Verify PotatoOS disk image invariants.

Checks:
  - exact image size for the expected sector budget
  - BIOS boot signature (0x55AA) at offset 510
  - stage-2 shell markers present in the kernel region
  - doc/code consistency: every shell command documented in the README's
    command table exists as a null-terminated literal in the stage-2 kernel
    binary, so a documented command can never silently go missing.
"""
from pathlib import Path
import re
import sys

path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("build/potato-os.img")
kernel_sectors = int(sys.argv[2]) if len(sys.argv) > 2 else 8
expected_size = 512 + kernel_sectors * 512
data = path.read_bytes()
if len(data) != expected_size:
    raise SystemExit(f"invalid image size: {len(data)} bytes, expected {expected_size}")
if data[510:512] != b"\x55\xaa":
    raise SystemExit("invalid boot signature: expected 55 aa at offset 510")
for marker in (b"PotatoOS v0.1.0", b"potato> ", b"commands: help"):
    if marker not in data:
        raise SystemExit(f"missing marker: {marker!r}")

kernel = data[512 : 512 + kernel_sectors * 512]
readme = Path(__file__).resolve().parent.parent / "README.md"
commands = []
if readme.exists():
    table = readme.read_text().split("## Shell commands", 1)
    if len(table) == 2:
        section = table[1].split("\n## ", 1)[0]
        commands = re.findall(r"^\|\s*`([a-z0-9-]+)`\s*\|", section, re.M)
for cmd in commands:
    if cmd.encode() + b"\x00" not in kernel:
        raise SystemExit(
            f"README documents shell command {cmd!r} but no null-terminated "
            f"literal for it exists in the stage-2 kernel"
        )

print(
    f"verified {path}: {len(data)} bytes, boot signature 55aa, "
    f"stage-2 shell markers present, {len(commands)} documented shell "
    f"command(s) present in kernel"
)
