#!/usr/bin/env python3
"""Generate the short sound effects used for moves in Kaptis.

Pure standard library (wave/struct/math) so it can be re-run anywhere without
extra dependencies. Outputs 16-bit mono 44.1kHz WAV files into assets/sounds/.

Run from the repo root:  python3 tool/generate_sounds.py
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")


def write_wav(filename, samples):
    """Write float samples in [-1, 1] as a 16-bit mono WAV."""
    path = os.path.join(OUT_DIR, filename)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in samples:
            v = max(-1.0, min(1.0, s))
            frames += struct.pack("<h", int(v * 32767))
        w.writeframes(bytes(frames))
    print("wrote", path)


def adsr(i, n, attack, release):
    """Simple attack/decay envelope for a sample at index i of n total."""
    a = int(attack * SAMPLE_RATE)
    r = int(release * SAMPLE_RATE)
    if i < a:
        return i / max(1, a)
    if i > n - r:
        return max(0.0, (n - i) / max(1, r))
    return 1.0


def pawn_move():
    """Soft, bright wooden 'tick' with a quick downward pitch drop (~90ms)."""
    dur = 0.09
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Pitch glides from 1100Hz down to 700Hz.
        freq = 1100 - 400 * (t / dur)
        # Fast exponential decay gives it a percussive, plucky feel.
        decay = math.exp(-t * 38)
        env = adsr(i, n, 0.002, 0.04) * decay
        wave_val = (
            math.sin(2 * math.pi * freq * t)
            + 0.3 * math.sin(2 * math.pi * 2 * freq * t)
        )
        samples.append(0.5 * env * wave_val)
    return samples


def nexus_move():
    """Deeper, rounder 'thunk' with a gentle rising hum (~160ms)."""
    dur = 0.16
    n = int(dur * SAMPLE_RATE)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Low base tone rising slightly for a sense of weight settling.
        freq = 240 + 60 * (t / dur)
        decay = math.exp(-t * 14)
        env = adsr(i, n, 0.006, 0.08) * decay
        wave_val = (
            math.sin(2 * math.pi * freq * t)
            + 0.4 * math.sin(2 * math.pi * 1.5 * freq * t)
            + 0.2 * math.sin(2 * math.pi * 2 * freq * t)
        )
        samples.append(0.55 * env * wave_val)
    return samples


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    write_wav("pawn_move.wav", pawn_move())
    write_wav("nexus_move.wav", nexus_move())


if __name__ == "__main__":
    main()
