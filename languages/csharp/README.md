# C# Donut

## How to Run
- Compile: `csc -nologo -out:languages/csharp/Donut.exe languages/csharp/Donut.cs`
- Animate: `languages/csharp/Donut.exe`
- Benchmark: `languages/csharp/Donut.exe --benchmark --frames 500`

## Language Version Tested
- csc 4.14.0

## Performance Notes
- Uses `double` for geometry and depth precision.

## Implementation Decisions
- Baseline constants and formulas mirror donut.c behavior.
- Terminal output uses ANSI escapes; benchmark mode avoids output.

## Comparison vs original C
- Preserves z-buffer update rule and luminance-to-ramp mapping.
- Uses explicit, idiomatic C# class structure for clarity.

## Benchmark Results

Environment:
CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
OS: Windows 11 Pro (10.0.26200)
Language Version: csc 4.14.0

Baseline:
Frames: 500
Total Time: 2.5205s
Avg Frame: 5.04ms
FPS: 198.37
