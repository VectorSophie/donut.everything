# C++ Donut

## How to Run
- Compile: `g++ -O2 -std=c++17 -o languages/cpp/donut_cpp.exe languages/cpp/donut.cpp`
- Animate: `languages/cpp/donut_cpp.exe`
- Benchmark: `languages/cpp/donut_cpp.exe --benchmark --frames 500`

## Language Version Tested
- g++ 15.2.0 (MSYS2)

## Performance Notes
- Baseline implementation uses direct trig evaluation and per-frame buffer allocation.

## Implementation Decisions
- Defaults mirror classic donut.c dimensions and motion: 80x22, R1=1, R2=2, K1=30, K2=5, A+=0.04, B+=0.02.
- Projection uses `k1` for X and `k1*0.5` for Y to preserve terminal aspect behavior.
- No external graphics libraries; ANSI escape sequences only.

## Comparison vs original C
- Same torus geometry, rotation model, luminance ramp, and z-buffer depth test.
- Expanded variable names for readability.

## Benchmark Results

Environment:
CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
OS: Windows 11 Pro (10.0.26200)
Language Version: g++ 15.2.0

Baseline:
Frames: 500
Total Time: Not captured in this environment (binary output issue)
Avg Frame: N/A
FPS: N/A
