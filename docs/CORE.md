# donut.everything — core.md

## Overview

This document defines the mathematical and rendering model used by donut.c
by Andy Sloane. All implementations must follow this specification to
ensure visual consistency across languages.

---

## 1. Geometry: Parametric Torus

A torus is defined by two radii:

- R: distance from center of tube to center of torus
- r: radius of tube

Using parameters:
- θ (theta): angle around the tube
- φ (phi): angle around the central ring

Parametric equations:

x = (R + r cos θ) cos φ
y = (R + r cos θ) sin φ
z = r sin θ

---

## 2. Rotation in 3D

Rotation A → X-axis  
Rotation B → Z-axis

Rotation around X:

x' = x  
y' = y cos A - z sin A  
z' = y sin A + z cos A  

Rotation around Z:

x'' = x' cos B - y' sin B  
y'' = x' sin B + y' cos B  
z'' = z'

Angles A and B increment every frame.

---

## 3. Perspective Projection

Let:

K1 = screen scaling constant  
K2 = camera distance  

Projection:

ooz = 1 / (z + K2)  
xp = screen_width/2  + K1 * ooz * x  
yp = screen_height/2 - K1 * ooz * y  

---

## 4. Lighting Model

Luminance is computed via dot product:

L = dot(surface_normal, light_vector)

Only positive luminance values are rendered.

ASCII ramp (dark → bright):

".,-~:;=!*#$@"

Index selection:

index = luminance * 8

---

## 5. Z-Buffer

Maintain:

zbuffer[width * height]

Only render pixel if:

current_ooz > stored_ooz

---

## 6. Frame Algorithm

Per frame:

1. Clear buffers  
2. Loop θ from 0 → 2π  
3. Loop φ from 0 → 2π  
4. Compute 3D position  
5. Apply rotation  
6. Project to 2D  
7. Compute luminance  
8. Update z-buffer and output  
9. Print buffer  
10. Increment A and B  

---

## Implementation Requirements

All language ports must:

- Use floating point math  
- Use identical luminance ramp ordering  
- Use z-buffer logic  
- Use consistent angular increments  

Baseline behavior must remain reproducible.