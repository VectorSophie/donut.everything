# EVOLUTION.md

This document tracks all mutations and feature extensions beyond the
canonical baseline implementation.

Baseline Reference:
- Version: 1.0
- Source: donut.c
- Behavior: Deterministic ASCII torus renderer

---

## Versioning Philosophy

1. Baseline behavior must remain reproducible.
2. All mutations must be versioned.
3. Experimental features must not overwrite canonical behavior.
4. Any math changes require SPEC.md updates.

Version format:

MAJOR.MINOR.PATCH

- MAJOR → Breaking behavioral changes
- MINOR → Feature additions (non-breaking)
- PATCH → Internal refactors without visual change

---

# Evolution Log

## v1.1 — Parameterization

Add CLI/configurable parameters:
- Radius (R)
- Tube thickness (r)
- Rotation speeds (A_step, B_step)
- Field of view (FOV)
- Light vector components

No change to default baseline behavior.

---

## v1.2 — Color Support

ANSI-based luminance coloring.
- Depth-based coloring mode
- Luminance-based coloring mode

ASCII ramp preserved.
Baseline remains default mode.

---

## v1.3 — Physics Rotation

Add:
- Angular velocity
- Angular acceleration
- Friction coefficient
- Keyboard torque impulses

Baseline deterministic mode remains selectable.

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