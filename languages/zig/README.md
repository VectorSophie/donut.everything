# Zig Donut

## How to Run
- Compile: `zig build-exe languages/zig/donut.zig -O ReleaseFast -femit-bin=languages/zig/donut_zig`
- Animate: `languages/zig/donut_zig`
- Benchmark: `languages/zig/donut_zig --benchmark --frames 500`

## Language Version Tested
- Not executed in this environment (zig unavailable)

## Performance Notes
- Uses direct floating-point math with allocation-per-frame baseline flow.

## Implementation Decisions
- Same defaults as donut.c baseline for dimensions, radii, and increments.
- Maintains z-buffer depth handling and luminance-based shading.

## Comparison vs original C
- Equivalent model with explicit control flow and configuration parsing.

## Benchmark Results

Environment:
CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
OS: Windows 11 Pro (10.0.26200)
Language Version: Not verified locally

Baseline:
Frames: 500
Total Time: Not captured in this environment
Avg Frame: N/A
FPS: N/A
