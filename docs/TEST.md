# TESTS.md

## Testing Philosophy

The donut is deterministic within floating-point tolerance.
Testing ensures cross-language consistency.

## Required Tests

### 1. Frame Snapshot Test
- Capture frame N
- Hash full ASCII output
- Compare across implementations

### 2. Z-Buffer Integrity Test
- Ensure no pixel renders behind nearer geometry

### 3. Luminance Distribution Test
- Verify brightness range matches baseline

### 4. Precision Drift Test
- Run 10,000 frames
- Compare angle values
- Ensure no catastrophic divergence

## Tolerance

Small floating-point deviations allowed.
Visual equivalence preferred over bit-perfect identity.