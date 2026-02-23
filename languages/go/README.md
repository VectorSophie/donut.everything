# Go Donut

## How to Run
- Animate: `go run languages/go/donut.go`
- Benchmark: `go run languages/go/donut.go --benchmark --frames 500`

## Language Version Tested
- go1.25.5

## Performance Notes
- Native compiled execution via `go run` in this measurement.

## Implementation Decisions
- Baseline constants match donut.c geometry and motion.
- Uses ANSI terminal control for frame rendering.
- Benchmark mode runs compute-only frames.

## Comparison vs original C
- Same luminance ramp and z-buffer condition (`current_ooz > stored_ooz`).
- Code is de-obfuscated and split into clear renderer/config structure.

## Benchmark Results

Environment:
CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
OS: Windows 11 Pro (10.0.26200)
Language Version: go1.25.5

Baseline:
Frames: 500
Total Time: 0.8905s
Avg Frame: 1.78ms
FPS: 561.51
