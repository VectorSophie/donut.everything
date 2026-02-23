# ARCHITECTURE.md

## Repository Structure

/baseline       → Canonical C implementation  
/shared         → Language-agnostic math references  
/rust           → Rust implementation  
/python         → Python implementation  
/go             → Go implementation  
/js             → JavaScript implementation  
/tests          → Cross-language validation tests  
/docs           → The folder that contains this doc

## Conceptual Layers

1. Geometry Layer
   - Torus parametric equation
   - Rotation math

2. Projection Layer
   - Perspective divide
   - Screen mapping

3. Lighting Layer
   - Surface normal
   - Dot product luminance

4. Rendering Layer
   - Z-buffer
   - ASCII ramp mapping

5. Platform Adapter
   - Terminal handling
   - Frame timing
   - ANSI escape control

All implementations must preserve this layered separation.