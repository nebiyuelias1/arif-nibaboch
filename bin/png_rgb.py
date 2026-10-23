#!/usr/bin/env python3
"""Normalize App Store screenshots to clean 8-bit RGB PNGs.

Rewrites the file in place, removing the alpha channel and all ancillary
metadata (eXIf, etc.), which App Store Connect rejects. Dependency-free.

Usage: png_rgb.py file1.png [file2.png ...]
"""

import struct
import sys
import zlib

SIGNATURE = b"\x89PNG\r\n\x1a\n"


def read_chunks(data):
    if data[:8] != SIGNATURE:
        raise ValueError("not a PNG")
    pos = 8
    chunks = []
    while pos < len(data):
        (length,) = struct.unpack(">I", data[pos : pos + 4])
        ctype = data[pos + 4 : pos + 8]
        payload = data[pos + 8 : pos + 8 + length]
        chunks.append((ctype, payload))
        pos += 12 + length
        if ctype == b"IEND":
            break
    return chunks


def unfilter(raw, height, stride, bpp):
    out = bytearray()
    prev = bytearray(stride)
    pos = 0
    for _ in range(height):
        filter_type = raw[pos]
        pos += 1
        line = bytearray(raw[pos : pos + stride])
        pos += stride
        if filter_type == 1:
            for x in range(bpp, stride):
                line[x] = (line[x] + line[x - bpp]) & 0xFF
        elif filter_type == 2:
            for x in range(stride):
                line[x] = (line[x] + prev[x]) & 0xFF
        elif filter_type == 3:
            for x in range(stride):
                left = line[x - bpp] if x >= bpp else 0
                line[x] = (line[x] + ((left + prev[x]) >> 1)) & 0xFF
        elif filter_type == 4:
            for x in range(stride):
                a = line[x - bpp] if x >= bpp else 0
                b = prev[x]
                c = prev[x - bpp] if x >= bpp else 0
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                predictor = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[x] = (line[x] + predictor) & 0xFF
        elif filter_type != 0:
            raise ValueError("unsupported PNG filter: %d" % filter_type)
        out += line
        prev = line
    return out


def chunk(ctype, payload):
    return (
        struct.pack(">I", len(payload))
        + ctype
        + payload
        + struct.pack(">I", zlib.crc32(ctype + payload) & 0xFFFFFFFF)
    )


def convert(path):
    with open(path, "rb") as handle:
        data = handle.read()

    chunks = read_chunks(data)
    ihdr = next(payload for ctype, payload in chunks if ctype == b"IHDR")
    width, height, depth, color, _, _, interlace = struct.unpack(">IIBBBBB", ihdr)
    if depth != 8 or interlace != 0 or color not in (2, 6):
        print(f"skip (unsupported format): {path}", file=sys.stderr)
        return

    idat = b"".join(payload for ctype, payload in chunks if ctype == b"IDAT")
    raw = zlib.decompress(idat)
    bpp = 4 if color == 6 else 3
    stride = width * bpp

    if color == 6:
        pixels = unfilter(raw, height, stride, 4)
        rows = bytearray()
        for y in range(height):
            start = y * stride
            line = pixels[start : start + stride]
            rgb = bytearray(width * 3)
            rgb[0::3] = line[0::4]
            rgb[1::3] = line[1::4]
            rgb[2::3] = line[2::4]
            rows += b"\x00" + rgb
        raw = bytes(rows)

    header = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    output = (
        SIGNATURE
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(raw, 9))
        + chunk(b"IEND", b"")
    )
    with open(path, "wb") as handle:
        handle.write(output)


for arg in sys.argv[1:]:
    convert(arg)
