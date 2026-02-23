# EVOLUTION.md

This document tracks all mutations and feature extensions beyond the
canonical baseline implementation.

Baseline Reference:
- Version: 1.0.0
- Source: donut.c
- Behavior: Deterministic ASCII torus renderer

---

## Versioning Philosophy

Version format:

MAJOR.MINOR.PATCH

- MAJOR → Breaking behavioral changes
- MINOR → Significant feature additions (non-breaking)
- PATCH → Internal refactors without visual change

Rules:

1. Baseline behavior must remain reproducible.
2. All mutations must be versioned.
3. Experimental features must not overwrite canonical behavior.
4. Any math changes require SPEC.md updates.

---

# Evolution Log

## v1.1.0 — Multi-Language Expansion

Add official baseline-equivalent implementations in major languages:

- C (baseline reference)
- Rust
- Python
- Go
- JavaScript (Node)
- Java
- (Optional future) C#, Zig, Swift

Requirements:

- Exact behavioral parity with baseline
- Matching frame output within floating-point tolerance
- Deterministic frame test support
- Conformance to SPEC.md and TESTS.md

No visual or mathematical changes permitted in this version.
This release establishes cross-language canonical parity.

---

## v1.2.0 — Parameterization Layer

Add configurable parameters:

- Radius (R)
- Tube thickness (r)
- Rotation speeds (A_step, B_step)
- Field of view (FOV)
- Light vector components

Defaults must preserve baseline behavior.

---

## v1.3.0 — Color Support

Add ANSI-based luminance coloring:
- Depth-based coloring mode
- Luminance-based coloring mode

ASCII ramp preserved.
Baseline monochrome remains default mode.

---

## v2.0.0 — Rendering Abstraction Layer

Separate into modular subsystems:

- Geometry engine
- Lighting engine
- Projection engine
- Platform renderer

Enables:

- Web canvas port
- WASM build
- GPU experimentation

---

# Mutation Rules

All new features must:
- Preserve baseline path
- Be toggleable
- Be documented here
- Include visual comparison with baseline

---

# Future Directions

- GPU-based ASCII shader experiments
- Floating-point precision comparison suite
- Cross-language benchmark leaderboard
- Deterministic frame hashing standardization