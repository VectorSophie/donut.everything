# SPEC.md

## Baseline Specification (Version 1.0)

Reference Implementation: C (donut.c)

### Required Defaults
- Screen width: 80
- Screen height: 22
- Angle increments:
  - A += 0.04
  - B += 0.02
- Luminance ramp (dark → bright):
  ".,-~:;=!*#$@"

### Rendering Rules
- Floating-point math required
- Z-buffer must be implemented
- Only render if current depth > stored depth
- Negative luminance values clamp to 0

### Determinism
Given identical:
- Screen dimensions
- Float precision
- Angle increments

Frame N should produce equivalent output across languages
within reasonable floating-point tolerance.

### Versioning
Any behavioral deviation must:
- Increment baseline version
- Be documented in EVOLUTION.md