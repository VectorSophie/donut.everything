# Python Donut

ASCII spinning torus following `docs/CORE.md` and `docs/SPEC.md` in pure Python.

## How to Run
- Animation (baseline): `python languages/python/donut.py`
- Animation (optimized precomputed angles): `python languages/python/donut.py --mode optimized`
- Benchmark (compute-only, default 500 frames): `python languages/python/donut.py --benchmark`

### Useful Options
- `--width` / `--height` — screen dimensions (default 80x22)
- `--r1` / `--r2` — tube radius / center radius (default 1.0 / 2.0)
- `--k1` / `--k2` — projection scale and camera distance (default 30.0 / 5.0)
- `--a-step` / `--b-step` — rotation speed increments (default 0.04 / 0.02)
- `--theta-step` / `--phi-step` — angular sampling steps (default 0.07 / 0.02)
- `--shading` — ASCII ramp dark→bright (default `.,-~:;=!*#$@`)
- `--frames` — frame count for benchmark (default 500)

## Tested Environment
- Python 3.13.12
- OS: Windows 11 Pro (10.0.26200)
- CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz

## Benchmark Results (Baseline)
- Frames: 500
- Total Time: 24.7784s
- Avg Frame Time: 49.56ms
- FPS: 20.18

## Implementation Notes
- Math matches `docs/CORE.md`: torus parametric geometry, X (A) and Z (B) rotations, perspective via `ooz = 1/(z + K2)`, and ASCII ramp `.,-~:;=!*#$@`.
- Projection uses 2:1 horizontal/vertical scaling (`k1` for X and `k1*0.5` for Y) to match classic `donut.c` terminal aspect behavior.
- Z-buffer prevents rear-surface bleed (`ooz` depth test per pixel).
- Baseline mode computes trig per sample; optimized mode caches `sin`/`cos` tables per frame to reduce math overhead without changing output.
- Screen clearing uses ANSI (`\x1b[H\x1b[2J`) each frame; terminal-only with no external graphics libraries.

## Comparison vs baseline C
- Preserves constants (80x22, A+=0.04, B+=0.02, default steps 0.07/0.02) and luminance ramp.
- Uses clearer variable names and double-precision Python floats while keeping operation order aligned with the original donut.c math.
- Adds configurable parameters and benchmark mode; animation output remains visually equivalent to baseline within floating-point tolerance.
