# Rust Donut

## How to Run
- Compile: `rustc -O languages/rust/donut.rs -o languages/rust/donut_rs`
- Animate: `languages/rust/donut_rs`
- Benchmark: `languages/rust/donut_rs --benchmark --frames 500`

## Language Version Tested
- rustc 1.92.0

## Performance Notes
- Native optimized build with scalar math.

## Implementation Decisions
- Defaults mirror donut.c dimensions/motion and shading ramp.
- Projection uses 2:1 horizontal/vertical scaling (`k1` and `k1*0.5`).
- Benchmark mode disables terminal output and measures compute-only frames.

## Comparison vs original C
- Preserves torus math, depth buffer semantics, and luminance mapping.
- Improves readability while maintaining baseline structure.

## Benchmark Results

Environment:
CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
OS: Windows 11 Pro (10.0.26200)
Language Version: rustc 1.92.0

Baseline:
Frames: 500
Total Time: 1.5058s
Avg Frame: 3.01ms
FPS: 332.05
