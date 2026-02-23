# Kotlin Donut

## How to Run
- Compile: `kotlinc languages/kotlin/Donut.kt -include-runtime -d languages/kotlin/donut.jar`
- Animate: `java -jar languages/kotlin/donut.jar`
- Benchmark: `java -jar languages/kotlin/donut.jar --benchmark --frames 500`

## Language Version Tested
- Not executed in this environment (kotlinc unavailable)

## Performance Notes
- Implementation follows baseline math with `Double` precision.

## Implementation Decisions
- Keeps direct torus/rotation/projection pipeline and z-buffer update rule.
- Uses same defaults and shading ramp as donut.c baseline.

## Comparison vs original C
- Equivalent rendering model with de-obfuscated structure and clearer names.

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
