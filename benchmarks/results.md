# Benchmark Results

All runs use resolution 80x22, R1=1.0, R2=2.0, K1=30.0, K2=5.0, A+=0.04, B+=0.02, theta_step=0.07, phi_step=0.02, frame count 500 unless noted.

## Environment
- OS: Windows 11 Pro (10.0.26200)
- CPU: 11th Gen Intel(R) Core(TM) i5-1135G7 @ 2.40GHz
- Notes: Terminal compute-only benchmark; no rendering during benchmark.

## Python (baseline)
- Language Version: Python 3.13.12 (CPython)
- Frames: 500
- Total Time: 24.7784s
- Avg Frame Time: 49.56ms
- FPS: 20.18
- Runtime Model: Interpreter (no JIT)

## C++ (baseline)
- Language Version: g++ 15.2.0
- Frames: 500
- Total Time: Not captured in this environment (binary output issue)
- Avg Frame Time: N/A
- FPS: N/A
- Runtime Model: Native AOT compiled

## Rust (baseline)
- Language Version: rustc 1.92.0
- Frames: 500
- Total Time: 1.5058s
- Avg Frame Time: 3.01ms
- FPS: 332.05
- Runtime Model: Native AOT compiled

## Go (baseline)
- Language Version: go1.25.5
- Frames: 500
- Total Time: 0.8905s
- Avg Frame Time: 1.78ms
- FPS: 561.51
- Runtime Model: Native compiled (gc)

## Java (baseline)
- Language Version: Java 11.0.28
- Frames: 500
- Total Time: 1.0832s
- Avg Frame Time: 2.17ms
- FPS: 461.61
- Runtime Model: JVM (JIT)

## JavaScript Node.js (baseline)
- Language Version: Node.js v24.10.0
- Frames: 500
- Total Time: 1.4758s
- Avg Frame Time: 2.95ms
- FPS: 338.81
- Runtime Model: V8 JIT

## C# (baseline)
- Language Version: csc 4.14.0
- Frames: 500
- Total Time: 2.5205s
- Avg Frame Time: 5.04ms
- FPS: 198.37
- Runtime Model: .NET CLR (JIT)

## Kotlin (baseline)
- Language Version: Not verified locally
- Frames: 500
- Total Time: Not captured in this environment (kotlinc unavailable)
- Avg Frame Time: N/A
- FPS: N/A
- Runtime Model: JVM (JIT)

## Swift (baseline)
- Language Version: Not verified locally
- Frames: 500
- Total Time: Not captured in this environment (swift unavailable)
- Avg Frame Time: N/A
- FPS: N/A
- Runtime Model: Native AOT compiled

## Zig (baseline)
- Language Version: Not verified locally
- Frames: 500
- Total Time: Not captured in this environment (zig unavailable)
- Avg Frame Time: N/A
- FPS: N/A
- Runtime Model: Native AOT compiled
