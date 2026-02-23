# Java Donut

## How to Run
- Compile: `javac languages/java/Donut.java`
- Animate: `java -cp languages/java Donut`
- Benchmark: `java -cp languages/java Donut --benchmark --frames 500`

## Language Version Tested
- javac 11.0.28 / Java Runtime 11.0.28

## Performance Notes
- Uses double precision math and simple arrays for depth and output buffers.

## Implementation Decisions
- Preserves baseline constants and operation ordering from donut.c.
- Keeps benchmark mode compute-only for cross-language comparability.

## Comparison vs original C
- Same torus equations, rotational increments, depth test, and ASCII ramp.
- Java version is explicit and educational compared to C obfuscation.

## Benchmark Results

Environment:
CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
OS: Windows 11 Pro (10.0.26200)
Language Version: Java 11.0.28

Baseline:
Frames: 500
Total Time: 1.0832s
Avg Frame: 2.17ms
FPS: 461.61
