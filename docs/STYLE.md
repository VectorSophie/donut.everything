# STYLE.md

## Coding Style Guidelines

### General Rules
- Use radians for all angles
- Use descriptive variable names in non-baseline implementations
- Preserve mathematical clarity over brevity

### Floating Point
- Prefer double precision unless performance-critical
- Avoid reordering expressions without testing visual equivalence

### Naming Conventions
- theta, phi for torus parameters
- A, B for rotation angles (baseline compatibility)
- ooz for 1/z

### Formatting
- Consistent indentation (4 spaces recommended)
- Clear separation of geometry, projection, lighting, rendering

### Cross-Language Consistency
- Maintain identical luminance ramp ordering
- Maintain identical default constants