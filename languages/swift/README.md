# Swift Donut

## How to Run
- Compile: `swiftc languages/swift/donut.swift -O -o languages/swift/donut_swift`
- Animate: `languages/swift/donut_swift`
- Benchmark: `languages/swift/donut_swift --benchmark --frames 500`

## Language Version Tested
- Not executed in this environment (swift unavailable)

## Performance Notes
- Uses `Double` math for baseline parity.

## Implementation Decisions
- Preserves torus parametric equations, z-buffer, and luminance ramp mapping.
- Uses ANSI escape sequences for terminal animation.

## Comparison vs original C
- Same mathematical model and defaults, with explicit readable structure.

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
