# JavaScript (Node.js) Donut

## How to Run
- Animate: `node languages/javascript/donut.js`
- Benchmark: `node languages/javascript/donut.js --benchmark --frames 500`

## Language Version Tested
- Node.js v24.10.0

## Performance Notes
- Uses Number (IEEE-754 double) arithmetic for parity with baseline formulas.

## Implementation Decisions
- Keeps direct torus math and z-buffer updates in nested loops.
- Uses ANSI escape control for terminal animation.

## Comparison vs original C
- Same default dimensions, angular increments, and luminance ramp ordering.
- JavaScript implementation is intentionally readable while preserving baseline behavior.

## Benchmark Results

Environment:
CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
OS: Windows 11 Pro (10.0.26200)
Language Version: Node.js v24.10.0

Baseline:
Frames: 500
Total Time: 1.4758s
Avg Frame: 2.95ms
FPS: 338.81
