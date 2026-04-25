#!/usr/bin/env python3
"""Pad a binary file to an exact number of 512-byte disk sectors."""
from pathlib import Path
import sys
path = Path(sys.argv[1])
sectors = int(sys.argv[2])
size = sectors * 512
data = path.read_bytes()
if len(data) > size:
    raise SystemExit(f"{path} is {len(data)} bytes, exceeds {size} bytes ({sectors} sectors)")
path.write_bytes(data + b"\0" * (size - len(data)))
print(f"padded {path} to {size} bytes")
