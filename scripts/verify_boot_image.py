#!/usr/bin/env python3
"""Verify PotatoOS disk image invariants."""
from pathlib import Path
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
print(f"verified {path}: {len(data)} bytes, boot signature 55aa, stage-2 shell markers present")
